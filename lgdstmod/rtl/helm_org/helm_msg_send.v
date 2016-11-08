//------------------------------------------------------------------------------
// Copyright 2010 (c) Sculpture Networks
//
// Description:  This module encapsulates helm msg into a UDP/IP/Enet frame, and
//               sends it out.
//------------------------------------------------------------------------------
// clk: System clock
//
// rst_b: System synchronous reset
//
//------------------------------------------------------------------------------
module helm_msg_send(
    input             clk,
    input             rst_b,
    
    input      [47:0] dst_mac_addr,
    input      [31:0] dst_ip_addr,
    input      [15:0] dst_port,
    
    input      [31:0] ack_timeout_lim, //number of clocks to wait for read
    
    //msg interface
    input             req_msg_tx,
    output reg        msg_tx_rdy,
    input       [7:0] msg_type,
    input       [7:0] msg_seq_no,
    input       [7:0] msg_page,
    input       [7:0] msg_offset,
    input       [7:0] msg_data_length,
    
    //user mem interface
    output reg        usr_mem_cs,
    output reg        usr_mem_rd_en,
    output reg  [7:0] usr_mem_page,
    output reg  [7:0] usr_mem_offset,
    input       [7:0] usr_mem_data,
    input             usr_mem_ack,
    
    //MAC interface
    output reg        mac_tx_src_rdy_n,
    input             mac_tx_dst_rdy_n,
    output reg        mac_tx_eof_n,
    output reg        mac_tx_sof_n,
    output reg  [7:0] mac_tx_data

);

`define STATE_COUNT 30

localparam ST_IDLE                 = `STATE_COUNT'd1,
           ST_WRITE_DST_MAC        = ST_IDLE << 1,
           ST_WRITE_IP_LENGTH      = ST_IDLE << 2,
           ST_WRITE_IP_IDENT_MSB   = ST_IDLE << 3,
           ST_WRITE_IP_IDENT_LSB   = ST_IDLE << 4,
           ST_WRITE_DST_IP_ADDR    = ST_IDLE << 5,
           ST_INIT_IP_CHECKSUM     = ST_IDLE << 6,
           ST_START_IP_CHECKSUM    = ST_IDLE << 7,
           ST_COMPUTE_IP_CHECKSUM  = ST_IDLE << 8,
           ST_FINISH_IP_CHECKSUM   = ST_IDLE << 9,
           ST_WRITE_IP_CHECKSUM    = ST_IDLE << 10,
           ST_WRITE_DST_PORT       = ST_IDLE << 11,
           ST_WRITE_UDP_LENGTH_MSB = ST_IDLE << 12,
           ST_WRITE_UDP_LENGTH_LSB = ST_IDLE << 13,
           ST_HEADER_WRITE_FINISH  = ST_IDLE << 14,
           ST_SEND_HEADER_START    = ST_IDLE << 15,
           ST_SEND_HEADER          = ST_IDLE << 16,
           
           ST_SEND_MSG_PREAMBLE3   = ST_IDLE << 17,
           ST_SEND_MSG_PREAMBLE2   = ST_IDLE << 18,
           ST_SEND_MSG_PREAMBLE1   = ST_IDLE << 19,
           ST_SEND_MSG_PREAMBLE0   = ST_IDLE << 20,
           
           ST_SEND_MSG_TYPE        = ST_IDLE << 21,
           ST_SEND_MSG_SEQ_NO      = ST_IDLE << 22,
           ST_SEND_MSG_LENGTH      = ST_IDLE << 23,
           ST_SEND_MSG_PAGE        = ST_IDLE << 24,
           ST_SEND_MSG_OFFSET      = ST_IDLE << 25,
           ST_SEND_MSG_DATA_LENGTH = ST_IDLE << 26,
           ST_SEND_BLK_RD_STAT     = ST_IDLE << 27,
           ST_SEND_MSG_CHECKSUM    = ST_IDLE << 28,
           
           ST_SEND_FINISH          = ST_IDLE << 29;
           
localparam C_MSG_PREAMBLE3   = 8'haa,
           C_MSG_PREAMBLE2   = 8'h99,
           C_MSG_PREAMBLE1   = 8'h55,
           C_MSG_PREAMBLE0   = 8'h66;
           
localparam C_MSG_BLK_WRITE   = 8'h00,
           C_MSG_BYTE_WRITE  = 8'h01,
           C_MSG_BLK_READ    = 8'h02,
           C_MSG_BLK_WR_CONF = 8'h80,
           C_MSG_BLK_RD_STAT = 8'h81;
           
// internal signals ////////////////////////////////////////////////////////////
reg  [`STATE_COUNT-1:0] state;  //state machine variable

reg               [5:0] header_addr;
reg               [7:0] header_din;
wire              [7:0] header_dout;
reg                     header_we;
//reg                     payload_buf_rd_en;
//wire             [10:0] payload_buf_data_count;
//wire              [7:0] payload_buf_rd_data;
//wire                    payload_buf_full;
reg              [10:0] byte_count;
reg              [15:0] udp_length;
reg              [15:0] ip_length;
reg              [15:0] ip_ident;
reg              [10:0] payload_length_reg;
reg                     usr_mem_data_valid;
reg              [31:0] checksum;
reg               [15:0] msg_checksum;
wire             [10:0] payload_length;
wire                    data_transferred;
reg              [31:0] ack_timer;
reg                     ack_timed_out;

assign data_transferred = (~mac_tx_src_rdy_n) & (~mac_tx_dst_rdy_n);
assign payload_length = (msg_type == C_MSG_BLK_READ)?  (msg_data_length + 11) : 11;

//for simulation only
//synthesis translate_off
function [30*8-1:0] state_name(input [`STATE_COUNT-1:0] state);
begin
    case(state)
        ST_IDLE:                 state_name = "ST_IDLE";
        ST_WRITE_DST_MAC:        state_name = "ST_WRITE_DST_MAC";
        ST_WRITE_IP_LENGTH:      state_name = "ST_WRITE_IP_LENGTH";
        ST_WRITE_IP_IDENT_MSB:   state_name = "ST_WRITE_IP_IDENT_MSB";
        ST_WRITE_IP_IDENT_LSB:   state_name = "ST_WRITE_IP_IDENT_LSB";
        ST_WRITE_DST_IP_ADDR:    state_name = "ST_WRITE_DST_IP_ADDR";
        ST_INIT_IP_CHECKSUM:     state_name = "ST_INIT_IP_CHECKSUM";
        ST_START_IP_CHECKSUM:    state_name = "ST_START_IP_CHECKSUM";
        ST_COMPUTE_IP_CHECKSUM:  state_name = "ST_COMPUTE_IP_CHECKSUM";
        ST_FINISH_IP_CHECKSUM:   state_name = "ST_FINISH_IP_CHECKSUM";
        ST_WRITE_IP_CHECKSUM:    state_name = "ST_WRITE_IP_CHECKSUM";
        ST_WRITE_DST_PORT:       state_name = "ST_WRITE_DST_PORT";
        ST_WRITE_UDP_LENGTH_MSB: state_name = "ST_WRITE_UDP_LENGTH_MSB";
        ST_WRITE_UDP_LENGTH_LSB: state_name = "ST_WRITE_UDP_LENGTH_LSB";
        ST_HEADER_WRITE_FINISH:  state_name = "ST_HEADER_WRITE_FINISH";
        ST_SEND_HEADER_START:    state_name = "ST_SEND_HEADER_START";
        ST_SEND_HEADER:          state_name = "ST_SEND_HEADER";
        ST_SEND_MSG_PREAMBLE3:   state_name = "ST_SEND_MSG_PREAMBLE3";
        ST_SEND_MSG_PREAMBLE2:   state_name = "ST_SEND_MSG_PREAMBLE2";
        ST_SEND_MSG_PREAMBLE1:   state_name = "ST_SEND_MSG_PREAMBLE1";
        ST_SEND_MSG_PREAMBLE0:   state_name = "ST_SEND_MSG_PREAMBLE0";
        ST_SEND_MSG_TYPE:        state_name = "ST_SEND_MSG_TYPE";
        ST_SEND_MSG_SEQ_NO:      state_name = "ST_SEND_MSG_SEQ_NO";
        ST_SEND_MSG_LENGTH:      state_name = "ST_SEND_MSG_LENGTH";
        ST_SEND_MSG_PAGE:        state_name = "ST_SEND_MSG_PAGE";
        ST_SEND_MSG_OFFSET:      state_name = "ST_SEND_MSG_OFFSET";
        ST_SEND_MSG_DATA_LENGTH: state_name = "ST_SEND_MSG_DATA_LENGTH";
        ST_SEND_BLK_RD_STAT:     state_name = "ST_SEND_BLK_RD_STAT";
        ST_SEND_MSG_CHECKSUM:    state_name = "ST_SEND_MSG_CHECKSUM";
        ST_SEND_FINISH:          state_name = "ST_SEND_FINISH";
        default:                 state_name = "UNKNOWN";
    endcase
end
endfunction

wire [30*8-1:0] cur_state = state_name(state);
//synthesis translate_on

//==============================================================================
//                                 processes                                  //
//==============================================================================
always @(posedge clk) begin: state_machine
    if (~rst_b) begin
        state            <= ST_IDLE;
        mac_tx_src_rdy_n <= 1'b1;
        mac_tx_sof_n     <= 1'b1;
        mac_tx_eof_n     <= 1'b1;
        usr_mem_cs       <= 1'b0;
        usr_mem_rd_en    <= 1'b0;
        msg_tx_rdy       <= 1'b0;
        usr_mem_data_valid  <= 1'b0;
        ip_ident            <= 16'b0;
    end
    else begin
        //mac_tx_src_rdy_n <= 1'b1;
        mac_tx_sof_n     <= 1'b1;
        mac_tx_eof_n     <= 1'b1;
        //usr_mem_rd_en <= 1'b0;
        usr_mem_data_valid <= usr_mem_rd_en;
        
        if (usr_mem_rd_en) begin
            if ((ack_timer < ack_timeout_lim) && (|ack_timeout_lim)) begin
                ack_timer <= ack_timer + 1;
            end
        end
        
        ack_timed_out <= (|ack_timeout_lim)? (ack_timer == ack_timeout_lim) : 1'b0;
        
        case(state)
            ST_IDLE: begin
                header_we <= 1'b0;
                msg_tx_rdy <= 1'b1;
                
                if (req_msg_tx) begin
                    header_we <= 1'b1;
                    header_addr <= 6'b0;
                    state <= ST_WRITE_DST_MAC;
                    byte_count <= 5;
                    header_din <= dst_mac_addr[47:40];
                    
                    udp_length <= payload_length + 8;
                    ip_length <= payload_length + (8 + 20);
                    payload_length_reg <= msg_data_length;
                    msg_tx_rdy <= 1'b0;
                    
                    usr_mem_page <= msg_page;
                    
                end
            end
            
            ST_WRITE_DST_MAC: begin
                header_addr <= header_addr + 1;
                
                if (byte_count == 0) begin
                    state <= ST_WRITE_IP_LENGTH;
                    header_din <= ip_length[15:8];
                    header_addr <= 16;
                end
                else begin
                    byte_count <= byte_count - 1;
                    
                    case(byte_count)
                        5: header_din <= dst_mac_addr[39:32];
                        4: header_din <= dst_mac_addr[31:24];
                        3: header_din <= dst_mac_addr[23:16];
                        2: header_din <= dst_mac_addr[15:8];
                        1: header_din <= dst_mac_addr[7:0];
                    endcase
                end
            end
            
            ST_WRITE_IP_LENGTH: begin
                header_addr <= 17;
                header_din <= ip_length[7:0];
                state <= ST_WRITE_IP_IDENT_MSB;
            end
            
            ST_WRITE_IP_IDENT_MSB: begin
                header_addr <= 18;
                header_din <= ip_ident[15:8];
                state <= ST_WRITE_IP_IDENT_LSB;
            end
            
            ST_WRITE_IP_IDENT_LSB: begin
                header_addr <= 19;
                header_din <= ip_ident[7:0];
                ip_ident <= ip_ident + 1;
                state <= ST_WRITE_DST_IP_ADDR;
                byte_count <= 0;
            end
            
            ST_WRITE_DST_IP_ADDR: begin
                if (byte_count == 4) begin
                    header_addr <= 24;
                    header_din  <= 8'h00;
                    state <= ST_INIT_IP_CHECKSUM;
                end
                else begin
                    header_addr <= 30 + byte_count;
                    byte_count <= byte_count + 1;
                    
                    case(byte_count)
                        0: header_din <= dst_ip_addr[31:24];
                        1: header_din <= dst_ip_addr[23:16];
                        2: header_din <= dst_ip_addr[15:8];
                        3: header_din <= dst_ip_addr[7:0];
                    endcase
                end
            end
            
            ST_INIT_IP_CHECKSUM: begin
                header_addr <= 25;
                header_din  <= 8'h00;
                byte_count <= 0;
                state <= ST_START_IP_CHECKSUM;
            end
            
            ST_START_IP_CHECKSUM: begin
                header_addr <= 14; //beginning of ip header
                byte_count  <= 1;
                header_we   <= 1'b0;
                checksum    <= 'b0;
                state <= ST_COMPUTE_IP_CHECKSUM;
            end
            
            ST_COMPUTE_IP_CHECKSUM: begin
                if (byte_count > 20) begin
                    if (checksum[31:16] != 0) begin //fold the overflow portion back into the sum
                        checksum <= {16'h0, checksum[15:0]} + {16'h0, checksum[31:16]};
                    end
                    else begin
                        header_addr <= 24;
                        header_we <= 1'b1;
                        
                        //flip of final checksum is 0
                        if (checksum[15:0] == 16'hffff) begin
                            header_din     <= 8'hff;
                            checksum[15:0] <= 16'h0000;
                        end
                        else begin
                            header_din  <= ~checksum[15:8];
                        end
                        
                        state <= ST_FINISH_IP_CHECKSUM;
                    end
                end
                else begin
                    header_addr <= 14 + byte_count;
                    byte_count  <= byte_count + 1;
                    
                    if (byte_count[0] == 1'b0) begin
                        checksum <= checksum + {24'h0, header_dout};
                    end
                    else begin
                        checksum <= checksum + {16'h0, header_dout, 8'h0};
                    end
                end
            end
            
            ST_FINISH_IP_CHECKSUM: begin
                header_addr <= 25;
                header_din  <= ~checksum[7:0];
                state <= ST_WRITE_IP_CHECKSUM;
            end
            
            ST_WRITE_IP_CHECKSUM: begin
                header_addr <= 36;
                header_din  <= dst_port[15:8];
                state <= ST_WRITE_DST_PORT;
            end
            
            ST_WRITE_DST_PORT: begin
                header_addr <= 37;
                header_din  <= dst_port[7:0];
                state <= ST_WRITE_UDP_LENGTH_MSB;
            end
            
            ST_WRITE_UDP_LENGTH_MSB: begin
                header_addr <= 38;
                header_din  <= udp_length[15:8];
                state <= ST_WRITE_UDP_LENGTH_LSB;
            end
            
            ST_WRITE_UDP_LENGTH_LSB: begin
                header_addr <= 39;
                header_din  <= udp_length[7:0];
                state <= ST_HEADER_WRITE_FINISH;
            end
            
            ST_HEADER_WRITE_FINISH: begin
                byte_count <= 0;
                header_we <= 1'b0;
                header_addr  <= 0;
                state <= ST_SEND_HEADER_START;
            end
            
            ST_SEND_HEADER_START: begin
                mac_tx_data <= header_dout;
                
                if (data_transferred) begin
                    header_addr  <= header_addr + 1;
                    mac_tx_src_rdy_n <= 1'b1;
                    state <= ST_SEND_HEADER;
                end
                else begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_sof_n <= 1'b0;
                end
            end
            
            ST_SEND_HEADER: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b1;
                    
                    if (byte_count < 40) begin
                        byte_count <= byte_count + 1;
                        header_addr  <= header_addr + 1;
                    end
                    else begin
                        //byte_count <= 0;
                        //usr_mem_offset <= 0;
                        //usr_mem_rd_en <= 1'b1;
                        
                        state <= ST_SEND_MSG_PREAMBLE3;
                        mac_tx_data <= C_MSG_PREAMBLE3;
                        mac_tx_src_rdy_n <= 1'b0;
                    end
                end
                else begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= header_dout;
                end
            end
            
            ST_SEND_MSG_PREAMBLE3: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= C_MSG_PREAMBLE2;
                    state <= ST_SEND_MSG_PREAMBLE2;
                end
            end
            
            ST_SEND_MSG_PREAMBLE2: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= C_MSG_PREAMBLE1;
                    state <= ST_SEND_MSG_PREAMBLE1;
                end

            end
            
            ST_SEND_MSG_PREAMBLE1: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= C_MSG_PREAMBLE0;
                    state <= ST_SEND_MSG_PREAMBLE0;
                end

            end
            
            ST_SEND_MSG_PREAMBLE0: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    
                    if (msg_type == C_MSG_BLK_WRITE) begin
                        mac_tx_data <= C_MSG_BLK_WR_CONF;
                        msg_checksum <= C_MSG_BLK_WR_CONF;
                    end
                    else if (msg_type == C_MSG_BLK_READ)  begin
                        mac_tx_data <= C_MSG_BLK_RD_STAT;
                        msg_checksum <= C_MSG_BLK_RD_STAT;
                    end
                        
                    state <= ST_SEND_MSG_TYPE;
                end
            end
            
            ST_SEND_MSG_TYPE: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= msg_seq_no;
                    msg_checksum <= msg_checksum + msg_seq_no;
                    state <= ST_SEND_MSG_SEQ_NO;
                end
            end
            
            ST_SEND_MSG_SEQ_NO: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    
                    if (msg_type == C_MSG_BLK_WRITE) begin
                        mac_tx_data <= 8'h03; //write confirmation
                        msg_checksum <= msg_checksum + 8'h03;
                    end
                    else if (msg_type == C_MSG_BLK_READ) begin
                        mac_tx_data <= msg_data_length + 3;  //read stat
                        msg_checksum <= msg_checksum + msg_data_length + 3;
                    end
                    
                    state <= ST_SEND_MSG_LENGTH;
                end
            end
            
            ST_SEND_MSG_LENGTH: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= msg_page;
                    msg_checksum <= msg_checksum + msg_page;
                    state <= ST_SEND_MSG_PAGE;
                end
            end
            
            ST_SEND_MSG_PAGE: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= msg_offset;
                    msg_checksum <= msg_checksum + msg_offset;
                    state <= ST_SEND_MSG_OFFSET;
                end
            end
            
            ST_SEND_MSG_OFFSET: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b0;
                    mac_tx_data <= msg_data_length;
                    msg_checksum <= msg_checksum + msg_data_length;
                    state <= ST_SEND_MSG_DATA_LENGTH;
                end
            end
            
            ST_SEND_MSG_DATA_LENGTH: begin
                if (data_transferred) begin
                    if (msg_type == C_MSG_BLK_WRITE || payload_length_reg == 0) begin
                        mac_tx_src_rdy_n <= 1'b0;
                        mac_tx_data <= msg_checksum;
                        mac_tx_eof_n <= 1'b0;
                        state <= ST_SEND_MSG_CHECKSUM;
                    end
                    else if (msg_type == C_MSG_BLK_READ) begin
                        mac_tx_src_rdy_n <= 1'b1;
                        usr_mem_cs <= 1'b1;
                        usr_mem_rd_en <= 1'b1;
                        byte_count <= 0;
                        usr_mem_offset <= 0;
                        ack_timer <= 0;
                        state <= ST_SEND_BLK_RD_STAT;
                    end
                end
            end
            
            ST_SEND_BLK_RD_STAT: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b1;
                    
                    if (byte_count < payload_length_reg - 1) begin
                        usr_mem_rd_en <= 1'b1;
                        ack_timer <= 0;
                        byte_count <= byte_count + 1;
                        usr_mem_offset <= usr_mem_offset + 1;
                    end
                    else begin
                        mac_tx_data <= msg_checksum;
                        mac_tx_eof_n <= 1'b0;
                        mac_tx_src_rdy_n <= 1'b0;
                        usr_mem_cs <= 1'b0;
                        state <= ST_SEND_MSG_CHECKSUM;
                    end
                end
                else begin
                    if (usr_mem_ack | ack_timed_out) begin
                        mac_tx_data <= (usr_mem_ack)? usr_mem_data : 8'hac;
                        mac_tx_src_rdy_n <= 1'b0;
                        usr_mem_rd_en <= 1'b0;
                        ack_timer <= 0;
                        
                        msg_checksum <= msg_checksum + ((usr_mem_ack)? usr_mem_data : 8'hac);
                    end
                end
            end
            
            ST_SEND_MSG_CHECKSUM: begin
                if (data_transferred) begin
                    mac_tx_src_rdy_n <= 1'b1;
                    state <= ST_SEND_FINISH;
                end
            end
            
            ST_SEND_FINISH: begin
                state <= ST_IDLE;
            end
            
            default: begin
                state <= ST_IDLE;
            end
        endcase
    end
end

udp_header_mem header_buf(
    .clk (clk),
    .we  (header_we),
    .a   (header_addr),
    .d   (header_din),
    .spo (header_dout)
);

//----------------------------------------------------------------------------//
//                                  Debug                                     //
//----------------------------------------------------------------------------//
wire       [35:0] chipscope_control;
//wire      [255:0] chipscope_trig;

//chipscope_icon icon(
//    .CONTROL0 (chipscope_control)
//);
//
//chipscope_ila_1024x256 ila(
//    .CONTROL (chipscope_control),
//    .CLK     (clk),
//    .TRIG0   (chipscope_trig[255:0])
//);

(* mark_debug = "true" *)
wire      [63:0] chipscope_trig;
//ila_1kx64 ILA_inst (
//  .clk(clk), // input clk
//.probe0(chipscope_trig)
//);

assign chipscope_trig[0] = req_msg_tx;
assign chipscope_trig[1] = mac_tx_src_rdy_n;
assign chipscope_trig[2] = mac_tx_dst_rdy_n;
assign chipscope_trig[3] = mac_tx_eof_n;
assign chipscope_trig[4] = mac_tx_sof_n;
assign chipscope_trig[12:5] = mac_tx_data;

assign chipscope_trig[42:13] = state;

assign chipscope_trig[43] = msg_tx_rdy;
assign chipscope_trig[59:44] = ack_timer[15:0];
//assign chipscope_trig[59:52] = msg_seq_no;
assign chipscope_trig[60] = usr_mem_rd_en;
assign chipscope_trig[61] = usr_mem_ack;
assign chipscope_trig[62] = ack_timed_out;
assign chipscope_trig[63] = 0;


//assign chipscope_trig[67:60] = msg_page;
//assign chipscope_trig[75:68] = msg_offset;
//assign chipscope_trig[83:76] = msg_data_length;
//
//assign chipscope_trig[84] = usr_mem_rd_en;
//assign chipscope_trig[92:85] = usr_mem_page;
//assign chipscope_trig[100:93] = usr_mem_offset;
//assign chipscope_trig[108:101] = usr_mem_data;
//
//assign chipscope_trig[109] = data_transferred;
//assign chipscope_trig[120:110] = payload_length_reg;
//assign chipscope_trig[131:121] = byte_count;
//assign chipscope_trig[132] = usr_mem_ack;

`undef STATE_COUNT
endmodule

