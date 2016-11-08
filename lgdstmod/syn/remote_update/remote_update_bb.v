
module remote_update (
	busy,
	data_out,
	param,
	read_param,
	reconfig,
	reset_timer,
	clock,
	reset,
	write_param,
	data_in,
	asmi_busy,
	asmi_data_valid,
	asmi_dataout,
	asmi_addr,
	asmi_read,
	asmi_rden,
	pof_error);	

	output		busy;
	output	[31:0]	data_out;
	input	[2:0]	param;
	input		read_param;
	input		reconfig;
	input		reset_timer;
	input		clock;
	input		reset;
	input		write_param;
	input	[31:0]	data_in;
	input		asmi_busy;
	input		asmi_data_valid;
	input	[7:0]	asmi_dataout;
	output	[31:0]	asmi_addr;
	output		asmi_read;
	output		asmi_rden;
	output		pof_error;
endmodule
