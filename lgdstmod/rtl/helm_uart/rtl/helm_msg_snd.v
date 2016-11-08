`timescale 1ns / 10ps

module helm_msg_snd #(
  parameter         PREAMBLE = 32'hAA995566,
  parameter C_MSG_BLK_WRITE   = 8'h00,
  parameter C_MSG_BYTE_WRITE  = 8'h01,
  parameter C_MSG_BLK_READ    = 8'h02,
  parameter C_MSG_BLK_WR_VER  = 8'h03,
  parameter C_MSG_BLK_WR_CONF = 8'h80,
  parameter C_MSG_BLK_RD_STAT = 8'h81
)(
  input                 clk,
  input                 rst_b,

  output reg            tx_wr,
  input                 tx_busy,
  output reg      [7:0] tx_data,

  input                 tx_blkrd,
  input                 tx_blkwr,
  input           [7:0] data_len,

  input           [7:0] msg_type,
  input           [7:0] msg_seq_no, 
  input           [7:0] msg_page,
  input           [7:0] msg_offset,

  output reg            usr_mem_cs = 1'b0,
  output reg            usr_mem_rd_en = 1'b0,
  output          [7:0] usr_mem_page,
  output          [7:0] usr_mem_offset,
  input           [7:0] usr_mem_data,
  input                 usr_mem_ack
);

  reg     [7:0] tx_msg_type;
  reg     [7:0] tx_msg_seq_no;
  reg    [15:0] tx_msg_base_addr;
  reg     [7:0] tx_msg_len; 
  reg     [7:0] tx_data_len;
  reg     [7:0] tx_chksum;

  reg     [2:0] tx_fsm_cs, tx_fsm_ns;
  reg     [7:0] tx_send_cntr;

  reg     [7:0] usr_mem_buf;
  reg           usr_mem_data_vld = 'd0;

  assign {usr_mem_page, usr_mem_offset} = tx_msg_base_addr;

  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b)
    begin   
      usr_mem_data_vld <= 'd0;
    end
    else
    begin
      if (tx_blkrd | tx_blkwr)
      begin
        tx_msg_type <= (msg_type == C_MSG_BLK_WRITE)?  C_MSG_BLK_WR_CONF:
                       (msg_type == C_MSG_BYTE_WRITE)? C_MSG_BLK_WR_CONF:
                       (msg_type == C_MSG_BLK_READ)?   C_MSG_BLK_RD_STAT:
                       8'h00;
        tx_msg_seq_no <= msg_seq_no;
        tx_msg_base_addr <= {msg_page, msg_offset};
        tx_msg_len <= (msg_type == C_MSG_BLK_WRITE)? data_len + 8'd3:
                      (msg_type == C_MSG_BYTE_WRITE)? 8'd4:
                      (msg_type == C_MSG_BLK_READ)? data_len + 8'd3:
                      8'h00;
        tx_data_len <= data_len;
        usr_mem_data_vld <= 'd0;
      end
      else 
      begin   
        //tx_msg_base_addr <= tx_msg_base_addr + {15'd0, usr_mem_cs & usr_mem_rd_en};
        tx_msg_base_addr[7:0] <= tx_msg_base_addr[7:0] + {7'd0, usr_mem_cs & usr_mem_rd_en};
        usr_mem_data_vld <= (usr_mem_cs & usr_mem_rd_en)? 'd0:
                            (usr_mem_ack)? 'd1: usr_mem_data_vld;
        usr_mem_buf <= (usr_mem_ack)? usr_mem_data:usr_mem_buf;
      end
    end
  end

  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b)
    begin
      tx_send_cntr <= 'd0;
      tx_wr <= 'd0;
      usr_mem_cs <= 'd0;
      usr_mem_rd_en <= 'd0;
    end
    else
    begin
      case (tx_fsm_cs)
      'd1: 
      begin
        tx_send_cntr <= (~|tx_send_cntr)? tx_data_len:
                        tx_send_cntr + {8{tx_wr}};
        tx_wr <= |tx_send_cntr & ~tx_busy & ~tx_wr;
        tx_data <= (tx_send_cntr[3:0] == 4'd10)? PREAMBLE[31:24]:
                   (tx_send_cntr[3:0] == 4'd9)? PREAMBLE[23:16]:
                   (tx_send_cntr[3:0] == 4'd8)? PREAMBLE[15: 8]:
                   (tx_send_cntr[3:0] == 4'd7)? PREAMBLE[ 7: 0]: 
                   (tx_send_cntr[3:0] == 4'd6)? tx_msg_type:
                   (tx_send_cntr[3:0] == 4'd5)? tx_msg_seq_no:
                   (tx_send_cntr[3:0] == 4'd4)? tx_msg_len:
                   (tx_send_cntr[3:0] == 4'd3)? tx_msg_base_addr[15:8]:
                   (tx_send_cntr[3:0] == 4'd2)? tx_msg_base_addr[7:0]:
                   (tx_send_cntr[3:0] == 4'd1)? tx_data_len:
                   'd0;
        tx_chksum = (~tx_wr)? tx_chksum:
                    (tx_send_cntr[3:0] == 4'd6)? tx_data: tx_chksum+tx_data;

        usr_mem_cs <= ~|tx_send_cntr & |tx_data_len;
        usr_mem_rd_en <= ~|tx_send_cntr & |tx_data_len;
      end
      'd2:
      begin
        tx_send_cntr <= tx_send_cntr + {8{tx_wr}};
        tx_wr <= |tx_send_cntr & ~tx_busy & ~tx_wr;
        tx_data <= usr_mem_buf;
        tx_chksum = (~tx_wr)? tx_chksum: tx_chksum+tx_data;

        usr_mem_cs <= |tx_send_cntr[7:1] & tx_wr;
        usr_mem_rd_en <= |tx_send_cntr[7:1] & tx_wr;
      end
      'd3:
      begin
        tx_wr <= ~tx_busy & ~tx_wr;
        tx_data <= tx_chksum;
      end

      default:
      begin
        tx_send_cntr <= 7'd10;
        tx_wr <= 'd0;
      end
      endcase
    end
  end

  always @(*)
  begin
    case (tx_fsm_cs)
    'd1: // TX_Preamble
      tx_fsm_ns = (|tx_send_cntr)? 'd1:
                  (tx_data_len)? 'd2:'d3;
    'd2:
      tx_fsm_ns = (|tx_send_cntr)? 'd2: 'd3;
    'd3:
      tx_fsm_ns = (tx_wr)? 'd0: 'd3;

    default: //'d0 
      tx_fsm_ns = (tx_blkrd | tx_blkwr)? 'd1:'d0;
    endcase
  end

  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b)
      tx_fsm_cs <= 'd0;
    else
      tx_fsm_cs <= tx_fsm_ns;
  end
endmodule
