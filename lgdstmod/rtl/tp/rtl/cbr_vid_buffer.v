`timescale 1ns / 10ps

module cbr_vid_buffer #(
  parameter     PROG_FULL_THRESHOLD = 13'd3859   
)(
  input         rst, 
    
  input         wr_clk,
  input         rd_clk,
  input   [7:0] din,
  input         wr_en,
  input         rd_en,
  output  [7:0] dout,
  output        full,
  output        almost_full,
  output        overflow,
  output        empty,
  output        almost_empty,
  output        valid,
  output        underflow,
  output [12:0] rd_data_count,
  output [12:0] wr_data_count,
  output reg    prog_full,
  output        prog_empty
);

  always @(posedge wr_clk or posedge rst)
  begin
    if (rst)
      prog_full <= 1'b0;
    else
      prog_full <= full || (wr_data_count > PROG_FULL_THRESHOLD);
  end

  cbr_vid_buffer_fifo i_vid_buffer(
    .aclr(rst), 

    .wrclk(wr_clk),                 .wrreq(wr_en),
    .data(din),                     
    .wrusedw(wr_data_count),        .wrfull(full), 

    .rdclk(rd_clk),                 .rdreq(rd_en),
    .q(dout),
    .rdempty(),                     .rdusedw(rd_data_count)
    
  );

endmodule
