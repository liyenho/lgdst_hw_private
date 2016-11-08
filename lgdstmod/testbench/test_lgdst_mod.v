`timescale 1ns / 10ps

module test_lgdst_mod();

  reg       rst_b = 1'b0;
  reg       osc_24M = 1'b0;
  reg       adi_data_clk = 1'b0;

  always #20.8333 osc_24M = ~osc_24M;
  always #6.840 adi_data_clk = ~adi_data_clk;

  defparam i_dut.i_helm_uart.UART_BAUD_RATE = 1152000*3;

  initial 
  begin
    rst_b = 1'b1;
    #10;
    rst_b = 1'b0;
    #300;
    @(posedge osc_24M); #1;
    rst_b = 1'b1;

    #300;
    SPI_Test();
    #30000;
    //$stop;
  end

  wire          adi_fb_clk;
  reg           adi_rx_frame;
  reg     [5:0] adi_rx;      
  wire          adi_tx_frame;
  wire    [5:0] adi_tx;      

  wire          spi_clk, spi_en_n, spi_mosi, spi_miso;

  wire          helm_txd, helm_rxd;
  tri1          fpga_reset_a;

  always @(*)
    {adi_rx_frame, adi_rx} <= {adi_tx_frame, adi_tx};

  lgdst_mod_top i_dut(
    .clk_24M(osc_24M),          
    .fpga_rst_b(),                 .fpga_reset_a(fpga_reset_a),

    // Signals from ADI9634  
    //.adi_clk_out(1'b0),     
    .adi_fb_clk_p(adi_fb_clk),        
    .adi_data_clk_p(adi_data_clk),   
    .adi_rx_frame_p(adi_rx_frame),  
    .adi_rx_p(adi_rx),             
    .adi_tx_frame_p(adi_tx_frame), 
    .adi_tx_p(adi_tx),            

    .spi0_spck(spi_clk),                .spi0_npcs0(spi_en_n),
    .spi0_mosi(spi_mosi),               .spi0_miso(spi_miso),

    .helm_txd(helm_txd),                .helm_rxd(helm_rxd),

    .dbg_tp()
  );

  spi_master i_atmel_spi(
    .spi_clk(spi_clk),                  .spi_en_n(spi_en_n), 
    .spi_mosi(spi_mosi),                .spi_miso(spi_miso)
  );
 
  reg           tx_wr =1'b0;
  reg     [7:0] tx_data;
  wire          tx_busy; 
  integer       tx_pat_i, i;
  reg     [32*8-1:0] tx_pattern;
  wire    [7:0] tx_pat_ary[31:0];

  genvar gen_i;
  generate 
    for (gen_i=0; gen_i < 32; gen_i = gen_i+1)
    begin
      assign tx_pat_ary[gen_i] = tx_pattern[(gen_i*8+7): (gen_i*8)];
    end
  endgenerate

  initial 
  begin
    #1000;
    force i_cmd_uart.txd = 1'b0;
    repeat(6)
      @(posedge i_dut.clk50m); #1;
    release i_cmd_uart.txd;
    #2000;

    tx_pat_i = 11;
    //tx_pattern = 88'hAA_99_55_66_02_00_03_00_00_01_06;
    tx_pattern = 88'hAA_99_55_66_02_00_03_00_00_20_25;
    
    for (i=tx_pat_i-1; i >= 0; i = i-1)
    begin
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b1;
      tx_data = tx_pat_ary[i];
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b0;

      @(negedge tx_busy);
    end
    #200000;

    tx_pat_i = 12;
    tx_pattern = 96'hAA_99_55_66_01_33_04_00_34_77_f0_d3;
    
    for (i=tx_pat_i-1; i >= 0; i = i-1)
    begin
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b1;
      tx_data = tx_pat_ary[i];
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b0;

      @(negedge tx_busy);
    end
    #60000;

    tx_pat_i = 11;
    tx_pattern = 88'hAA_99_55_66_02_00_03_00_20_20_45;
    
    for (i=tx_pat_i-1; i >= 0; i = i-1)
    begin
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b1;
      tx_data = tx_pat_ary[i];
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b0;

      @(negedge tx_busy);
    end
    #200000;

    tx_pat_i = 11;
    tx_pattern = 88'hAA_99_55_66_02_00_03_01_20_18_3E;
    
    for (i=tx_pat_i-1; i >= 0; i = i-1)
    begin
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b1;
      tx_data = tx_pat_ary[i];
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b0;

      @(negedge tx_busy);
    end
    #150000;

    tx_pat_i = 16;
    tx_pattern = 'hAA_99_55_66_00_33_08_00_34_05_11_22_33_44_55_73;
    
    for (i=tx_pat_i-1; i >= 0; i = i-1)
    begin
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b1;
      tx_data = tx_pat_ary[i];
      @(posedge i_dut.clk50m); #1;
      tx_wr = 1'b0;

      @(negedge tx_busy);
    end
    #60000;

    $stop;
  end

  uart_top #(
   .UART_BAUD_RATE(1152000*3)
  ) i_cmd_uart (
    .clk(i_dut.clk50m),         .rst_b(rst_b),

    .rxd(helm_txd),             .txd(helm_rxd), 

    .tx_wr(tx_wr),              .tx_busy(tx_busy),
    .tx_data(tx_data)
  );

  task SPI_Test();
  begin
    $display("\/\/Setup 12-b Address Register");
    i_atmel_spi.spi_wr(3'h4, 12'h133);
    $display("\/\/Setup 8-b Data Register");
    i_atmel_spi.spi_wr(3'h0, 12'h001);
    $display("\/\/Setup 8-b Data Register and Assert Write Command");
    i_atmel_spi.spi_wr(3'h2, 12'h055);
    $display("\/\/Setup 8-b Data Register and Assert Write Command and Adr Increase by 1");
    i_atmel_spi.spi_wr(3'h3, 12'h092);
    $display("\/\/Setup 8-b Data Register and Assert Write Command and Adr Increase by 1");
    i_atmel_spi.spi_wr(3'h3, 12'h093);
    $display("\/\/Setup 8-b Data Register and Assert Write Command and Adr Increase by 1");
    i_atmel_spi.spi_wr(3'h3, 12'h094);
    $display("\/\/Setup 8-b Data Register and Assert Write Command and Adr Increase by 1");
    i_atmel_spi.spi_wr(3'h3, 12'h095);
    
    $display("\/\/Setup 12-b Address Register and Prepare data in SPI 8-bit Data Register");
    i_atmel_spi.spi_wr(3'h5, 12'd034);
    $display("\/\/Read from SPI 8-b Data Register");
    i_atmel_spi.spi_rd(3'h0);
    $display("\/\/Read from SPI 8-b Data Register and Prepare next data in SPI 8-bit Data Register");
    i_atmel_spi.spi_rd(3'h2);
    $display("\/\/Read from SPI 8-b Data Register and Prepare next data in SPI 8-bit Data Register");
    i_atmel_spi.spi_rd(3'h2);
    repeat(5)
    begin
      $display("\/\/Read from SPI 8-b Data Register and Prepare next data in SPI 8-bit Data Register from Addr+1");
      i_atmel_spi.spi_rd(3'h3);
    end

    //$stop;
  end
  endtask

endmodule
