//------------------------------------------------------------------------------
// Copyright 2008 (c) Sculpture Networks
//
// Description:  Implements helm control logic.
//------------------------------------------------------------------------------
// clk: System clock
//
// rst_b: System synchronous reset
//
// usr_mem_page: the memory page to write to or read from.  The mem page, offset,
//     and wr_data remain valid and stable until the acknowledge is received.
//
// usr_mem_offset: the memory page to write to or read from.
//
// usr_mem_wr_en: the write enable to the user memory.  The wr_en and rd_en
//     remains asserted until the ack is received.
//
// usr_mem_wr_data: the write data to the user memory.
//
// usr_mem_rd_en: the read enable to the user memory.
//
// usr_mem_rd_data: the read data from the user memory.
//
// usr_mem_ack: the acknowlege from the user memory.  For a memory write, this
//     should be a single-cycle pulse indicating that the data has been written
//     to user memory.  For a memory read, this indicates the "usr_mem_rd_data"
//     is valid for sampling by helm.  This can be a single-cycle pulse.
//------------------------------------------------------------------------------
module helm #(
    parameter REF_CLK_FREQ   = 100000000,  //in Hz
    parameter UART_BAUD_RATE = 115200,
    parameter ACTIVE_TIMEOUT = 1e8   //number of ref_clk cycles
)(
    input             clk,
    input             refclk,
    input             rst_b,
    
    // Register file interface
    output reg  [7:0] usr_mem_page,
    output reg  [7:0] usr_mem_offset,
    output reg        usr_mem_wr_en,
    output reg  [7:0] usr_mem_wr_data,
    output reg        usr_mem_rd_en,
    input       [7:0] usr_mem_rd_data,
    input             usr_mem_ack,
    
    input      [15:0] ack_timeout_lim, //number of clocks to wait for read/write acks (<= 1023)
    output reg        msg_processing,
    output reg        active,
    
    // Serial port interface
    output            uart_serial_tx,
    input             uart_serial_rx,
    output    [7:0]   uart_data8_rx,
    input             uart_data8_rx_vld,
    input             helm_serial_disable
);


localparam UART_CLK_DIV   = REF_CLK_FREQ / UART_BAUD_RATE / 16;

//picoblaze read ports
localparam C_UART_RX_DATA       = 0,
           C_STATUS_REG         = 1,
           C_USR_MEM_RD_DATA    = 3,
           C_INT_BUF_RD_DATA    = 7;
           
//picoblaze write ports
localparam C_UART_TX_DATA       = 0,
           C_USR_MEM_PAGE       = 1,
           C_USR_MEM_OFFSET     = 2,
           C_USR_MEM_WR_DATA    = 3,
           C_USR_MEM_RD_EN      = 4,
           C_USR_MEM_WR_EN      = 5,
           C_INT_BUF_ADDR       = 6,
           C_INT_BUF_WR_DATA    = 7,
           C_START_CMD_PROC     = 250,
           C_SIM_DEBUG_REG      = 251,
           C_END_CMD_PROC       = 252;
           
wire  [7:0] pblz_port_id;
wire        pblz_write_strobe;
wire        pblz_read_strobe;
wire  [7:0] pblz_out_port;
reg   [7:0] pblz_in_port;
wire        pblz_interrupt = 1'b0;
wire        pblz_interrupt_ack;
wire  [9:0] pblz_address;
wire [17:0] pblz_instruction;

wire  [7:0] uart_rx_data_out, uart_rx_data, uart_tx_data;
reg   [7:0] uart_tx_data_in;
reg         uart_rx_read_buffer;
reg         uart_en_16_x_baud;
wire        uart_rx_buffer_data_present, uart_rx_data_valid;
wire        uart_rx_buffer_full;
wire        uart_rx_buffer_half_full;
reg         uart_tx_write_buffer;
wire        uart_tx_buffer_full;
wire        uart_tx_buffer_half_full;
wire        uart_tx_data_valid;
wire        uart_tx_data_read;
wire        uart_int_tx_buffer_full;
wire        uart_int_tx_buffer_write;
wire        uart_rx_transfer;

reg   [6:0] uart_baud_count;
wire        int_buf_valid;
wire        int_buf_full;
wire        int_buf_empty;
wire  [7:0] int_buf_rd_data;
reg   [7:0] int_buf_addr;
reg   [7:0] int_buf_wr_data;
reg         int_buf_wr_en;
reg         int_buf_rd_en;

reg         cmd_proc_start;
reg         cmd_proc_end;
reg   [7:0] cmd_type;
reg         usr_mem_ack_reg;

reg         usr_mem_wr_en_int, usr_mem_wr_en_d1;
reg         usr_mem_rd_en_int, usr_mem_rd_en_d1;
reg   [7:0] usr_mem_rd_data_reg;

reg   [7:0] sim_debug_reg;
reg         sim_debug_strobe;
reg  [15:0] ack_timer;
reg         ack_timed_out;
reg         reset_on_timeout;
wire        uart_rx_full, uart_rx_half_full;
reg  [39:0] active_timer;

//picoblaze input
always @(posedge clk) begin
    case(pblz_port_id)
        C_UART_RX_DATA:
            pblz_in_port <= uart_rx_data_out;
        
        C_USR_MEM_RD_DATA:
            pblz_in_port <= usr_mem_rd_data_reg;
            
        C_STATUS_REG:
            pblz_in_port <= {3'b0, usr_mem_ack_reg, int_buf_full, int_buf_empty,
                             uart_tx_buffer_full, uart_rx_buffer_data_present};
            
        C_INT_BUF_RD_DATA:
            pblz_in_port <= int_buf_rd_data;
            
        default:
            pblz_in_port <= 8'b0;
    endcase
end

//picoblaze output
always @(posedge clk) begin
    if (~rst_b) begin
        uart_tx_write_buffer <= 1'b0;
        //usr_mem_wr_en <= 1'b0;
        int_buf_wr_en <= 1'b0;
        cmd_proc_start <= 1'b0;
        cmd_proc_end <= 1'b0;
        sim_debug_strobe <= 1'b0;
        usr_mem_rd_en_int <= 1'b0;
        usr_mem_wr_en_int <= 1'b0;
        msg_processing <= 1'b0;
    end else begin
        uart_tx_write_buffer <= 1'b0;
        //usr_mem_wr_en <= 1'b0;
        int_buf_wr_en <= 1'b0;
        cmd_proc_start <= 1'b0;
        cmd_proc_end <= 1'b0;
        sim_debug_strobe <= 1'b0;
        
        if (cmd_proc_start)
            msg_processing <= 1'b1;
        else if (cmd_proc_end)
            msg_processing <= 1'b0;
            
        if (pblz_write_strobe) begin
            uart_tx_write_buffer <= 1'b0;
            //usr_mem_wr_en <= 1'b0;
            int_buf_wr_en <= 1'b0;
            cmd_proc_start <= 1'b0;
            cmd_proc_end <= 1'b0;
            sim_debug_strobe <= 1'b0;
            
            case(pblz_port_id)
                C_UART_TX_DATA: begin
                        uart_tx_data_in <= pblz_out_port;
                        uart_tx_write_buffer <= 1'b1;
                    end
                
                C_USR_MEM_PAGE:
                    usr_mem_page <= pblz_out_port;
                    
                C_USR_MEM_OFFSET:
                    usr_mem_offset <= pblz_out_port;
                    
                C_USR_MEM_WR_DATA: begin
                        usr_mem_wr_data <= pblz_out_port;
                        //usr_mem_wr_en <= 1'b1;
                    end
                    
                C_USR_MEM_RD_EN: begin
                        usr_mem_rd_en_int <= pblz_out_port[0];
                    end
                    
                C_USR_MEM_WR_EN: begin
                        usr_mem_wr_en_int <= pblz_out_port[0];
                    end
                    
                C_INT_BUF_ADDR:
                    int_buf_addr <= pblz_out_port;
                    
                C_INT_BUF_WR_DATA: begin
                        int_buf_wr_data <= pblz_out_port;
                        int_buf_wr_en <= 1'b1;
                    end
                    
                C_START_CMD_PROC: begin
                        cmd_type <= pblz_out_port;
                        cmd_proc_start <= 1'b1;
                    end
                    
                C_END_CMD_PROC: begin
                        cmd_proc_end <= 1'b1;
                    end
                
                C_SIM_DEBUG_REG: begin
                        sim_debug_reg <= pblz_out_port;
                        sim_debug_strobe <= 1'b1;
                    end
                    
            endcase
        end
    end
end

//register acknowledge
always @(posedge clk) begin
    if (~rst_b) begin
        usr_mem_ack_reg <= 1'b0;
        usr_mem_wr_en_d1 <= 1'b0;
        usr_mem_rd_en_d1 <= 1'b0;
        usr_mem_wr_en <= 1'b0;
        usr_mem_rd_en <= 1'b0;
        ack_timer <= 16'h0;
    end else begin
        if ((usr_mem_wr_en_int & (~usr_mem_wr_en_d1)) |
            (usr_mem_rd_en_int & (~usr_mem_rd_en_d1))) begin
            usr_mem_ack_reg <= 1'b0;
            usr_mem_wr_en <= usr_mem_wr_en_int;
            usr_mem_rd_en <= usr_mem_rd_en_int;
            ack_timer <= 0;
        end else if (usr_mem_ack | ack_timed_out) begin
            usr_mem_ack_reg <= 1'b1;
            usr_mem_wr_en <= 1'b0;
            usr_mem_rd_en <= 1'b0;
            ack_timer <= 0;
            usr_mem_rd_data_reg <= (usr_mem_ack)? usr_mem_rd_data : 8'hac;
        end
        
        if (usr_mem_rd_en | usr_mem_wr_en) begin
            if (ack_timer < ack_timeout_lim && (|ack_timeout_lim)) begin
                ack_timer <= ack_timer + 1;
            end
        end
        
        ack_timed_out <= (|ack_timeout_lim)? (ack_timer == ack_timeout_lim) : 1'b0;
        
        reset_on_timeout <= ack_timed_out & uart_rx_buffer_full; //assume overflow
        
        usr_mem_wr_en_d1 <= usr_mem_wr_en_int;
        usr_mem_rd_en_d1 <= usr_mem_rd_en_int;
    end
end

//read/write enables
always @(posedge clk) begin
    //usr_mem_wr_en        <= (pblz_port_id == C_USR_MEM_WR_DATA)? pblz_write_strobe : 1'b0;
    uart_rx_read_buffer  <= (pblz_port_id == C_UART_RX_DATA)? pblz_read_strobe : 1'b0;
    //uart_tx_write_buffer <= (pblz_port_id == C_UART_TX_DATA)? pblz_write_strobe : 1'b0;
    //int_buf_wr_en        <= (pblz_port_id == C_INT_BUF_WR_DATA)? pblz_write_strobe : 1'b0;
    int_buf_rd_en        <= (pblz_port_id == C_INT_BUF_RD_DATA)? pblz_read_strobe : 1'b0;
end

//uart baud-rate strobe
always @(posedge refclk) begin
    if (~rst_b) begin
        uart_baud_count <= 'b0;
        uart_en_16_x_baud <= 1'b0;
        active_timer <= 0;
        active <= 1'b0;
    end else begin
        if (uart_baud_count < UART_CLK_DIV - 1) begin
            uart_baud_count <= uart_baud_count + 1;
            uart_en_16_x_baud <= 1'b0;
        end else begin
            uart_baud_count <= 'b0;
            uart_en_16_x_baud <= 1'b1;
        end
        
        if (msg_processing) begin
            active <= 1'b1;
            active_timer <= ACTIVE_TIMEOUT;
        end
        else begin
            active_timer <= active_timer - 1;
            
            if (~|active_timer)
                active <= 1'b0;
        end
    end
end


kcpsm3 processor(
    .address       (pblz_address),
    .instruction   (pblz_instruction),
    .port_id       (pblz_port_id),
    .write_strobe  (pblz_write_strobe),
    .out_port      (pblz_out_port),
    .read_strobe   (pblz_read_strobe),
    .in_port       (pblz_in_port),
    .interrupt     (pblz_interrupt),
    .interrupt_ack (pblz_interrupt_ack),
    .reset         (~rst_b),
    .clk           (clk)
);

helm_prog_rom program(
    .reset       (/* open */),
    .address     (pblz_address),
    .instruction (pblz_instruction),
    .clk         (clk)
);

fifo_fwft_256x8 int_buffer(
	.clk          (clk),
	.din          (int_buf_wr_data), // Bus [7 : 0] 
	.rd_en        (int_buf_rd_en),
	.rst          (~rst_b),
	.wr_en        (int_buf_wr_en),
	.almost_empty (/* open */),
	.almost_full  (/* open */),
	.dout         (int_buf_rd_data), // Bus [7 : 0] 
	.empty        (int_buf_empty),
	.full         (int_buf_full),
	.valid        (int_buf_valid)
);

//fifo_16x8_fwft uart_rx_buffer(
//	.rst    (~rst_b | reset_on_timeout),
//	.wr_clk (refclk),
//	.rd_clk (clk),
//	.din    (uart_rx_data), // Bus [7 : 0] 
//	.wr_en  (uart_rx_transfer & ~helm_serial_disable),
//	.rd_en  (uart_rx_read_buffer),
//	.dout   (uart_rx_data_out), // Bus [7 : 0] 
//	.full   (uart_rx_buffer_full),
//	.empty  (/* open */),
//	.valid  (uart_rx_buffer_data_present)
//);

fifo_fwft_async_2048x8 uart_rx_buffer (
	.rst(~rst_b | reset_on_timeout),
	.wr_clk(refclk),
	.rd_clk(clk),
	.din(uart_rx_data), // Bus [7 : 0] 
	.wr_en(uart_rx_transfer & ~helm_serial_disable),
	.rd_en(uart_rx_read_buffer),
	.dout(uart_rx_data_out), // Bus [7 : 0] 
	.full(),
	.almost_full(uart_rx_buffer_full),
	.empty(),
	.almost_empty(),
	.valid(uart_rx_buffer_data_present));


assign uart_rx_transfer = uart_rx_data_valid & ~uart_rx_buffer_full;
assign uart_data8_rx_vld = uart_rx_transfer & helm_serial_disable;
assign uart_data8_rx     = uart_rx_data;

uart_rx uart_rx_i(
    .serial_in           (uart_serial_rx),
    .data_out            (uart_rx_data),
    .read_buffer         (uart_rx_transfer), //read it out immediately
    .reset_buffer        (~rst_b | reset_on_timeout),
    .en_16_x_baud        (uart_en_16_x_baud),
    .buffer_data_present (uart_rx_data_valid),
    .buffer_full         (uart_rx_full),
    .buffer_half_full    (uart_rx_half_full),
    .clk                 (refclk)
);

fifo_fwft_async_2048x8 uart_tx_buffer(
	.rst    (~rst_b),
	.wr_clk (clk),
	.rd_clk (refclk),
	.din    (uart_tx_data_in), // Bus [7 : 0] 
	.wr_en  (uart_tx_write_buffer),
	.rd_en  (uart_tx_data_read),
	.dout   (uart_tx_data), // Bus [7 : 0] 
	.almost_full   (uart_tx_buffer_full),
	.empty  (/* open */),
	.valid  (uart_tx_data_valid)
);

assign uart_int_tx_buffer_write = uart_tx_data_valid & (~uart_int_tx_buffer_full);
assign uart_tx_data_read = uart_int_tx_buffer_write;

uart_tx uart_tx_i(
    .data_in             (uart_tx_data),
    .write_buffer        (uart_int_tx_buffer_write),
    .reset_buffer        (~rst_b),
    .en_16_x_baud        (uart_en_16_x_baud),
    .serial_out          (uart_serial_tx),
    .buffer_full         (uart_int_tx_buffer_full),
    .buffer_half_full    (/* uart_tx_buffer_half_full */),
    .clk                 (refclk)
);


//debug
wire       [35:0] chipscope_control;
wire      [255:0] chipscope_trig;


//chipscope_icon icon( 
//    .CONTROL0 (chipscope_control)
//);
//
//chipscope_ila_1024x256 ila( 
//    .CONTROL (chipscope_control),
//    .CLK     (clk),
//    .TRIG0   (chipscope_trig[255:0])
//);

//ila_1kx64 ILA_inst (
// .clk(clk), // input clk
// .probe0(chipscope_trig)
//);

/*
assign chipscope_trig[7:0] = usr_mem_page;
assign chipscope_trig[15:8] = usr_mem_offset;
assign chipscope_trig[16] = usr_mem_wr_en;
assign chipscope_trig[24:17] = usr_mem_wr_data;
assign chipscope_trig[25] = usr_mem_rd_en;
assign chipscope_trig[33:26] = usr_mem_rd_data;
assign chipscope_trig[34] = usr_mem_ack;
*/

assign chipscope_trig[34] = 1'b0;
assign chipscope_trig[35] = uart_serial_tx;
assign chipscope_trig[36] = uart_serial_rx;

assign chipscope_trig[44:37] = pblz_port_id;                                       //wire  [7:0] 
assign chipscope_trig[45] = pblz_write_strobe;                                  //wire        
assign chipscope_trig[46] = pblz_read_strobe;                                   //wire        
assign chipscope_trig[54:47] = pblz_out_port;                                      //wire  [7:0] 
assign chipscope_trig[62:55] = pblz_in_port;                                       //reg   [7:0] 
assign chipscope_trig[63] = 1'b0;
assign chipscope_trig[31:0] = active_timer;
assign chipscope_trig[32] = active;
assign chipscope_trig[33] = msg_processing;

//assign chipscope_trig[63] = pblz_interrupt = 1'b0;                              //wire        
//assign chipscope_trig[64] = pblz_interrupt_ack;                                 //wire        
//assign chipscope_trig[74:65] = pblz_address;                                       //wire  [9:0] 
//assign chipscope_trig[33:26] = pblz_instruction;                                   //wire [17:0] 

/*
assign chipscope_trig[70:63] = uart_rx_data_out;
assign chipscope_trig[77:71] = uart_rx_data;
assign chipscope_trig[85:78] = uart_tx_data;       //wire  [7:0] 
assign chipscope_trig[87:86] = uart_tx_data_in;                                    //reg   [7:0] 
assign chipscope_trig[88] = uart_rx_read_buffer;                                //reg         
//assign chipscope_trig[33:26] = uart_en_16_x_baud;                                  //reg         
assign chipscope_trig[89] = uart_rx_buffer_data_present;
assign chipscope_trig[90] = uart_rx_data_valid;    //wire        
assign chipscope_trig[91] = uart_rx_buffer_full;                                //wire        
assign chipscope_trig[92] = uart_rx_buffer_half_full;                           //wire        
assign chipscope_trig[93] = uart_tx_write_buffer;                               //reg         
assign chipscope_trig[94] = uart_tx_buffer_full;                                //wire        
assign chipscope_trig[95] = uart_tx_buffer_half_full;                           //wire        
assign chipscope_trig[96] = uart_tx_data_valid;                                 //wire        
assign chipscope_trig[97] = uart_tx_data_read;                                  //wire        
assign chipscope_trig[98] = uart_int_tx_buffer_full;                            //wire        
assign chipscope_trig[99] = uart_int_tx_buffer_write;                           //wire        
assign chipscope_trig[100] = uart_rx_transfer;                                   //wire        

//assign chipscope_trig[33:26] = uart_baud_count;                                    //reg   [6:0] 
assign chipscope_trig[101] = int_buf_valid;                                      //wire        
assign chipscope_trig[102] = int_buf_full;                                       //wire        
assign chipscope_trig[103] = int_buf_empty;                                      //wire        
assign chipscope_trig[111:104] = int_buf_rd_data;                                    //wire  [7:0] 
assign chipscope_trig[119:112] = int_buf_addr;                                       //reg   [7:0] 
assign chipscope_trig[127:120] = int_buf_wr_data;                                    //reg   [7:0] 
assign chipscope_trig[128] = int_buf_wr_en;                                      //reg         
assign chipscope_trig[129] = int_buf_rd_en;                                      //reg         

assign chipscope_trig[130] = cmd_proc_start;                                     //reg         
assign chipscope_trig[138:131] = cmd_type;                                           //reg   [7:0] 

assign chipscope_trig[139] = usr_mem_ack_reg;                                             //reg         
assign chipscope_trig[140] = usr_mem_wr_en_int;
assign chipscope_trig[141] = usr_mem_wr_en_d1;                                            //reg         
assign chipscope_trig[142] = usr_mem_rd_en_int;
assign chipscope_trig[143] = usr_mem_rd_en_d1;                                            //reg         
assign chipscope_trig[151:144] = usr_mem_rd_data_reg;                                     //reg   [7:0] 
assign chipscope_trig[159:152] = sim_debug_reg;                                         //reg   [7:0] 
assign chipscope_trig[160] = sim_debug_strobe;                                      //reg
assign chipscope_trig[170:161] = ack_timer;                                      //reg
assign chipscope_trig[171] = ack_timed_out;                                      //reg
assign chipscope_trig[172] = cmd_proc_end;
assign chipscope_trig[173] = msg_processing;
assign chipscope_trig[174] = uart_rx_full;
assign chipscope_trig[175] = uart_rx_half_full;

*/
endmodule
