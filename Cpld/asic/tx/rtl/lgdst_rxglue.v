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
 reg     		spi_ck_cnt ;
 reg			spi_mosi_1clk = 1'b0,
 					spi_clk_1clk = 1'b0;
 //assigning the tsclk signal
 assign ts_clk = (!reset)? 1'b0: /*spi_clk*/spi_clk_1clk;
 assign ts_valid = (!reset)? 1'b0: (~spi_cs);
 assign ts_d0 = (!reset)? 1'b0: /*spi_mosi*/spi_mosi_1clk;

 always @ (negedge spi_clk or negedge reset)
 begin
  if (!reset)
	ts_sync <= 1'b0;
  else
  begin
   //if (1'b0 == spi_clk)
	begin
	 //if(spi_cs == 1'b0)
	 begin
	  if (1'b1 == spi_ck_cnt)
	  	 ts_sync <= 1'b1;
	  else
	    ts_sync <= 1'b0;
	 end
	end
	end
 end

 always @ (negedge spi_clk or posedge spi_cs or negedge reset)
 begin
  if (!reset)
	spi_ck_cnt <= 1'b1;
  if (1'b1 == spi_cs)
 	spi_ck_cnt <= 1'b1;  // reset 1 bit cnt
  else if (1'b0 == spi_clk)
   spi_ck_cnt <= 0;
 end

 always @ (posedge spi_clk or negedge reset)
  if (!reset)
  begin
   spi_clk_1clk = 1'b0;
   spi_mosi_1clk = 1'b0;
  end
  else
  begin
   spi_clk_1clk <= spi_clk; // 1 clk delay copy of spi_clk
  	spi_mosi_1clk <= spi_mosi; // 1 clk delay copy of spi_mosi
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
