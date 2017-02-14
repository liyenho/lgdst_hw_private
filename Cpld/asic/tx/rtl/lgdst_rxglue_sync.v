/*
 *
 */

`timescale 1ns / 10ps

module lgdst_rxglue_sync(
  input             clk,

  // IOs for ADRF_brg
  input             spi0_spck,
  input             spi0_npcs0,
  input             spi0_mosi,
  output reg        spi0_miso,

  output            ad_spi_cs,
  output            ad_spi_sclk,
  inout             ad_spi_sdio,

  // IOs for TS_brg
  input             spi5_spck,
  input             spi5_npcs0,
  input             spi5_mosi,
  output reg        spi5_miso = 1'b0,

  input             ts_clk,
  input             ts_d0,
  input             ts_valid,
  input             ts_sync
);

  // Signals for ADRF_brg
  reg     [1:0] spi0_ck_sync = 2'b11,
                spi0_csn_sync = 2'b11,
                spi0_mosi_sync = 2'b11;
  reg     [3:0] spi0_ck_cnt = 4'd8;

  reg           ad_spi_rw   = 1'b0;
  reg           ad_spi_oe_b = 1'b1;


  wire      spi0_csn_fall = spi0_csn_sync[1] & ~spi0_csn_sync[0];
  wire      spi0_ck_rise = ~spi0_ck_sync[1]  &  spi0_ck_sync[0];
  wire      spi0_ck_fall =  spi0_ck_sync[1]  & ~spi0_ck_sync[0];

  assign {ad_spi_cs, ad_spi_sclk} = {spi0_csn_sync[1], spi0_ck_sync[1]};
  assign ad_spi_sdio = (ad_spi_oe_b)? 1'bz: spi0_mosi_sync[1];

  always @(posedge clk)
  begin
    spi0_ck_sync <= {spi0_ck_sync[0], spi0_spck};
    spi0_csn_sync <= {spi0_csn_sync[0], spi0_npcs0};
    spi0_mosi_sync <= {spi0_mosi_sync[0], spi0_mosi};

    spi0_miso <= (ad_spi_oe_b)? ad_spi_sdio: 1'b0;
    // so when spi0_ck_cnt reaches 0xa? that points r/w bit on mosi line, liyenho
    spi0_ck_cnt <= (spi0_csn_sync[1])? 4'd8:
                   spi0_ck_cnt + {4{|spi0_ck_cnt & spi0_ck_rise}};

    ad_spi_rw   <= (spi0_csn_sync[1])? 1'b0:
                   //(~|spi0_ck_cnt[3:1] & spi0_ck_cnt[0] & spi0_ck_rise)? spi0_mosi:
                   (~|spi0_ck_cnt[3:1] & spi0_ck_cnt[0] & spi0_ck_rise)? spi0_mosi:
                   ad_spi_rw;
    ad_spi_oe_b <= (spi0_csn_fall)? 1'b0:
                   (spi0_csn_sync[1])? 1'b1:
                   (spi0_ck_fall)? ad_spi_rw:
                    ad_spi_oe_b;
  end

  // Signals for TS_brg
  reg       ts_active = 1'b0;
  reg [7:0] ts_buf, ts_spi_buf;
  reg       ts_spi_buf_vld = 1'b0;
  reg [2:0] ts_cntr = 'd7;
  wire      ts_wr = &{ts_cntr, ts_active};
  reg [1:0] ts_wr_sync = 2'd0;
  wire      ts_wr_rise = ~ts_wr_sync[1] & ts_wr_sync[0] & spi5_npcs0;
  reg [1:0] spi5_npcs0_sync = 2'd3;
  wire      spi5_npcs0_rise = ~spi5_npcs0_sync[1] & spi5_npcs0_sync[0];
  reg [1:0] spi5_spck_sync = 2'd3;
  wire      spi5_spck_rise = ~spi5_spck_sync[1] & spi5_spck_sync[0];

  reg [2:0] spi5_clk_cnt = 'd7;

  always @(posedge clk)
  begin
    ts_wr_sync      <= {ts_wr_sync[0], ts_wr};
    spi5_npcs0_sync <= {spi5_npcs0_sync[0], spi5_npcs0};
    spi5_spck_sync  <= {spi5_spck_sync[0], spi5_spck};

    ts_spi_buf <= (ts_wr_rise)? ts_buf:
                  (spi5_spck_rise)? {ts_spi_buf[6:0], ts_spi_buf[7]}:
                                ts_spi_buf;
    ts_spi_buf_vld <= (ts_wr_rise)? 1'b1:
                      (spi5_npcs0_rise)? 1'b0: ts_spi_buf_vld;
  end

  always @(posedge ts_clk)
  begin
    ts_active <= (~ts_valid)? 1'b0:
                 (ts_sync & ts_valid)? 1'b1:ts_active;
    ts_buf <= {ts_d0, ts_buf[7:1]};
    ts_cntr <= (~ts_valid)? 'd7:
                ts_cntr + {2'd0, (ts_sync & ts_valid) | ts_active};
  end

  always @(negedge spi5_spck)
  begin
    spi5_clk_cnt <= (spi5_npcs0)? 'd7:
                    spi5_clk_cnt + {3{|spi5_clk_cnt}};
    spi5_miso <= (|spi5_clk_cnt[2:1])? 1'b0:
                 ( spi5_clk_cnt[0]  )? ts_spi_buf_vld:
                                       ts_spi_buf[7];
  end

endmodule
