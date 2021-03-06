/*
 *
 1.The spi_clk and the 2072_clk are connected to the same pin. Since th protocol for the 2072 is different the pin has to be used as an inout pin
 */

`timescale 1ns / 10ps
`include "ver_info.v"

module lgdst_rxglue (
    input       clk,
	 input       reset,

	 input       spi0_clk,
	 input       spi0_cs,
	 input       spi0_mosi,
	 output      spi0_miso,

	inout       ad_spi_sdio,

	input 		spi_clk,
	input		 spi_cs,
	input		spi_mosi,

	 output reg  ts_sync,
	 output      ts_valid,
	 output      ts_clk,
	 output      ts_d0
);
 reg     		clk_on ;

 //assigning the tsclk signal
 assign ts_clk = (!reset)? 1'b0: ~spi_clk;
 assign ts_valid = (!reset)? 1'b0: (~spi_cs);
 assign ts_d0 = (!reset)? 1'b0: spi_mosi;

 always @ (posedge spi_cs or posedge spi_clk)
 	if (1'b1 == spi_cs)
 	 clk_on <= 1'b0;
 	else if (1'b1 == spi_clk)
 	 clk_on <= 1'b1;
 	else
 	 clk_on <= clk_on;

 always @ (posedge spi_clk)
 begin
  if (1'b0 == clk_on)
  	ts_sync <= 1'b1;
  else  // after 1st spi_clk
   ts_sync <= 1'b0;
 end

 // Signals for ADRF_brg, liyenho
 reg  [3:0]    spi0_ck_cnt = 4'd10;
 reg           ad_spi_rw   = 1'b0;
 reg           ad_spi_oe_b = 1'b1;
 reg           spi_rw = 1'b0;

 //assigning the 6612 signals
 assign ad_spi_sdio = (~(ad_spi_oe_b | spi0_cs))? spi0_mosi: 1'bz;
 assign spi0_miso = ad_spi_sdio;
 assign {ad_spi_cs, ad_spi_sclk} = {spi0_cs, spi0_clk};

  always @(negedge spi0_clk or posedge spi0_cs)
  begin
    if (spi0_cs)
      ad_spi_oe_b <= 1'b0;
    else
      ad_spi_oe_b <= ad_spi_rw;
  end

    always @(posedge spi0_clk or posedge spi0_cs)
  begin
    if (spi0_cs)
    begin
      spi0_ck_cnt <= 4'd10;
      ad_spi_rw <= 1'd0;
		spi_rw <= 1'd0;
    end
    else
    begin
	   spi_rw <= (spi0_ck_cnt==4'd9)? spi0_mosi : spi_rw;
      spi0_ck_cnt <= spi0_ck_cnt + {4{|spi0_ck_cnt}};
      ad_spi_rw <= (~|spi0_ck_cnt[3:1] & spi0_ck_cnt[0])? spi_rw:
                   ad_spi_rw;
    end
  end

endmodule
