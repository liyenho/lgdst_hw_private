`timescale 1ns / 10ps

module adi9364_if(
  input         fpga_rst_b,
  input         adi_data_clk_p, 
  //input         adi_data_clk_n,
  input         adi_rx_frame_p,
  input         adi_rx_frame_n,
  input   [5:0] adi_rx_n,
  input   [5:0] adi_rx_p,
  output        adi_tx_frame_p,
  //output        adi_tx_frame_n,
  output  [5:0] adi_tx_p,
  //output  [5:0] adi_tx_n,

  output        rf_l_clk,
  output        rf_data_clk,
  output        clk146, 

  output        rx_frame_p_s,
  output        rx_frame_n_s,
  output  [5:0] rf_rx_data_p_s, 
  output  [5:0] rf_rx_data_n_s,

  input         rf_tx_p_frame,
  input   [5:0] rf_tx_p_data_p, 
  input   [5:0] rf_tx_p_data_n
);
  reg           dcm_por;
  wire          adi_rx_frame, adi_tx_frame;
  wire    [5:0] adi_rx_data,  adi_tx_data;

  always @(posedge adi_data_clk_p or negedge fpga_rst_b)
  begin
    if (!fpga_rst_b)
      dcm_por <= 1'b1;
    else
      dcm_por <= 1'b0;
  end

  tx_clk_gen2 tx_clk_gen_i(
    .refclk(adi_data_clk_p),            .rst(dcm_por), 
    .outclk_0(clk146),                  //.outclk_1(rf_l_clk), 
    .locked()
  );

  assign adi_tx_frame_p = adi_tx_frame;
  assign adi_tx_p = adi_tx_data;
  assign adi_rx_frame = adi_rx_frame_p;
  assign adi_rx_data = adi_rx_p;
  assign rf_l_clk = adi_data_clk_p;
  assign rf_data_clk = rf_l_clk;

  // Differential Pairs for ADI TX/RX
  /*
  adi_tx i_adi_tx(
    .datain({adi_tx_frame, adi_tx_data}),
    .dataout({adi_tx_frame_p, adi_tx_p}),       .dataout_b({adi_tx_frame_n, adi_tx_n})
  );
  adi_rx i_adi_rx(
   .datain({adi_rx_frame_p, adi_rx_p}),         .datain_b({adi_rx_frame_n, adi_rx_n}),
   .dataout({adi_rx_frame, adi_rx_data})
  );
  diff_clkin i_rf_l_clk(            //ad9364_rx_clk_in_p/n
    .datain(adi_data_clk_p),        .datain_b(adi_data_clk_n),
    .dataout(rf_l_clk)
  );
  */

  // DDR I/O for ADI TX/RX
  // transmit frame interface, oddr -> obuf
  ad_lvds_out i_tx_frame(
    .tx_inclock(rf_l_clk),          .tx_in({rf_tx_p_frame, rf_tx_p_frame}),
    .tx_outclock(),                 .tx_out(adi_tx_frame)
  );
  ad_lvds_in i_rx_frame(
    .rx_inclock(rf_l_clk), 
    .rx_in(adi_rx_frame),           .rx_out({rx_frame_p_s, rx_frame_n_s})
  );

  genvar l_inst;
  generate
    for (l_inst = 0; l_inst <= 5; l_inst = l_inst + 1) begin: g_tx_data
      ad_lvds_out i_tx_data( // TBD: check bit order
        .tx_inclock(rf_l_clk),          .tx_in({rf_tx_p_data_p[l_inst], rf_tx_p_data_n[l_inst]}),
        .tx_outclock(),                 .tx_out(adi_tx_data[l_inst])
      );
    end
    for (l_inst = 0; l_inst <= 5; l_inst = l_inst + 1) begin: g_rx_data
      ad_lvds_in i_rx_data( // TBD: check bit order
        .rx_inclock(rf_l_clk), 
        .rx_in(adi_rx_data[l_inst]),    .rx_out({rf_rx_data_p_s[l_inst],  rf_rx_data_n_s[l_inst]})
      );
    end
  endgenerate

endmodule
