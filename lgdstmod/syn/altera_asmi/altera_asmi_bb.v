
module altera_asmi (
	clkin,
	read,
	rden,
	addr,
	reset,
	dataout,
	busy,
	data_valid,
	wren,
	en4b_addr);	

	input		clkin;
	input		read;
	input		rden;
	input	[31:0]	addr;
	input		reset;
	output	[7:0]	dataout;
	output		busy;
	output		data_valid;
	input		wren;
	input		en4b_addr;
endmodule
