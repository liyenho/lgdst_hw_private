/*
 *
 */

`timescale 1ns / 10ps
`include "ver_info.v"

module lgdst_rxglue (
  input             clk,
  input             resync_n,  //active low

  //Intf from the 6612
  input             spi0_spck,
  input             spi0_npcs0,
  input             spi0_mosi,
  output            spi0_miso,

  //for debugging
  //output            i2c_sclk1, //for debugging
  input             i2c_sda1,
  output            ad_spi_cs,
  output            ad_spi_sclk,
  inout             ad_spi_sdio,

  //IOs for the TS to the atmel(was spi5 signals in the old design)
  output             ts1_clk,
  output             ts_ce,
  output reg         ts_mosi,
  input              ts_miso,

  //IOs for the TS signal from the ITE9317
  input             ts_clk,
  input             ts_d0,
  input             ts_valid,
  input             ts_sync, //not used
  input             ts_fail  //not used

);

 // Signals for ADRF_brg
 reg  [3:0]    spi0_ck_cnt = 4'd8;
 reg           ad_spi_rw   = 1'b0;
 reg           ad_spi_oe_b = 1'b1;
 reg           spi_rw = 1'b0;

 reg spi5_npcs0=1'b1;
 //asynchronous resync handling
 reg rst_arm;
 reg ts_valid_prelatch; //required to force delay WRT ts_clk
 reg ts_valid_prelatch_d1;
 //following synchronous resync handling
 reg ts_clk_disable;
 reg ts_d0_prelatch; //required to force delay WRT ts_clk

 wire ts_valid_risingedge = ~ts_valid_prelatch_d1 & ts_valid_prelatch;

 always @(negedge ts_clk)
  ts_valid_prelatch <= ts_valid;

 always @(posedge ts_clk )
 begin
  ts_valid_prelatch_d1 <= ts_valid_prelatch;
  if(rst_arm) ts_clk_disable <= 1'b1;
  else if(ts_valid_risingedge)ts_clk_disable <= 1'b0;
 end

 always @(posedge clk)
 begin
  if(!resync_n) rst_arm <= 1'b1;
  else if(ts_valid_risingedge) rst_arm<=1'b0;
 end

 //assigning the TSclk signal to spi_clk  to the atmel
 assign  ts1_clk = (rst_arm)?1'b1:
                   (ts_clk_disable)? 1'b1:
						 (ts_ce) ? 1'b1:
						 ts_clk;

 //assigning the TSce signal to the atmel
 assign ts_ce = spi5_npcs0;
 always @(posedge ts_clk)
 begin
  if(rst_arm) spi5_npcs0 <= 1'b1;
  else if(ts_valid_risingedge) spi5_npcs0 <= 1'b0;
  else if(ts_valid_prelatch)   spi5_npcs0 <= 1'b0;
  else                         spi5_npcs0 <= 1'b1;
 end

 //assigning the TSd0 signal to spi_mosi to the atmel
 always @(negedge ts_clk)
  ts_d0_prelatch <= ts_d0;

 always @(posedge ts_clk)
 begin
  if(rst_arm)
   ts_mosi <= 1'b0;
  else
   ts_mosi <= ts_d0_prelatch;
 end

 //for debugging purpose
 //assign i2c_sclk1 = pattern;
 reg pattern=1'b0;
 always @ (posedge clk/*spi0_spck*/)
 begin
  pattern <= ~pattern;
 end

wire spi_clk;
assign spi_clk = (i2c_sda1)? i2c_sda1 : spi0_spck;

 //assigning the 6612 signals
 assign ad_spi_sdio = (~(ad_spi_oe_b | spi0_npcs0))? spi0_mosi: /*pattern*/1'bz;
 assign spi0_miso = /*pattern*/ad_spi_sdio;
 assign {ad_spi_cs, ad_spi_sclk} = {spi0_npcs0, spi_clk/*spi0_spck*/};

  always @(negedge spi0_spck or posedge spi0_npcs0)
  begin
    if (spi0_npcs0)
      ad_spi_oe_b <= 1'b0;
    else
      ad_spi_oe_b <= ad_spi_rw;
  end

    always @(posedge spi0_spck or posedge spi0_npcs0)
  begin
    if (spi0_npcs0)
    begin
      spi0_ck_cnt <= 4'd8;
      ad_spi_rw <= 1'd0;
		spi_rw <= 1'd0;
    end
    else
    begin
	   spi_rw <= (spi0_ck_cnt==4'd8)? spi0_mosi : spi_rw;
      spi0_ck_cnt <= spi0_ck_cnt + {4{|spi0_ck_cnt}};
      ad_spi_rw <= (~|spi0_ck_cnt[2:1] & spi0_ck_cnt[0])? spi_rw:
                   ad_spi_rw;
    end
  end

endmodule
