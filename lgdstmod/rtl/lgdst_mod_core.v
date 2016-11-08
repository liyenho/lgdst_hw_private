/* Check List:
 *
 *
 */

`timescale 1ns /10ps

module lgdst_mod_core(
  input              rst_b,
  input              clk50m, 
  input              clk100m, 

  input              rf_data_clk,
  output             dvbt_tx_enable,
  output reg         rf_tx_p_frame_mb,
  output reg  [5:0]  rf_tx_p_data_p_mb,
  output reg  [5:0]  rf_tx_p_data_n_mb,

  // IOs for ts_data_spi_receiver
  input              spi_spck,         
  input              spi_npcs0,    
  input              spi_mosi,     
  output             spi_miso,     
  output      [7:0]  cbr_data,
  output             cbr_data_vld,

  input              TEST_MODE,
  input              RESET_COUNTS,
  output      [7:0]  TS_SYNC_LOSS_COUNT,
  output      [7:0]  SHIFTED_BYTE_COUNT,
  output      [7:0]  PATTERN_DATA_ERROR_COUNT,
  output      [7:0]  PATTERN_PKT_LOSS_COUNT,
  output      [7:0]  CONTINUITY_ERROR_COUNT,
  output      [15:0] TSBITRATE1k,    //added this reg by sid

  input              rx_frame_p_s, 
  input              rx_frame_n_s,
  input       [5:0]  rf_rx_data_p_s,
  input       [5:0]  rf_rx_data_n_s,
  output      [3:0]  adi_ctrl_in,
  input       [7:0]  adi_ctrl_out
);

  assign adi_ctrl_in = 4'd0;

  reg     [5:0] dvbt_gen_cntr = 6'd30;
  reg    [11:0] dvbt_gen_i, dvbt_gen_q;
  reg    [11:0] cbr_gen;

  assign dvbt_tx_enable = ~|dvbt_gen_cntr;

  always @(posedge rf_data_clk or negedge rst_b)
  begin
    if (!rst_b)
    begin
      dvbt_gen_cntr <= 6'd30;
      dvbt_gen_i <= {6'h3A, 6'd0};
      dvbt_gen_q <= {6'h17, 6'd0};
      {rf_tx_p_data_p_mb, rf_tx_p_data_n_mb, rf_tx_p_frame_mb} = 'd0;

      cbr_gen <= 'd0;
    end
    else
    begin
      dvbt_gen_cntr <= dvbt_gen_cntr + {6{~dvbt_tx_enable}};
      if (~dvbt_tx_enable)
      begin
        dvbt_gen_i <= dvbt_gen_i + 12'd3;
        dvbt_gen_q <= dvbt_gen_q + 12'd7;
      end
      else
      begin
        if (rx_frame_p_s)
        begin
          dvbt_gen_i[11:6] <= rf_rx_data_p_s;
          dvbt_gen_q[11:6] <= rf_rx_data_n_s;
        end
        else
        begin
          dvbt_gen_i[5:0] <= rf_rx_data_p_s;
          dvbt_gen_q[5:0] <= rf_rx_data_n_s;
        end
      end

      if (dvbt_gen_cntr[0])
        {rf_tx_p_data_p_mb, rf_tx_p_data_n_mb, rf_tx_p_frame_mb} <= 
            {dvbt_gen_i[11:6], dvbt_gen_q[11:6], 1'b1};
      else
        {rf_tx_p_data_p_mb, rf_tx_p_data_n_mb, rf_tx_p_frame_mb} <= 
            {dvbt_gen_i[5:0], dvbt_gen_q[5:0], 1'b0};

      cbr_gen <= cbr_gen + 1'b1;
    end
  end

  ts_data_spi_receiver i_ts_rcvr(
    //System Control
    .CLK(clk50m),                   .RST(~rst_b),
    
    //Helm Register Config and Status Interfaces
    .TEST_MODE(1'b1),//TEST_MODE),
    .RESET_COUNTS(RESET_COUNTS),
    .TS_SYNC_LOSS_COUNT(TS_SYNC_LOSS_COUNT),
    .SHIFTED_BYTE_COUNT(SHIFTED_BYTE_COUNT),
    .PATTERN_DATA_ERROR_COUNT(PATTERN_DATA_ERROR_COUNT),
    .PATTERN_PKT_LOSS_COUNT(PATTERN_PKT_LOSS_COUNT),
    .CONTINUITY_ERROR_COUNT(CONTINUITY_ERROR_COUNT),
	 .TSBITRATE1k(TSBITRATE1k), //added by sid
    
    //SPI Interface
    .SCLK(spi_spck),                .MOSI(spi_mosi),     
    .MISO(spi_miso),                .SS_NOT(spi_npcs0),    
    
    //Transport Stream Interface
    .TS_DATA(cbr_data),             .TS_DATA_VALID(cbr_data_vld)
  );

endmodule
