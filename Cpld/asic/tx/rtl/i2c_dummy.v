`timescale 1ns /10ps

module i2c_dummy#(
  parameter         SLAVE_ADR = 7'h68,
  parameter         RW_BIT    = 1'b1
)(
  input             clk,
  
  input             trig, //active high

  output            scl, 
  input             sdai,
  output  reg       sdao=1'b1,
  output  reg       scl_reg=1'b1,  //monitoring
  output            byte_cmpl,
  output            nack,
  output  reg       dummy_en=1'b0
  
);

  reg       trig_sync = 1'd1;
  wire      trig_rise = ~trig_sync & trig;
  reg       adr_out  = 1'b0;
  reg [3:0] bit_cntr = 'd4;
  assign    byte_cmpl = &bit_cntr[2:0]; //kevin old
  //assign      byte_cmpl = &bit_cntr[3:0];
  assign      nack = byte_cmpl & sdai;

  assign scl = (scl_reg)? 1'bz:1'b0;
  //assign scl = 1'bz; //testing

  always @(posedge clk)
  begin
    trig_sync <= trig;
    dummy_en <= (trig_rise)? 1'b1:
			    (nack & scl_reg)?1'b0: //check on falling edge
                dummy_en;
    adr_out  <= (trig_rise)? 1'b1:
                (byte_cmpl)? 1'b0:
                adr_out;

    scl_reg <= ~dummy_en | (dummy_en ^ scl_reg);
    sdao <= (trig_rise |(nack & scl_reg) | (~sdao & ~dummy_en & ~scl_reg))?  1'b0:  //check on falling edge
               (~adr_out)?         1'b1:
               (~scl_reg)?         sdao: 
               (bit_cntr == 'd2 )? SLAVE_ADR[6]:
               (bit_cntr == 'd4 )? SLAVE_ADR[5]:
               (bit_cntr == 'd9 )? SLAVE_ADR[4]:
               (bit_cntr == 'd3 )? SLAVE_ADR[3]:
               (bit_cntr == 'd6 )? SLAVE_ADR[2]:
               (bit_cntr == 'd13)? SLAVE_ADR[1]:
               (bit_cntr == 'd10)? SLAVE_ADR[0]:
               (bit_cntr == 'd5 )? RW_BIT:
                                   1'b1;

    bit_cntr <= (~dummy_en)? 4'd2:
                (~scl_reg)? bit_cntr: //change on fall edge
                (byte_cmpl)? 4'd4:
                             {bit_cntr[2:0], ^bit_cntr[3:2]};
	// lfsr sequence: 2,4,9,3,6,13,10,5,11,7,15,14,12,8,1,
  end
endmodule
