
module tx (
	iclk,
	icode,
	idat,
	iguard,
	imod,
	irst,
	isop,
	ival,
	odati,
	odatq,
	ordy);
input	iclk;
input	[2:0] icode;
input	[7:0] idat;
input	[1:0] iguard;
input	[1:0] imod;
input	irst;
input	isop;
input	ival;
output	[15:0] odati;
output	[15:0] odatq;
output	ordy;

endmodule
