`timescale 1ns / 10ps

module test_lgdst_rxglue();

  reg       osc_50M = 1'b0;
  always #(1000/(50*2)) osc_50M = ~osc_50M;
  reg       osc_10M = 1'b0;
  always #(1000/(10*2)) osc_10M = ~osc_10M;

  wire      spi_clk = osc_10M; 
  wire      spi_miso;
  reg       spi_mosi = 1'b0;
  reg       spi_cs;
  wire      spi5_clk, 
            spi5_en_n, 
            spi_mosi; 

  wire      ts_d0;
  reg       ts_clk, ts_valid, ts_sync;

  initial 
  begin
    #300;
    #200000;
    //$stop;
  end

  tri1 ad_spi_sdio;

  lgdst_rxglue i_dut(
    .clk(),          .reset(),

    .spi_clk(osc_50M),                .spi_cs(spi_cs),
    .spi_mosi(spi_mosi),               

    .ts_clk(ts_clk),                    .ts_d0(ts_d0), 
    .ts_valid(ts_valid),                .ts_sync(ts_sync)
  );

 initial
 begin
  @(posedge i_dut.spi_clk) spi_cs = 1'b1;
  repeat(2) @(posedge i_dut.spi_clk) spi_cs = 1'b1;
  @(posedge i_dut.spi_clk) spi_cs = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b0;
 @(posedge i_dut.spi_clk) spi_mosi = 1'b1;
 end

endmodule
