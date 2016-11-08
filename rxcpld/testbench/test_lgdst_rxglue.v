`timescale 1ns / 10ps

module test_lgdst_rxglue();

  reg       osc_50M = 1'b0;
  always #(1000/(50*2)) osc_50M = ~osc_50M;
  reg       osc_10M = 1'b0;
  always #(1000/(10*2)) osc_10M = ~osc_10M;

  wire      spi_clk = osc_10M; 
  wire      spi_miso;
  reg       spi_mosi = 1'b0;
  reg       spi_en_n;
  wire      spi5_clk, 
            spi5_en_n, 
            spi5_mosi; 

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
    .clk(osc_50M),          

    .spi0_spck(spi_clk),                .spi0_npcs0(),
    .spi0_mosi(spi_mosi),               .spi0_miso(spi_miso),
    .tp_45(spi_en_n),

    .ad_spi_cs(),
    .ad_spi_sclk(),
    .ad_spi_sdio(ad_spi_sdio), 

    .spi5_spck(spi5_clk),                .spi5_npcs0(spi5_en_n),
    .spi5_mosi(spi5_mosi),               

    .ts_clk(ts_clk),                    .ts_d0(ts_d0), 
    .ts_valid(ts_valid),                .ts_sync(ts_sync)
  );

// code for driving the 6612 signals

//  always @ (posedge i_dut.spi0_spck)
//  begin
//  spi_mosi <= ~spi_mosi;
//  end

 initial
 begin
  @(posedge i_dut.spi0_spck) spi_en_n = 1'b1;
  repeat(2) @(posedge i_dut.spi0_spck) spi_en_n = 1'b1;
  @(posedge i_dut.spi0_spck) spi_en_n = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b0;
 @(posedge i_dut.spi0_spck) spi_mosi = 1'b1;
 end

  always #500 ts_clk = ~ts_clk;
  wire [188*8-1:0] ts_pattern;
  reg        [7:0] ts_pat_reg[0:187];
  integer        ts_i;
  integer        ts_B_i;
  assign ts_d0 = ts_pattern[ts_i];

  genvar t_i;
  generate
    for (t_i=0; t_i < 188; t_i=t_i+1)
    begin
      assign ts_pattern[t_i*8+7: t_i*8] = ts_pat_reg[t_i];
    end
  endgenerate

  initial 
  begin
    ts_clk = 'd0;
    {ts_valid, ts_sync} = 'd0;
    repeat (30) @(posedge ts_clk); #1;
    
    ts_valid = 1'b1;
    repeat (30) @(posedge ts_clk); #1;
    ts_valid = 1'b0;
    repeat (30) @(posedge ts_clk); #1;

    ts_B_i = 8;
    for (ts_i = 0; ts_i < ts_B_i; ts_i = ts_i+1)
      ts_pat_reg[ts_i] <= ts_i*8'h11;
    @(negedge ts_clk); #1;
    for (ts_i = 0; ts_i < ts_B_i*8; ts_i = ts_i+1)
    begin
      if (ts_i == 0)
        {ts_valid, ts_sync} = 'd3;
      else
        {ts_valid, ts_sync} = 'd2;
      @(negedge ts_clk); #1;
    end
    {ts_valid, ts_sync} = 'd0;
    repeat (30) @(posedge ts_clk); #1;

    ts_B_i = 8;
    for (ts_i = 0; ts_i < ts_B_i; ts_i = ts_i+1)
      ts_pat_reg[ts_i] <= ts_i*8'h22;
    @(negedge ts_clk); #1;

    repeat (2)
    begin
      for (ts_i = 0; ts_i < ts_B_i*8; ts_i = ts_i+1)
      begin
        if (ts_i == 0)
          {ts_valid, ts_sync} = 'd3;
        else
          {ts_valid, ts_sync} = 'd2;
        @(negedge ts_clk); #1;
      end
    end
    {ts_valid, ts_sync} = 'd0;
    repeat (30) @(posedge ts_clk); #1;

    repeat (10) @(posedge ts_clk); #1;
    $stop;
  end

  integer spi5_byte_cnt = 'd0;
  reg [2:0] spi5_tick;
  reg [7:0] spi5_buf;
  reg [1:0] spi5_clk_sync = 2'd3;
  wire      spi5_clk_rise = ~spi5_clk_sync[1] & spi5_clk_sync[0];
  reg [7:0] spi5_result;

  always @(posedge spi5_clk)
  begin
    if (spi5_en_n)
    begin
      spi5_tick <= 'd0;
    end
    else
    begin
      spi5_tick <= spi5_tick + 1'b1;
      spi5_buf <= {spi5_buf, spi5_mosi};
    end
  end
 
  always @(posedge osc_50M)
  begin
    spi5_clk_sync <= {spi5_clk_sync[0], spi5_clk};
    spi5_result <= (spi5_clk_rise & ~|spi5_tick)? spi5_buf:spi5_result;
    spi5_byte_cnt <= (spi5_clk_rise & ~|spi5_tick)? spi5_byte_cnt + 'd1 : spi5_byte_cnt;
  end

endmodule
