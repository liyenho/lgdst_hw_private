//------------------------------------------------------------------------------
// Copyright 2010 (c) Sculpture Networks
//
// Description:  This module receives a helm msg via UDP/IP/Enet frame, extracts
//               and executes the message.
//------------------------------------------------------------------------------
// clk: System clock
//
// rst_b: System synchronous reset
//
//------------------------------------------------------------------------------
module helm_msg_recv(
    input             clk,
    input             rst_b,
    
    input      [31:0] listened_ip_addr1,
    input      [31:0] listened_ip_addr2,
    input      [15:0] listened_port_helm,
    input      [15:0] listened_port_udp,
    
    input       [3:0] mac_rx_fifo_status,
    output            mac_rx_dst_rdy_n,
    input             mac_rx_src_rdy_n,
    input             mac_rx_eof_n,
    input             mac_rx_sof_n,
    input       [7:0] mac_rx_data,
    
    //msg buffer
    output reg        msg_mem_wr_en,
    output reg        msg_mem_rd_en,
    output reg [10:0] msg_mem_addr,
    output reg  [7:0] msg_mem_wr_data,
    input       [7:0] msg_mem_rd_data,
    
    output reg        helm_ready,
    output reg        msg_processing,
    output reg        msg_dropped,
    
    //msg interface
    output reg        req_msg_tx,
    input             msg_tx_rdy,
    output reg  [7:0] msg_type,
    output reg  [7:0] msg_seq_no,
    output reg  [7:0] msg_page,
    output reg  [7:0] msg_offset,
    output reg  [7:0] msg_data_length,
    output reg [15:0] rx_src_port,
    
    //user mem interface
    output reg        usr_mem_cs,
    output reg        usr_mem_rd_en,
    output reg        usr_mem_wr_en,
    output reg  [7:0] usr_mem_page,
    output reg  [7:0] usr_mem_offset,
    output reg  [7:0] usr_mem_wr_data,
    input       [7:0] usr_mem_rd_data,
    input             usr_mem_ack,
    
    //rx udp payload
    input             udp_payload_wr_ok,
    output reg        udp_payload_wr_en,
    output reg  [7:0] udp_payload_wr_data,
    output reg [15:0] udp_payload_length,
    output reg        udp_payload_sof,
    output reg        udp_payload_eof
);

`define UMR_STATE_COUNT 22

localparam ST_IDLE             = 0,
           ST_CHECK_TYPE1      = 1,
           ST_CHECK_TYPE0      = 2,
           ST_CHECK_PROTOCOL   = 3,
           ST_CHECK_IP3        = 4,
           ST_CHECK_IP2        = 5,
           ST_CHECK_IP1        = 6,
           ST_CHECK_IP0        = 7,
           ST_SRC_PORT1        = 8,
           ST_SRC_PORT0        = 9,
           ST_CHECK_PORT1      = 10,
           ST_CHECK_PORT0      = 11,
           ST_DROP_FRAME       = 12,
           ST_PROCESS_MSG      = 13,
           ST_UDP_DECAP        = 14,
           ST_BUFFER_MSG_DATA  = 15,
           ST_MSG_RX_DONE      = 16,
           ST_PROC_BLK_WR_MSG  = 17,
           ST_BLK_WR_MSG_WAIT  = 18,
           ST_PROC_BLK_RD_MSG  = 19,
           ST_BLK_RD_MSG_WAIT  = 20,
           ST_PROC_BYTE_WR_MSG = 21;
           
localparam C_MSG_PREAMBLE3   = 8'haa,
           C_MSG_PREAMBLE2   = 8'h99,
           C_MSG_PREAMBLE1   = 8'h55,
           C_MSG_PREAMBLE0   = 8'h66;
           
localparam C_MSG_BLK_WRITE   = 8'h00,
           C_MSG_BYTE_WRITE  = 8'h01,
           C_MSG_BLK_READ    = 8'h02,
           C_MSG_BLK_WR_VER  = 8'h03,
           C_MSG_BLK_WR_CONF = 8'h80,
           C_MSG_BLK_RD_STAT = 8'h81;
           
// internal signals ////////////////////////////////////////////////////////////
reg  [`UMR_STATE_COUNT-1:0] state;  //state machine variable

wire                    data_transferred;
reg              [10:0] byte_count;
reg              [15:0] msg_checksum;
reg               [7:0] msg_total_len;
reg              [10:0] msg_mem_addr_d1;
reg                     msg_mem_data_valid;
reg              [15:0] udp_length;
//wire             [15:0] udp_payload_length;
reg                     msg_valid;
reg                     msg_tx_rdy_d1;
reg              [31:0] rx_dst_ip;
reg              [15:0] rx_dst_port;

//do not block frame transfer
assign mac_rx_dst_rdy_n = mac_rx_src_rdy_n; //1'b0;
assign data_transferred = (~mac_rx_src_rdy_n) & (~mac_rx_dst_rdy_n);
//assign udp_payload_length = udp_length - 8;  //subtract udp header

//for simulation only
//synthesis translate_off
function [20*8-1:0] state_name(input [`UMR_STATE_COUNT-1:0] state);
begin
    case(state)
        ST_IDLE:             state_name = "ST_IDLE";
        ST_CHECK_TYPE1:      state_name = "ST_CHECK_TYPE1";
        ST_CHECK_TYPE0:      state_name = "ST_CHECK_TYPE0";
        ST_CHECK_PROTOCOL:   state_name = "ST_CHECK_PROTOCOL";
        ST_CHECK_IP3:        state_name = "ST_CHECK_IP3";
        ST_CHECK_IP2:        state_name = "ST_CHECK_IP2";
        ST_CHECK_IP1:        state_name = "ST_CHECK_IP1";
        ST_CHECK_IP0:        state_name = "ST_CHECK_IP0";
        ST_SRC_PORT1:        state_name = "ST_SRC_PORT1";
        ST_SRC_PORT0:        state_name = "ST_SRC_PORT0";
        ST_CHECK_PORT1:      state_name = "ST_CHECK_PORT1";
        ST_CHECK_PORT0:      state_name = "ST_CHECK_PORT0";
        ST_DROP_FRAME:       state_name = "ST_DROP_FRAME";
        ST_PROCESS_MSG:      state_name = "ST_PROCESS_MSG";
        ST_UDP_DECAP:        state_name = "ST_UDP_DECAP";
        ST_BUFFER_MSG_DATA:  state_name = "ST_BUFFER_MSG_DATA";
        ST_MSG_RX_DONE:      state_name = "ST_MSG_RX_DONE";
        ST_PROC_BLK_WR_MSG:  state_name = "ST_PROC_BLK_WR_MSG";
        ST_BLK_WR_MSG_WAIT:  state_name = "ST_BLK_WR_MSG_WAIT";
        ST_PROC_BLK_RD_MSG:  state_name = "ST_PROC_BLK_RD_MSG";
        ST_BLK_RD_MSG_WAIT:  state_name = "ST_BLK_RD_MSG_WAIT";
        ST_PROC_BYTE_WR_MSG: state_name = "ST_PROC_BYTE_WR_MSG";
        default:             state_name = "UNKNOWN";
    endcase
end
endfunction

wire [20*8-1:0] cur_state = state_name(state);
//synthesis translate_on

//==============================================================================
//                                 processes                                  //
//==============================================================================
always @(posedge clk) begin: state_machine
    if (~rst_b) begin
        state            <= ST_IDLE;
        msg_mem_wr_en   <= 1'b0;
        msg_mem_data_valid <= 1'b0;
        msg_mem_rd_en <= 1'b0;
        req_msg_tx <= 1'b0;
        usr_mem_cs <= 1'b0;
        usr_mem_wr_en <= 1'b0;
        usr_mem_rd_en <= 1'b0;
        msg_processing <= 1'b0;
        msg_tx_rdy_d1 <= 1'b0;
        helm_ready <= 1'b1;
        msg_dropped <= 1'b0;
        udp_payload_wr_en <= 1'b0;
        udp_payload_sof <= 1'b0;
        udp_payload_eof <= 1'b0;
    end
    else begin
        msg_mem_wr_en <= 1'b0;
        msg_mem_rd_en <= 1'b0;
        msg_mem_data_valid <= msg_mem_rd_en;
        msg_mem_addr_d1 <= msg_mem_addr;
        req_msg_tx <= 1'b0;
        usr_mem_cs <= 1'b0;
        usr_mem_wr_en <= 1'b0;
        usr_mem_rd_en <= 1'b0;
        msg_tx_rdy_d1 <= msg_tx_rdy;
        msg_dropped <= 1'b0;
        udp_payload_wr_en <= 1'b0;
        udp_payload_sof <= 1'b0;
        udp_payload_eof <= 1'b0;
        
        case(state)
            ST_IDLE: begin
                msg_valid <= 1'b0;
                msg_processing <= 1'b0;
                helm_ready <= 1'b1;
                
                if (~mac_rx_sof_n) begin
                    msg_processing <= 1'b1;
                    helm_ready <= 1'b0;
                    
                    if (msg_tx_rdy) //process frame only when tx is ready
                        state <= ST_CHECK_TYPE1;
                    else
                        state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_TYPE1: begin
                if (byte_count == 12 && data_transferred) begin
                    if (mac_rx_data == 8'h08)
                        state <= ST_CHECK_TYPE0;
                    else
                        state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_TYPE0: begin
                if (byte_count == 13 && data_transferred) begin
                    if (mac_rx_data == 8'h00)
                        state <= ST_CHECK_PROTOCOL;
                    else
                        state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_PROTOCOL: begin
                if (byte_count == 23 && data_transferred) begin
                    if (mac_rx_data == 8'h11)  //UDP
                        state <= ST_CHECK_IP3;
                    else
                        state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_IP3: begin
                if (byte_count == 30 && data_transferred) begin
                    rx_dst_ip[31:24] <= mac_rx_data;
                    state <= ST_CHECK_IP2;
                    
                    //if (mac_rx_data == listened_ip_addr[31:24])
                    //    state <= ST_CHECK_IP2;
                    //else
                    //    state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_IP2: begin
                if (byte_count == 31 && data_transferred) begin
                    rx_dst_ip[23:16] <= mac_rx_data;
                    state <= ST_CHECK_IP1;
                    
                    //if (mac_rx_data == listened_ip_addr[23:16])
                    //    state <= ST_CHECK_IP1;
                    //else
                    //    state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_IP1: begin
                if (byte_count == 32 && data_transferred) begin
                    rx_dst_ip[15:8] <= mac_rx_data;
                    state <= ST_CHECK_IP0;
                    
                    //if (mac_rx_data == listened_ip_addr[15:8])
                    //    state <= ST_CHECK_IP0;
                    //else
                    //    state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_IP0: begin
                if (byte_count == 33 && data_transferred) begin
                    rx_dst_ip[7:0] <= mac_rx_data;
                    state <= ST_SRC_PORT1;
                    
                    //if (mac_rx_data == listened_ip_addr[7:0])
                    //    state <= ST_CHECK_PORT1;
                    //else
                    //    state <= ST_DROP_FRAME;
                end
            end
            
            ST_SRC_PORT1: begin
                if (byte_count == 34 && data_transferred) begin
                    rx_src_port[15:8] <= mac_rx_data;
                    state <= ST_SRC_PORT0;
                end
            end
            
            ST_SRC_PORT0: begin
                if (byte_count == 35 && data_transferred) begin
                    rx_src_port[7:0] <= mac_rx_data;
                    state <= ST_CHECK_PORT1;
                end
            end
            
            ST_CHECK_PORT1: begin
                if ((rx_dst_ip != listened_ip_addr1) && (rx_dst_ip != listened_ip_addr2))
                    state <= ST_DROP_FRAME;
                else if (byte_count == 36 && data_transferred) begin
                    rx_dst_port[15:8] <= mac_rx_data;
                    state <= ST_CHECK_PORT0;
                    
                    //if (mac_rx_data == listened_port_helm[15:8])
                    //    state <= ST_CHECK_PORT0;
                    //else
                    //    state <= ST_DROP_FRAME;
                end
            end
            
            ST_CHECK_PORT0: begin
                if (byte_count == 37 && data_transferred) begin
                    rx_dst_port[7:0] <= mac_rx_data;
                    state <= ST_PROCESS_MSG;
                    
                    //if (mac_rx_data == listened_port_helm[7:0]) begin
                    //    state <= ST_PROCESS_MSG;
                    //    //data_buf_addr <= 11'h7ff; //to get 0 first time
                    //end
                    //else
                    //    state <= ST_DROP_FRAME;
                end
            end
            
            ST_DROP_FRAME: begin
                if (~mac_rx_eof_n) begin
                    state <= ST_IDLE;
                    msg_dropped <= 1'b1;
                end
            end
            
            ST_PROCESS_MSG: begin
                if ((rx_dst_port != listened_port_helm) &&
                    (rx_dst_port != listened_port_udp))
                    state <= ST_DROP_FRAME;
                else if (data_transferred) begin
                    case(byte_count)
                        38: begin
                            udp_length[15:8] <= mac_rx_data;
                        end
                        
                        39: begin
                            udp_length[7:0] <= mac_rx_data;
                        end
                        
                        40: begin
                            udp_payload_length <= udp_length - 8;
                            
                            if (rx_dst_port == listened_port_udp)
                                state <= ST_UDP_DECAP;
                        end
                        
                        42: begin
                            if (mac_rx_data != C_MSG_PREAMBLE3)
                                state <= ST_DROP_FRAME;
                        end
                        
                        43: begin
                            if (mac_rx_data != C_MSG_PREAMBLE2)
                                state <= ST_DROP_FRAME;
                        end
                        
                        44: begin
                            if (mac_rx_data != C_MSG_PREAMBLE1)
                                state <= ST_DROP_FRAME;
                        end
                        
                        45: begin
                            if (mac_rx_data != C_MSG_PREAMBLE0)
                                state <= ST_DROP_FRAME;
                        end
                        
                        46: begin //type
                            msg_type <= mac_rx_data;
                            msg_checksum <= mac_rx_data;
                        end
                        
                        47: begin
                            msg_seq_no <= mac_rx_data;
                            msg_checksum <= msg_checksum + mac_rx_data;
                        end
                        
                        48: begin //mac_rx_data = length field
                            msg_total_len <= mac_rx_data;
                            msg_checksum <= msg_checksum + mac_rx_data;
                            msg_mem_addr <= 11'h7ff;
                            state <= ST_BUFFER_MSG_DATA;
                        end
                    endcase
                end
                
                //frame ends prematurely, back to idle
                if (~mac_rx_eof_n) begin
                    state <= ST_IDLE;
                end
            end
            
            ST_UDP_DECAP: begin
                if (byte_count >= 42 && (byte_count - 41 <= udp_payload_length)) begin
                    if (udp_payload_wr_ok)
                        udp_payload_wr_en <= data_transferred;
                    else
                        state <= ST_DROP_FRAME;
                        
                    udp_payload_wr_data <= mac_rx_data;
                end
                
                if (udp_payload_wr_ok && data_transferred && byte_count == 42)
                    udp_payload_sof <= 1'b1;
                
                if (~mac_rx_eof_n) begin
                    state <= ST_IDLE;
                    udp_payload_eof <= 1'b1;
                end
            end
            
            ST_BUFFER_MSG_DATA: begin //keep data in temp mem while checking checksum
                if (byte_count >= 49 && (byte_count - 41 <= udp_payload_length)) begin
                    msg_mem_wr_en <= data_transferred;
                    msg_mem_wr_data <= mac_rx_data;
                    
                    //msg_checksum <= msg_checksum + mac_rx_data;
                    
                    if (data_transferred) begin
                        msg_checksum <= msg_checksum + mac_rx_data;
                        msg_mem_addr <= msg_mem_addr + 1;
                        
                        if (byte_count - 41 == udp_payload_length) begin //end of msg
                            if (byte_count - 49 == msg_total_len &&
                                msg_checksum[7:0] == mac_rx_data)
                                msg_valid <= 1'b1;
                            else
                                msg_valid <= 1'b0;
                        end
                    end
                end
                
                if (~mac_rx_eof_n) begin
                    state <= ST_MSG_RX_DONE;
                end
            end
            
            ST_MSG_RX_DONE: begin
                if (msg_valid) begin
                    case(msg_type)
                        C_MSG_BLK_WRITE,
                        C_MSG_BLK_WR_VER: begin
                            msg_mem_addr <= 0;
                            msg_mem_rd_en <= 1'b1;
                            state <= ST_PROC_BLK_WR_MSG;
                        end
                        
                        C_MSG_BYTE_WRITE: begin
                            msg_mem_addr <= 0;
                            msg_mem_rd_en <= 1'b1;
                            state <= ST_PROC_BYTE_WR_MSG;
                        end
                        
                        C_MSG_BLK_READ: begin
                            msg_mem_addr <= 0;
                            msg_mem_rd_en <= 1'b1;
                            state <= ST_PROC_BLK_RD_MSG;
                        end
                            
                        default: begin
                            state <= ST_IDLE; //skip frame processing
                        end
                    endcase
                end
                else begin
                    state <= ST_IDLE; //skip frame processing
                end
            end
            
            ST_PROC_BLK_WR_MSG: begin
                if (msg_mem_addr < msg_total_len) begin
                    msg_mem_addr <= msg_mem_addr + 1;
                    msg_mem_rd_en <= 1'b1;
                end
                
                if (msg_mem_data_valid) begin
                    case(msg_mem_addr_d1)
                        0: begin //page
                            msg_page <= msg_mem_rd_data;
                        end
                        
                        1: begin //offset
                            msg_offset <= msg_mem_rd_data;
                            usr_mem_offset <= msg_mem_rd_data - 1;
                        end
                        
                        2: begin //data length
                            msg_data_length <= msg_mem_rd_data;
                        end
                        
                        default: begin //write data
                            if (msg_mem_addr_d1 < msg_data_length + 3) begin
                                usr_mem_cs     <= 1'b1;
                                usr_mem_wr_en  <= 1'b1;
                                usr_mem_page   <= msg_page;
                                usr_mem_offset <= usr_mem_offset + 1;
                                usr_mem_wr_data   <= msg_mem_rd_data;
                            end
                            else begin
                                state <= ST_BLK_WR_MSG_WAIT;
                                msg_processing <= 1'b0;
                            end
                        end
                    endcase
                end
            end
            
            ST_BLK_WR_MSG_WAIT: begin
                //use msg_tx_rdy_d1 to prevent asserting req_msg_tx when msg tx is done
                if (usr_mem_ack == 1'b1 && msg_tx_rdy_d1 == 1'b1) begin //write completed
                    req_msg_tx <= 1'b1;
                    
                    if (msg_type == C_MSG_BLK_WR_VER) begin
                        state <= ST_BLK_RD_MSG_WAIT;
                        msg_type <= C_MSG_BLK_READ; //request a block read tx
                    end
                end
                
                if (msg_tx_rdy == 1'b1 && msg_tx_rdy_d1 == 1'b0) begin //request done
                    state <= ST_IDLE;
                end
            end
            
            ST_PROC_BYTE_WR_MSG: begin
                if (msg_mem_addr < msg_total_len) begin
                    msg_mem_addr <= msg_mem_addr + 1;
                    msg_mem_rd_en <= 1'b1;
                end
                
                if (msg_mem_data_valid) begin
                    case(msg_mem_addr_d1)
                        0: begin //page
                            usr_mem_page <= msg_mem_rd_data;
                        end
                        
                        1: begin //offset
                            usr_mem_offset <= msg_mem_rd_data;
                            usr_mem_cs <= 1'b1;
                            usr_mem_rd_en <= 1'b1;
                        end
                        
                        2: begin //byte value
                            usr_mem_cs <= 1'b1;
                            usr_mem_wr_data <= msg_mem_rd_data;
                        end
                        
                        3: begin //byte mask
                            state <= ST_IDLE;
                            usr_mem_cs <= 1'b1;
                            usr_mem_wr_en <= 1'b1;
                            usr_mem_wr_data <= (usr_mem_wr_data & msg_mem_rd_data) | //RMW operation
                                               (usr_mem_rd_data & (~msg_mem_rd_data));
                        end
                    endcase
                end
            end
            
            ST_PROC_BLK_RD_MSG: begin
                if (msg_mem_addr < msg_total_len) begin
                    msg_mem_addr <= msg_mem_addr + 1;
                    msg_mem_rd_en <= 1'b1;
                end
                
                if (msg_mem_data_valid) begin
                    case(msg_mem_addr_d1)
                        0: begin //page
                            msg_page <= msg_mem_rd_data;
                        end
                        
                        1: begin //offset
                            msg_offset <= msg_mem_rd_data;
                        end
                        
                        2: begin //data length
                            msg_data_length <= msg_mem_rd_data;
                            req_msg_tx <= 1'b1;
                            state <= ST_BLK_RD_MSG_WAIT;
                            msg_processing <= 1'b0;
                        end
                        
                        default: begin //do nothing
                        end
                    endcase
                end
            end
            
            ST_BLK_RD_MSG_WAIT: begin
                if (msg_tx_rdy == 1'b1 && msg_tx_rdy_d1 == 1'b0) begin //request done
                    state <= ST_IDLE;
                end
            end
            
            default: begin
                state <= ST_IDLE;
            end
        endcase
    end
end

always @(posedge clk) begin: byte_count_blk
    if (~rst_b) begin
        byte_count <= 'b0;
    end
    else begin
        if (~mac_rx_eof_n)
            byte_count <= 'b0;
        else if (data_transferred)
            byte_count <= byte_count + 1;
    end
end

//----------------------------------------------------------------------------//
//                                  Debug                                     //
//----------------------------------------------------------------------------//
wire       [35:0] chipscope_control;
//wire      [127:0] chipscope_trig;

//chipscope_icon icon(
//    .CONTROL0 (chipscope_control)
//);
//
//chipscope_ila_1024x128 ila(
//    .CONTROL (chipscope_control),
//    .CLK     (clk),
//    .TRIG0   (chipscope_trig[127:0])
//);

(* mark_debug = "true" *)
wire      [63:0] chipscope_trig;
//ila_1kx64 ILA_inst (
//  .clk(clk), // input clk
//.probe0(chipscope_trig)
//);

assign chipscope_trig[0] = req_msg_tx;
assign chipscope_trig[1] = mac_rx_src_rdy_n;
assign chipscope_trig[2] = mac_rx_dst_rdy_n;
assign chipscope_trig[3] = mac_rx_eof_n;
assign chipscope_trig[4] = mac_rx_sof_n;
assign chipscope_trig[12:5] = mac_rx_data;

assign chipscope_trig[31:13] = state;

assign chipscope_trig[32] = msg_tx_rdy;
assign chipscope_trig[33] = msg_processing;
assign chipscope_trig[34] = usr_mem_ack;
assign chipscope_trig[35] = usr_mem_wr_en;
assign chipscope_trig[36] = msg_valid;

assign chipscope_trig[51:44] = msg_type;
assign chipscope_trig[59:52] = msg_seq_no;
assign chipscope_trig[63:60] = 0;

//assign chipscope_trig[67:60] = msg_page;
//assign chipscope_trig[75:68] = msg_offset;
//assign chipscope_trig[83:76] = msg_data_length;
//
//assign chipscope_trig[84] = usr_mem_rd_en;
//assign chipscope_trig[92:85] = usr_mem_page;
//assign chipscope_trig[100:93] = usr_mem_offset;
//assign chipscope_trig[108:101] = usr_mem_wr_data;
//
//assign chipscope_trig[109] = data_transferred;
//assign chipscope_trig[120:110] = byte_count;
//assign chipscope_trig[121] = rst_b;

endmodule

