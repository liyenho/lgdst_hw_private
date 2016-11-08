//------------------------------------------------------------------------------
// Copyright 2008 (c) Sculpture Networks
//
// Description:  Implements helm control logic.
//------------------------------------------------------------------------------
// clk: System clock
//
// rst_b: System synchronous reset
//------------------------------------------------------------------------------
module helm #(
    parameter REF_CLK_FREQ   = 100000000,  //in Hz
    parameter UART_BAUD_RATE = 115200
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
    
    // Serial port interface
    output            uart_serial_tx,
    input             uart_serial_rx
);

// XST black box declaration
// box_type "black_box"
// synthesis attribute box_type of helm is "black_box"

endmodule
