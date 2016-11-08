/*
 *
 *
 */

`timescale 1ns / 10ps

module baud_gen #(
  parameter         REF_CLK_FREQ = 50000000,    // 50MHz
  parameter         CLK_CNT_BIT = 16,
  parameter         UART_BAUD_RATE = 115200     // i.e., bit width = 8.68us
)(
  input         rst_b,
  input         clk,

  input         rxd_idle,
  input   [2:0] rxd_sync,
  output    reg rxd_htick,
  
  input         txd_en,
  output    reg txd_tick,
  output    reg txd_htick
);
  localparam BAUD_CLK_CNT = REF_CLK_FREQ/UART_BAUD_RATE;

  reg   [CLK_CNT_BIT-1:0]   tx_clk_cntr;
  reg   [CLK_CNT_BIT-1:0]   rx_clk_cntr;

  always @(posedge clk or negedge rst_b)
  begin
    if (~rst_b)
    begin
      tx_clk_cntr <= 'd2;
      txd_tick <= 1'b0;
      txd_htick <= 1'b0;
    end
    else if (~txd_en)
    begin
        tx_clk_cntr <= 'd2;
        txd_tick <= 1'b0;
        txd_htick <= 1'b0;
    end
    else 
    begin
      txd_tick <= ~|tx_clk_cntr; 
      txd_htick <= (tx_clk_cntr == BAUD_CLK_CNT/2)? 1'b1:1'b0;

      if (|tx_clk_cntr)
        tx_clk_cntr <= tx_clk_cntr + {CLK_CNT_BIT{1'b1}};
      else
        tx_clk_cntr <= BAUD_CLK_CNT;
    end
  end

  reg         rxd_start_det = 1'b0;
  reg         rxd_start_glitch = 1'b0;
  reg         rxd_en;
  wire        rxd_rise, rxd_fall;
  wire        rxd_htick_hit, 
              rxd_tick_hit;

  assign rxd_rise = (rxd_sync[2:1] == 2'b01)? 1'b1:1'b0;
  assign rxd_fall = (rxd_sync[2:1] == 2'b10)? 1'b1:1'b0;
  assign rxd_htick_hit = (rx_clk_cntr == BAUD_CLK_CNT/2)? 1'b1:1'b0;
  assign rxd_tick_hit =  ~|rx_clk_cntr;
 
  always @(posedge clk or negedge rst_b)
  begin
    if (!rst_b)
    begin
      rxd_en <= 1'b0;
      rxd_start_det <= 1'b0;
      rx_clk_cntr <= BAUD_CLK_CNT;
      rxd_htick <= 1'b0;
      rxd_start_glitch = 1'b0;
    end
    else
    begin
      if (rxd_tick_hit & (rxd_start_glitch | rxd_idle) )
        rxd_en <= 1'b0;
      else if (~rxd_en & rxd_idle & rxd_fall)
        rxd_en <= 1'b1;

      if (~rxd_en & rxd_idle & rxd_fall)
        rxd_start_det <= 1'b1;
      else if (rxd_htick)
        rxd_start_det <= 1'b0;

      if (|rx_clk_cntr & rxd_en)
        rx_clk_cntr <= rx_clk_cntr + {CLK_CNT_BIT{1'b1}};
      else
        rx_clk_cntr <= BAUD_CLK_CNT;

      if (~rxd_en)
        rxd_start_glitch = 1'b0;
      else if (rxd_start_det & rxd_rise)
        rxd_start_glitch = 1'b1;

      rxd_htick <= rxd_htick_hit & ~rxd_start_glitch;
    end
  end 

endmodule
