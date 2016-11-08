`timescale 1ns / 10ps

module helm_ctrl #(
  parameter C_MSG_BLK_WRITE   = 8'h00,
  parameter C_MSG_BYTE_WRITE  = 8'h01,
  parameter C_MSG_BLK_READ    = 8'h02,
  parameter C_MSG_BLK_WR_VER  = 8'h03,
  parameter C_MSG_BLK_WR_CONF = 8'h80,
  parameter C_MSG_BLK_RD_STAT = 8'h81
)(
  input                 clk, 
  input                 rst_b,

  input           [7:0] msg_type, 
  input           [7:0] msg_page,
  input           [7:0] msg_offset,
  input                 msg_exec, 
  input                 msg_chksum_err,

  input                 msg_data_wr, 
  input           [7:0] msg_data_adr, 
  input           [7:0] msg_data,

  output reg            tx_blkrd,
  output reg            tx_blkwr,
  output reg      [7:0] data_len,
  output reg      [7:0] usr_mem_page,
  output reg      [7:0] usr_mem_offset,
  output reg            usr_mem_wr_en,
  output          [7:0] usr_mem_wr_data,
  output          [7:0] usr_mem_wr_msk
);

  reg             dpram_rd;
  reg       [7:0] wr_cntr;
  reg       [2:0] ctrl_fsm_cs, ctrl_fsm_ns;
  reg       [7:0] msg_byte_2, msg_byte_3;
  reg       [7:0] msg_rd_adr;
  wire      [7:0] msg_rd_data;

  assign {usr_mem_wr_data, usr_mem_wr_msk} = (dpram_rd)? {msg_rd_data, 8'hFF}:
                         (msg_type == C_MSG_BYTE_WRITE)? {msg_byte_2, msg_byte_3}:
                                                         {msg_byte_2, 8'hFF};

  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b)
    begin
      msg_byte_2 <= 'd0;
      msg_byte_3 <= 'd0;
      tx_blkrd <= 'd0;
      tx_blkwr <= 'd0;
      usr_mem_wr_en <= 'd0;
      data_len <= 'd0;
      wr_cntr <= 'd0;
      dpram_rd <= 'd0;
    end
    else
    begin
      if (msg_data_wr && msg_data_adr == 'd2)
        msg_byte_2 <= msg_data;
      if (msg_data_wr && msg_data_adr == 'd3)
        msg_byte_3 <= msg_data;

      case (ctrl_fsm_ns)
      'd4: // Block Write MEM
      begin
        tx_blkwr <= 1'b0;
        tx_blkrd <= 1'b0;
        data_len <= msg_byte_2;

        usr_mem_wr_en <= (ctrl_fsm_cs == 'd4)? 1'b1:1'b0;
        usr_mem_offset <= usr_mem_offset + {7'd0, usr_mem_wr_en};
        wr_cntr <= wr_cntr + {8{|wr_cntr}};
        msg_rd_adr <= msg_rd_adr + 'd1;
        dpram_rd <= (ctrl_fsm_cs == 'd4)? 1'b1:1'b0;
      end
      'd5: // Block Write TX
      begin
        tx_blkwr <= 1'b1;
        tx_blkrd <= 1'b0;
        data_len <= data_len;

        usr_mem_wr_en <= 'd1;
        usr_mem_offset <= usr_mem_offset + {7'd0, usr_mem_wr_en};
        dpram_rd <= 'd1;
      end
      'd1: // Byte Write
      begin
        tx_blkwr <= 1'b1;
        tx_blkrd <= 1'b0;
        usr_mem_wr_en <= 'd1;
        data_len <= 'd1;
        dpram_rd <= 'd0;
      end
      'd2: // Block Read
      begin
        tx_blkwr <= 1'b0;
        tx_blkrd <= 1'b1;
        usr_mem_wr_en <= 'd0;
        data_len <= msg_byte_2;
        dpram_rd <= 'd0;
      end

      default: //
      begin
        tx_blkrd <= 1'd0;
        tx_blkwr <= 1'b0;
        usr_mem_wr_en <= 'd0;
        {usr_mem_page, usr_mem_offset} <= {msg_page, msg_offset};
        wr_cntr <= msg_byte_2;
        msg_rd_adr <= 'd3;
        dpram_rd <= 'd0;
      end
      endcase
    end
  end

  always @(*)
  begin
    case (ctrl_fsm_cs)
    'd4: // Block Write
      ctrl_fsm_ns = (|wr_cntr)? 4'd4:'d5;
    'd5: // Block Write
      ctrl_fsm_ns = 'd3;

    'd1: // Byte Write
      ctrl_fsm_ns = 'd3;
    'd2: // Block Read
      ctrl_fsm_ns = 'd3;
    'd3: // 
      ctrl_fsm_ns = 'd0;

    default: // 'd0
      ctrl_fsm_ns = (~msg_exec | msg_chksum_err)? 'd0:
                    (msg_type == C_MSG_BLK_WRITE)? 'd4:
                    (msg_type == C_MSG_BYTE_WRITE)? 'd1: 
                    (msg_type == C_MSG_BLK_READ)? 'd2: 'd0; 
    endcase
  end

  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b)
      ctrl_fsm_cs <= 'd0;
    else
      ctrl_fsm_cs <= ctrl_fsm_ns;
  end

  dpram_256x8 i_msg_buf(
    .clock(clk), 
    
    .wren(msg_data_wr), 
    .wraddress(msg_data_adr),   .data(msg_data), 
    .rdaddress(msg_rd_adr),     .q(msg_rd_data)
  );

endmodule
