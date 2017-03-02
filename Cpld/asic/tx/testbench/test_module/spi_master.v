`timescale 1ns / 10ps

module spi_master#(
  parameter REG_INFO = 1,
  parameter CLK_PERIOD = 1000/3 //ns, i.e. 3.33MHz
)(
  output reg        spi_clk = 1'b0,
  output reg        spi_en_n  = 1'b1,

  output reg        spi_mosi,
  input             spi_miso
);

  reg  [12*8:0] msg = "IDLE ...";
  reg           busy_flag = 1'b0;
  reg    [23:0] spi_wr_sh_reg;
  reg    [15:0] spi_rd_sh_reg;
  reg    [15:0] RDR; 

  initial
  begin
    #100;
    //spi_wr(7'h34, 8'hAB);
    //spi_wr(7'h27, 8'h11);
  end

  task spi_wr;
  input [2:0] cmd;
  input [19:0] data;
  begin
    if (busy_flag)
    begin
      @(negedge busy_flag);
      #1;
    end
    busy_flag = 1'b1;
    spi_en_n = 1'b0;
    spi_wr_sh_reg = {1'b1, cmd, data};
    $display("  Atmel TDR = 'h%x (cmd='h%x, ad='h%x)\n    SPI Op... ", spi_wr_sh_reg, {1'b1, cmd}, data);
    spi_mosi = spi_wr_sh_reg[23];
    #1;//(CLK_PERIOD/2);

    msg = "Wr";
    repeat(8)
    begin
      spi_mosi = spi_wr_sh_reg[23];
      spi_wr_sh_reg = {spi_wr_sh_reg[22:0], spi_wr_sh_reg[23]};
      #(CLK_PERIOD/2);
      spi_clk = 1'b1;
      #(CLK_PERIOD/2);
      spi_clk = 1'b0;
      msg = "wAdr";
    end
    
    msg = "wData";
    repeat(16)
    begin
      spi_mosi = spi_wr_sh_reg[23];
      spi_wr_sh_reg = {spi_wr_sh_reg[22:0], spi_wr_sh_reg[23]};
      #(CLK_PERIOD/2);
      spi_clk = 1'b1;
      #(CLK_PERIOD/2);
      spi_clk = 1'b0;
    end

    #(CLK_PERIOD/2);
    spi_en_n = 1'b1;
    busy_flag = 1'b0;
    msg = "Idle ...";
    #(CLK_PERIOD);
  end
  endtask

  task spi_rd;
  input [2:0] cmd;
  begin
    if (busy_flag)
    begin
      @(negedge busy_flag);
      #1;
    end
    busy_flag = 1'b1;
    spi_en_n = 1'b0;
    spi_rd_sh_reg = {1'b0, cmd, 12'h0FF};
    $display("  Atmel TDR = 'h%x (cmd='h%x)\n    SPI Op... ", spi_rd_sh_reg, {1'b0, cmd});
    spi_mosi = spi_rd_sh_reg[15];
    #1;//(CLK_PERIOD/2);

    msg = "Rd";
    repeat(8)
    begin
      spi_mosi = spi_rd_sh_reg[15];
      #(CLK_PERIOD/2);
      spi_clk = 1'b1; #1;
      spi_rd_sh_reg = {spi_rd_sh_reg[14:0], spi_miso};
      #(CLK_PERIOD/2);
      spi_clk = 1'b0;
      msg = "rAdr";
    end
    
    msg = "rData";
    repeat(8)
    begin
      spi_mosi = spi_rd_sh_reg[15];
      #(CLK_PERIOD/2);
      spi_clk = 1'b1; #1;
      spi_rd_sh_reg = {spi_rd_sh_reg[14:0], spi_miso};
      #(CLK_PERIOD/2);
      spi_clk = 1'b0;
    end

    #(CLK_PERIOD/2);
    spi_en_n = 1'b1;
    busy_flag = 1'b0;
    RDR = spi_rd_sh_reg;
    $display("  Atmel RDR = %x, after SPI operation", spi_rd_sh_reg[11:0]);
    msg = "Idle ...";
    #CLK_PERIOD;
  end
  endtask
endmodule
