//------------------------------------------------------------------------------
// Copyright 2011 (c) Sculpture Networks
//
// Description:  This module serves the video to an 8-bit data interface keeping
//               output data at a constant rate.  Null TS packets are inserted
//               whenever incoming video buffer runs low.
//-----------------------------------------------------------------------------
module rf_vid_server #(
  parameter PARAM_FORCE_NULL = "FALSE"  // in bytes
)(
    input              clk,
    input              rst_b,
    
    //input              vid_clk_edge_sel, //0 - rising edge, 1 - falling edge
    
    //Video Buffer Interface
    input              vid_clk,
    input        [7:0] vid_data,
    input              vid_data_vld,
    
    //Output TS Data Interface
    input              rf_tx_ready,
    output      [7:0]  ts_data_out,
    output             ts_data_vld,
    output             ts_sync,
    
    output             ts_null_out,
    output             vid_buf_empty,
    output reg  [7:0]  vid_drop_cnt,
    output reg  [7:0]  null_insert_cnt
);

`define SRV_ST_COUNT 7
localparam ST_IDLE         = 1,
           ST_SRV_VID      = ST_IDLE << 1,
           ST_NULL_HDR1    = ST_IDLE << 2,
           ST_NULL_HDR2    = ST_IDLE << 3,
           ST_NULL_HDR3    = ST_IDLE << 4,
           ST_NULL_PAYLOAD = ST_IDLE << 5,
           ST_ALIGN47      = ST_IDLE << 6;
           
//localparam ST_READ_IDLE    = 1,
//           ST_READ_ENABLE  = ST_READ_IDLE << 1,
//           ST_WAIT_AFTER   = ST_READ_IDLE << 2;
           
localparam C_TS_PACKET_SIZE = 188;
localparam C_TS_CLK_DET_THRESHOLD = 10;

reg          [`SRV_ST_COUNT-1:0] state;  //state machine variable
//reg                        [2:0] read_state;  //state machine variable
//reg                              ts_data_rd_en_d1, ts_data_rd_en_d2;
//reg                              ts_rd_en_falling;
//wire                             ts_rd_en_rising;
reg                       [7:0]  ts_count, vid_count;
wire                             vid_buf_rd_en;
wire                             vid_buf_wr_en;
reg                              vid_buf_prog_empty;
wire                             vid_buf_prog_full;
wire                      [7:0]  vid_buf_dout;
reg                              vid_buf_in_en;
wire                             ts_packet_start;
reg                              null_packet;
reg                              vid_packet_drop;
wire                             ts_rd_en;
reg                              ts_rd_en_d1, ts_rd_en_d2;
wire                             ts_output_active; //, ts_output_active_d1;
reg                              ts_output_active_vid;
//wire                             ts_link_loss;
//reg                       [7:0]  ts_rd_cnt;
//reg                      [15:0]  sys_clk_cnt;
//reg                              ts_data_rd_en;
reg                       [7:0]  ts_data_out_null;
reg                              null_state;
reg                              force_null;
wire                     [12:0]  vid_buf_data_cnt;

wire force_true;
generate
   if (PARAM_FORCE_NULL == "TRUE") begin
      assign force_true = 1'b1;
   end
   else begin
      assign force_true = 1'b0;
   end
endgenerate
     
//assign ts_rd_en_rising = ts_data_rd_en;
//assign ts_link_loss = ts_output_active_d1 & ~ts_output_active;
assign ts_rd_en = rf_tx_ready; //(vid_clk_edge_sel)? ts_rd_en_falling : ts_rd_en_rising;
assign ts_sync = rf_tx_ready && (state == ST_IDLE);

assign ts_data_vld = rf_tx_ready; //ts_rd_en_d1; //1'b1;
assign ts_null_out = ((state == ST_IDLE) && vid_buf_prog_empty) | null_state;
assign ts_data_out = (ts_null_out)? ts_data_out_null : vid_buf_dout;

assign vid_buf_wr_en = vid_buf_in_en & vid_data_vld;
assign vid_buf_rd_en = ((state == ST_IDLE) && rf_tx_ready & (~vid_buf_prog_empty) & (~force_null)) | 
                       (state == ST_SRV_VID && rf_tx_ready)|
                       (state == ST_ALIGN47 && ~vid_buf_prog_empty);
assign ts_packet_start = (state == ST_IDLE) && ts_rd_en;
assign vid_buf_empty = vid_buf_prog_empty;

//for simulation only
//synthesis translate_off
function [20*8-1:0] state_name(input [`SRV_ST_COUNT-1:0] state);
begin
    case(state)
        ST_IDLE:         state_name = "ST_IDLE";
        ST_ALIGN47:      state_name = "ST_ALIGN47";
        ST_SRV_VID:      state_name = "ST_SRV_VID";
        ST_NULL_HDR1:    state_name = "ST_NULL_HDR1";
        ST_NULL_HDR2:    state_name = "ST_NULL_HDR2";
        ST_NULL_HDR3:    state_name = "ST_NULL_HDR3";
        ST_NULL_PAYLOAD: state_name = "ST_NULL_PAYLOAD";
        default:         state_name = "UNKNOWN";
    endcase
end
endfunction

wire [20*8-1:0] cur_state = state_name(state);
//synthesis translate_on

//always @(posedge vid_clk or posedge rst_b) begin
// Kevin: change rst_b polarity
always @(posedge vid_clk or negedge rst_b) begin
    if (~rst_b) begin
        vid_count <= 8'b0;
        vid_buf_in_en <= 1'b0;
        vid_packet_drop <= 1'b0;
        vid_drop_cnt <= 8'b0;
        ts_output_active_vid <= 1'b0;
    end
    else begin
        vid_packet_drop <= vid_data_vld & (~vid_buf_in_en) & (~|vid_count);
        
        if (vid_packet_drop)
            vid_drop_cnt <= vid_drop_cnt + 1;
            
        //sync to vid clk
        ts_output_active_vid <= ts_output_active;
            
        if (vid_count == C_TS_PACKET_SIZE - 1 && vid_data_vld) begin
            if (~vid_buf_prog_full & ts_output_active_vid)
                vid_buf_in_en <= 1'b1;
            else
                vid_buf_in_en <= 1'b0;
        end
        
        if (vid_data_vld) begin
            if (vid_count < C_TS_PACKET_SIZE - 1)
                vid_count <= vid_count + 1;
            else
                vid_count <= 0;
        end
        
        
    end
end

assign ts_output_active = 1'b1;
/*
always @(posedge clk or negedge rst_b) begin
    if (~rst_b) begin
        ts_data_rd_en_d1 <= 1'b0;
        ts_data_rd_en_d2 <= 1'b0;
        ts_rd_en_falling <= 1'b0;
        //ts_rd_en_rising <= 1'b0;
        ts_output_active <= 1'b0;
        ts_output_active_d1 <= 1'b0;
        ts_rd_cnt <= 8'b0;
        sys_clk_cnt <= 16'b0;
        read_state <= ST_READ_IDLE;
    end
    else begin
        ts_data_rd_en_d1 <= ts_data_rd_en;
        ts_data_rd_en_d2 <= ts_data_rd_en_d1;
        ts_rd_en_falling <= 1'b0;
        //ts_rd_en_rising <= 1'b0;
        //
        if ((~ts_data_rd_en_d1) & ts_data_rd_en_d2)
            ts_rd_en_falling <= 1'b1;
            
        if (ts_data_rd_en_d1 & (~ts_data_rd_en_d2)) begin
            //ts_rd_en_rising <= 1'b1;
            ts_rd_cnt <= (&ts_rd_cnt)?8'd255:(ts_rd_cnt + 1);
        end
            
        sys_clk_cnt <= sys_clk_cnt + 1;
        ts_output_active_d1 <= ts_output_active;
        
        if (&sys_clk_cnt) begin
            ts_rd_cnt <= 8'b0;
            
            if (ts_rd_cnt >= C_TS_CLK_DET_THRESHOLD)
                ts_output_active <= 1'b1;
            else
                ts_output_active <= 1'b0;
        end
        
        ts_data_rd_en <= 1'b0;
        case(read_state)
            ST_READ_IDLE: begin
                if (rf_tx_ready) begin
                    ts_data_rd_en <= 1'b1;
                    read_state <= ST_READ_ENABLE;
                end
            end
            
            ST_READ_ENABLE: begin
                read_state <= ST_WAIT_AFTER;
            end
            
            ST_WAIT_AFTER: begin
                if (~rf_tx_ready) begin
                    read_state <= ST_READ_IDLE;
                end
            end
        endcase
    end
end
*/
 reg [1:0] cur_speed;
//always @(posedge clk or posedge rst_b) begin: state_machine_blk 
// Kevin: change rst_b polarity
always @(posedge clk or negedge rst_b) begin: state_machine_blk

    ts_rd_en_d1 <= ts_rd_en;
    ts_rd_en_d2 <= ts_rd_en_d1;
    
    vid_buf_prog_empty <= (vid_buf_data_cnt < 2*C_TS_PACKET_SIZE);
    
    if (~rst_b) begin
        state            <= ST_IDLE;
        //ts_sync        <= 1'b0;
        null_packet      <= 1'b0;
        null_insert_cnt  <= 8'b0;
        ts_data_out_null <= 8'h47; //sync byte
        ts_count         <= 0;
        force_null       <= 1'b1;
    end
    else begin
        //vid_buf_rd_en <= 1'b0;
        null_packet <= 1'b0;
        
        if (null_packet)
            null_insert_cnt <= null_insert_cnt + 1;
        
        case(state)
            ST_IDLE: begin
                ts_count <= 0;
                ts_data_out_null <= 8'h47; //sync byte
                null_state <= 1'b0;
                
                if (ts_rd_en) begin
                    // force_null artifically slows down the throughput by
                    // forcing the vid server to provide null packets for every
                    // real ts packets available in the buffer vid_buffer.
                    // Throughput is reduced on the receive side via the CPLD
                    // doing a null prediction that will throw away some of the
                    // null packets and lessening some of the null burden to the
                    // Atmel.
                    force_null <= ~force_null & force_true;

                    if (vid_buf_prog_empty | ~ts_output_active | force_null) begin
                        ts_count <= ts_count + 1;
                        state <= ST_NULL_HDR1;
                        ts_data_out_null <= 8'h1f; //sync byte
                        //ts_sync <= 1'b1;
                        null_packet <= 1'b1;
                        null_state  <= 1'b1;
                    end
                    else begin
                        if(vid_buf_dout == 8'h47) begin//validate 0x47 alignment 
                            state <= ST_SRV_VID;
                            ts_count <= ts_count + 1;
                        end
                        else //bad alignment, stay here and wait for next 0x47
                        begin
                            ts_count <= 0;
                            state <= ST_ALIGN47; //force continous ts_sync high
                        end
                    end
                end
            end
            ST_ALIGN47: begin
              // FOUND ISSUE WHERE THE STATE MACHINE GETS STUCK IN THIS STATE
              // WHEN IN ALIGNMENT MODE BUT NO DATA IS AVAILABLE.  SHOULD
              // WE INCLUDE A TIMEOUT TIMER HERE???
              if(ts_rd_en) begin
                if(vid_buf_dout == 8'h47) begin
                  state<=ST_SRV_VID;
                  ts_count<=ts_count +1;  end
                else begin
                  state <= ST_ALIGN47;
                  ts_count<=0;
                     end
                        end
            end
            
            ST_SRV_VID: begin
                if (ts_rd_en) begin
                    //vid_buf_rd_en <= 1'b1;
                    //ts_data_out <= vid_buf_dout;
                    ts_count <= ts_count + 1;
                    
                    //ts_sync <= 1'b0;
                    
                    if (ts_count == C_TS_PACKET_SIZE - 1) begin
                        state <= ST_IDLE;
                        ts_count <= 0;
                        ts_data_out_null <= 8'h47; //sync byte
                    end
                end
            end
            
            ST_NULL_HDR1: begin
                if (ts_rd_en) begin
                    ts_data_out_null <= 8'hff;
                    ts_count <= ts_count + 1;
                    //ts_sync <= 1'b0;
                    state <= ST_NULL_HDR2;
                end
            end
            
            ST_NULL_HDR2: begin
                if (ts_rd_en) begin
                    ts_data_out_null <= 8'h10;
                    ts_count <= ts_count + 1;
                    state <= ST_NULL_HDR3;
                end
            end
            
            ST_NULL_HDR3: begin
                if (ts_rd_en) begin
                    ts_data_out_null <= 8'hff;
                    ts_count <= ts_count + 1;
                    state <= ST_NULL_PAYLOAD;
                end
            end
            
            ST_NULL_PAYLOAD: begin
                if (ts_rd_en) begin
                    ts_data_out_null <= 8'hff;
                    ts_count <= ts_count + 1;
                    
                    if (ts_count == C_TS_PACKET_SIZE - 1) begin
                        state <= ST_IDLE;
                        null_state <= 1'b0;
                        ts_count <= 0;
                        ts_data_out_null <= 8'h47; //sync byte
                    end
                end
            end
            default: begin 
              state <= ST_IDLE;
            end
        endcase
     end
end

cbr_vid_buffer vid_buffer(
	.rst            (~rst_b), // | ~ts_output_active_vid),
	.wr_clk         (vid_clk),
	.rd_clk         (clk),
	.din            (vid_data), // Bus [7 : 0] 
	.wr_en          (vid_buf_wr_en),
	.rd_en          (vid_buf_rd_en),
	.dout           (vid_buf_dout), // Bus [7 : 0] 
	.full           (),
	.almost_full    (),
	.overflow       (),
	.empty          (),
	.almost_empty   (),
	.valid          (),
	.underflow      (),
	.rd_data_count  (vid_buf_data_cnt), // Bus [12 : 0] 
	.wr_data_count  (), // Bus [12 : 0] 
	.prog_full      (vid_buf_prog_full),
	.prog_empty     ()
);

//----------------------------------------------------------------------------//
//                                  Debug                                     //
//----------------------------------------------------------------------------//
wire       [35:0] chipscope_control;
wire      [255:0] chipscope_trig;

//chipscope_icon icon( /* synthesis syn_noprune=1 */
//    .CONTROL0 (chipscope_control)
//);

//chipscope_ila_1024x256 ila( /* synthesis syn_noprune=1 */
//    .CONTROL (chipscope_control),
//    .CLK     (clk),
//    .TRIG0   (chipscope_trig[255:0])
//);
/*
assign chipscope_trig[0] = vid_clk_edge_sel;
assign chipscope_trig[1] = ts_data_rd_en;
assign chipscope_trig[2] = ts_data_vld;
assign chipscope_trig[3] = ts_sync;
assign chipscope_trig[11:4] = ts_data_out;
assign chipscope_trig[12] = vid_data_vld;
assign chipscope_trig[20:13] = vid_data;
assign chipscope_trig[28:21] = vid_drop_cnt;
assign chipscope_trig[36:29] = null_insert_cnt;
assign chipscope_trig[42:37] = state;
assign chipscope_trig[43] = ts_rd_en_falling;
assign chipscope_trig[44] = ts_rd_en_rising;
assign chipscope_trig[52:45] = ts_count;
assign chipscope_trig[60:53] = vid_count;
assign chipscope_trig[61] = vid_buf_rd_en;
assign chipscope_trig[62] = vid_buf_wr_en;
assign chipscope_trig[63] = vid_buf_prog_empty;
assign chipscope_trig[64] = vid_buf_prog_full;
assign chipscope_trig[72:65] = vid_buf_dout;
assign chipscope_trig[73] = vid_buf_in_en;
assign chipscope_trig[74] = ts_packet_start;
assign chipscope_trig[75] = null_packet;
assign chipscope_trig[76] = vid_packet_drop;
assign chipscope_trig[77] = ts_rd_en;
assign chipscope_trig[78] = ts_output_active;
assign chipscope_trig[86:79] = ts_rd_cnt;
assign chipscope_trig[102:87] = sys_clk_cnt;
assign chipscope_trig[103] = rst_b;
assign chipscope_trig[104] = ts_link_loss;
*/
/*
(* mark_debug = "true" *) reg  dbgv__ts_data_vld;
(* mark_debug = "true" *) reg  dbgv__ts_sync;
(* mark_debug = "true" *) reg [7:0] dbgv__ts_data_out;
(* mark_debug = "true" *) reg  dbgv__vid_data_vld;
(* mark_debug = "true" *) reg [7:0] dbgv__vid_data;
(* mark_debug = "true" *) reg [7:0] dbgv__vid_drop_cnt;
(* mark_debug = "true" *) reg [7:0] dbgv__null_insert_cnt;
(* mark_debug = "true" *) reg [6:0] dbgv__state;
(* mark_debug = "true" *) reg [7:0] dbgv__ts_count;
(* mark_debug = "true" *) reg [7:0] dbgv__vid_count;
(* mark_debug = "true" *) reg  dbgv__vid_buf_rd_en;
(* mark_debug = "true" *) reg  dbgv__vid_buf_wr_en;
(* mark_debug = "true" *) reg  dbgv__vid_buf_prog_empty;
(* mark_debug = "true" *) reg  dbgv__vid_buf_prog_full;
(* mark_debug = "true" *) reg [7:0] dbgv__vid_buf_dout;
(* mark_debug = "true" *) reg  dbgv__vid_buf_in_en;
(* mark_debug = "true" *) reg  dbgv__ts_packet_start;
(* mark_debug = "true" *) reg  dbgv__null_packet;
(* mark_debug = "true" *) reg  dbgv__vid_packet_drop;
(* mark_debug = "true" *) reg  dbgv__ts_rd_en;
(* mark_debug = "true" *) reg dbgv__ts_output_active;
(* mark_debug = "true" *) reg  dbgv__rst_b;
(* mark_debug = "true" *) reg [12:0] dbgv__vid_buf_data_cnt;

always @(posedge  clk)
begin
dbgv__ts_data_vld <= ts_data_vld;
dbgv__ts_sync <= ts_sync;
dbgv__ts_data_out <= ts_data_out;
dbgv__vid_data_vld <= vid_data_vld;
dbgv__vid_data <= vid_data;
dbgv__vid_drop_cnt <= vid_drop_cnt;
dbgv__null_insert_cnt <= null_insert_cnt;
dbgv__state <= state;
dbgv__ts_count <= ts_count;
dbgv__vid_count <= vid_count;
dbgv__vid_buf_rd_en <= vid_buf_rd_en;
dbgv__vid_buf_wr_en <= vid_buf_wr_en;
dbgv__vid_buf_prog_empty <= vid_buf_prog_empty;
dbgv__vid_buf_prog_full <= vid_buf_prog_full;
dbgv__vid_buf_dout <= vid_buf_dout;
dbgv__vid_buf_in_en <= vid_buf_in_en;
dbgv__ts_packet_start <= ts_packet_start;
dbgv__null_packet <= null_packet;
dbgv__vid_packet_drop <= vid_packet_drop;
dbgv__ts_rd_en <= ts_rd_en;
dbgv__ts_output_active <= ts_output_active;
dbgv__rst_b <= rst_b;
dbgv__vid_buf_data_cnt <= vid_buf_data_cnt;
end
*/
endmodule
