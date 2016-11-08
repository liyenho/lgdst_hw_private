`timescale 1ns / 10ps

module helm_msg_rcv#(
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

  input                 rx_vld, 
  input           [7:0] rx_data,

  output reg      [7:0] msg_type,
  output reg      [7:0] msg_seq_no, 
  output reg      [7:0] msg_page,
  output reg      [7:0] msg_offset,
  output reg      [7:0] msg_data_length = 'd0,
  output reg      [7:0] msg_chksum,

  output reg      [7:0] msg_data_adr,
  output reg      [7:0] msg_data,
  output reg            msg_data_wr = 'd0, 
  output reg            msg_exec = 'd0, 
  output reg            msg_chksum_err = 'd0
);

  reg     [7:0] msg_data_cntr, // for FSM end condition only.
                rx_chksum;

  reg     [3:0] rx_extract_cs, rx_extract_ns;

  always @(posedge clk)
  begin
    msg_data <=     (rx_vld)? rx_data:msg_data;

    msg_data_wr <=  (rx_extract_cs == 'd7)? rx_vld:1'b0;
    msg_data_adr <= (rx_extract_cs == 'd0)? 'd0:
                    (rx_extract_cs == 'd7)? msg_data_adr + {7'd0, msg_data_wr} : msg_data_adr;

    case (rx_extract_cs)
    'd4: //RX_TYPE
    begin
      msg_type <= (rx_vld)? rx_data:msg_type;
      rx_chksum <= (rx_vld)? rx_data:rx_chksum;
      msg_exec <= 'd0;
    end
    'd5: //RX_SEQ
    begin
      msg_seq_no <= (rx_vld)? rx_data:msg_seq_no;
      rx_chksum <= rx_chksum + ((rx_vld)? rx_data:8'd0);
      msg_exec <= 'd0;
    end
    'd6: //RX_LEN
    begin
      msg_data_cntr <= (rx_vld)? rx_data:msg_data_cntr;
      msg_data_length <= (rx_vld)? rx_data: msg_data_length;
    
      rx_chksum <= rx_chksum + ((rx_vld)? rx_data:8'd0);
      msg_exec <= 'd0;
    end
    'd7: //RX_DATA
    begin
      msg_data_cntr <= msg_data_cntr + {8{rx_vld & |msg_data_cntr}};

      msg_page        <= (msg_data_wr & msg_data_adr == 'd0)? rx_data:
                                                              msg_page;
      msg_offset      <= (msg_data_wr & msg_data_adr == 'd1)? rx_data:
                                                              msg_offset;
      rx_chksum <= rx_chksum + ((rx_vld)? rx_data:8'd0);
      msg_exec <= 'd0;
    end
    'd8: //RX_CHKSUM
    begin
      msg_chksum <= (rx_vld)? rx_data:msg_chksum;
      msg_chksum_err <= (!rx_vld)? msg_chksum_err:
                        (rx_data != rx_chksum)? 1'b1:1'b0;
      msg_exec <= rx_vld;
    end

    default: //
    begin
      msg_exec <= 'd0;
    end
    endcase
  end

  always @(*)
  begin
    case (rx_extract_cs)
    'd1: 
      rx_extract_ns = (!rx_vld)? 'd1:
                    (rx_data == PREAMBLE[23:16])? 'd2:'d0;
    'd2: 
      rx_extract_ns = (!rx_vld)? 'd2:
                    (rx_data == PREAMBLE[15:08])? 'd3:'d0;
    'd3: 
      rx_extract_ns = (!rx_vld)? 'd3:
                    (rx_data == PREAMBLE[07:00])? 'd4:'d0;
    'd4: // RX_TYPE 
      rx_extract_ns = (!rx_vld)? 'd4: 'd5;
    'd5: // RX_SEQ 
      rx_extract_ns = (!rx_vld)? 'd5: 'd6;
    'd6: // RX_LEN  
      rx_extract_ns = (!rx_vld)? 'd6: 'd7;
    'd7: // RX_DATA 
      rx_extract_ns = (rx_vld & ~|msg_data_cntr[7:1])? 'd8: 'd7;
    'd8: // RX_CHKSUM 
      rx_extract_ns = (!rx_vld)? 'd8: 'd0;

    default: //'d0;
      rx_extract_ns = (rx_vld & rx_data == PREAMBLE[31:24])? 'd1:'d0;
    endcase
  end

  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b)
    begin
      rx_extract_cs <= 'd0;
    end
    else
    begin
      rx_extract_cs <= rx_extract_ns;
    end
  end

endmodule
