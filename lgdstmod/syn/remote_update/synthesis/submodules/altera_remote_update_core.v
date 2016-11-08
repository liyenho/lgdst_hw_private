//altremote_update CBX_AUTO_BLACKBOX="ALL" CBX_SINGLE_OUTPUT_FILE="ON" check_app_pof="true" config_device_addr_width=32 DEVICE_FAMILY="Cyclone V" in_data_width=32 is_epcq="true" operation_mode="remote" out_data_width=32 asmi_addr asmi_busy asmi_data_valid asmi_dataout asmi_rden asmi_read busy clock ctl_nupdt data_in data_out param pof_error read_param reconfig reset reset_timer write_param
//VERSION_BEGIN 15.1 cbx_altremote_update 2015:10:21:18:09:23:SJ cbx_cycloneii 2015:10:21:18:09:23:SJ cbx_lpm_add_sub 2015:10:21:18:09:23:SJ cbx_lpm_compare 2015:10:21:18:09:23:SJ cbx_lpm_counter 2015:10:21:18:09:23:SJ cbx_lpm_decode 2015:10:21:18:09:23:SJ cbx_lpm_shiftreg 2015:10:21:18:09:23:SJ cbx_mgl 2015:10:21:18:12:49:SJ cbx_nadder 2015:10:21:18:09:23:SJ cbx_nightfury 2015:10:21:18:09:22:SJ cbx_stratix 2015:10:21:18:09:23:SJ cbx_stratixii 2015:10:21:18:09:23:SJ  VERSION_END
// synthesis VERILOG_INPUT_VERSION VERILOG_2001
// altera message_off 10463



// Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
//  Your use of Altera Corporation's design tools, logic functions 
//  and other software and tools, and its AMPP partner logic 
//  functions, and any output files from any of the foregoing 
//  (including device programming or simulation files), and any 
//  associated documentation or information are expressly subject 
//  to the terms and conditions of the Altera Program License 
//  Subscription Agreement, the Altera Quartus Prime License Agreement,
//  the Altera MegaCore Function License Agreement, or other 
//  applicable license agreement, including, without limitation, 
//  that your use is for the sole purpose of programming logic 
//  devices manufactured by Altera and sold by Altera or its 
//  authorized distributors.  Please refer to the applicable 
//  agreement for further details.



//synthesis_resources = cyclonev_rublock 1 lpm_add_sub 1 lpm_counter 7 lpm_shiftreg 1 reg 172 
//synopsys translate_off
`timescale 1 ps / 1 ps
//synopsys translate_on
(* ALTERA_ATTRIBUTE = {"suppress_da_rule_internal=c104;suppress_da_rule_internal=C101;suppress_da_rule_internal=C103"} *)
module  altera_remote_update_core
	( 
	asmi_addr,
	asmi_busy,
	asmi_data_valid,
	asmi_dataout,
	asmi_rden,
	asmi_read,
	busy,
	clock,
	ctl_nupdt,
	data_in,
	data_out,
	param,
	pof_error,
	read_param,
	reconfig,
	reset,
	reset_timer,
	write_param) /* synthesis synthesis_clearbox=1 */;
	output   [31:0]  asmi_addr;
	input   asmi_busy;
	input   asmi_data_valid;
	input   [7:0]  asmi_dataout;
	output   asmi_rden;
	output   asmi_read;
	output   busy;
	input   clock;
	input   ctl_nupdt;
	input   [31:0]  data_in;
	output   [31:0]  data_out;
	input   [2:0]  param;
	output   pof_error;
	input   read_param;
	input   reconfig;
	input   reset;
	input   reset_timer;
	input   write_param;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri0   asmi_busy;
	tri0   asmi_data_valid;
	tri0   [7:0]  asmi_dataout;
	tri0   ctl_nupdt;
	tri0   [31:0]  data_in;
	tri0   [2:0]  param;
	tri0   read_param;
	tri0   reconfig;
	tri0   reset_timer;
	tri0   write_param;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	reg	[7:0]	asim_data_reg;
	wire	[31:0]	wire_asmi_addr_st_d;
	reg	[31:0]	asmi_addr_st;
	wire	[31:0]	wire_asmi_addr_st_ena;
	reg	[0:0]	asmi_read_reg;
	reg	[0:0]	cal_addr_reg;
	reg	[0:0]	check_busy_dffe;
	reg	[0:0]	crc_cal_reg;
	reg	[0:0]	crc_check_end_reg;
	reg	[0:0]	crc_chk_st_dffe;
	reg	[0:0]	crc_done_reg;
	wire	wire_crc_done_reg_ena;
	reg	[7:0]	crc_high;
	reg	[7:0]	crc_low;
	reg	[15:0]	crc_reg;
	wire	[31:0]	wire_dataa_switch_d;
	reg	[31:0]	dataa_switch;
	wire	[31:0]	wire_dataa_switch_ena;
	reg	[31:0]	dffe4a;
	wire	[31:0]	wire_dffe4a_ena;
	reg	dffe5;
	reg	[2:0]	dffe6a;
	wire	[2:0]	wire_dffe6a_ena;
	reg	[0:0]	get_addr_reg;
	reg	idle_state;
	reg	idle_write_wait;
	reg	[0:0]	load_crc_high_reg;
	reg	[0:0]	load_crc_low_reg;
	reg	[0:0]	load_data_reg;
	reg	[0:0]	pof_counter_l42;
	reg	[0:0]	pof_error_reg;
	wire	wire_pof_error_reg_ena;
	reg	re_config_reg;
	reg	read_address_state;
	wire	wire_read_address_state_ena;
	reg	[0:0]	read_control_reg_dffe;
	reg	read_data_state;
	reg	read_init_counter_state;
	reg	read_init_state;
	reg	read_post_state;
	reg	read_pre_data_state;
	reg	[0:0]	reconfig_width_reg;
	reg	[0:0]	ru_reconfig_pof_reg;
	reg	write_data_state;
	reg	write_init_counter_state;
	reg	write_init_state;
	reg	write_load_state;
	reg	write_post_data_state;
	reg	write_pre_data_state;
	reg	write_wait_state;
	wire  [31:0]   wire_add_sub12_result;
	wire  wire_cntr10_cout;
	wire  [7:0]   wire_cntr10_q;
	wire  wire_cntr11_cout;
	wire  [2:0]   wire_cntr11_q;
	wire  [5:0]   wire_cntr2_q;
	wire  [5:0]   wire_cntr3_q;
	wire  [2:0]   wire_cntr7_q;
	wire  [2:0]   wire_cntr8_q;
	wire  [2:0]   wire_cntr9_q;
	wire  wire_shift_reg13_shiftout;
	wire  wire_sd1_regout;
	wire  asmi_read_out;
	wire  asmi_read_wire;
	wire  bit_counter_all_done;
	wire  bit_counter_clear;
	wire  bit_counter_enable;
	wire  [5:0]  bit_counter_param_start;
	wire  bit_counter_param_start_match;
	wire  cal_addr;
	wire  chk_crc_counter_enable;
	wire  chk_pof_counter_enable;
	wire  chk_pof_counter_start;
	wire  [15:0]  crc;
	wire  crc_cal;
	wire  crc_check_end;
	wire  crc_check_st;
	wire  crc_check_st_wire;
	wire  crc_enable_wire;
	wire  [15:0]  crc_reg_wire;
	wire  crc_shift_done;
	wire  get_addr;
	wire  halt_cal;
	wire  idle;
	wire  invert_bits;
	wire  load_crc_high;
	wire  load_crc_low;
	wire  load_data;
	wire  [2:0]  param_addr;
	wire  [2:0]  param_decoder_param_latch;
	wire  [4:0]  param_decoder_select;
	wire  [2:0]  param_port_combine;
	wire  pof_counter_40;
	wire  pof_error_wire;
	wire  power_up;
	wire  read_address;
	wire  read_control_reg;
	wire  read_data;
	wire  read_init;
	wire  read_init_counter;
	wire  read_post;
	wire  read_pre_data;
	wire  ru_reconfig_pof;
	wire  rublock_captnupdt;
	wire  rublock_clock;
	wire  rublock_reconfig;
	wire  rublock_regin;
	wire  rublock_regout;
	wire  rublock_regout_reg;
	wire  rublock_shiftnld;
	wire  select_shift_nloop;
	wire  shift_reg_clear;
	wire  shift_reg_load_enable;
	wire  [31:0]  shift_reg_q;
	wire  shift_reg_serial_in;
	wire  shift_reg_serial_out;
	wire  shift_reg_shift_enable;
	wire  [5:0]  start_bit_decoder_out;
	wire  [4:0]  start_bit_decoder_param_select;
	wire  [5:0]  w22w;
	wire  [5:0]  w53w;
	wire  width_counter_all_done;
	wire  width_counter_clear;
	wire  width_counter_enable;
	wire  [5:0]  width_counter_param_width;
	wire  width_counter_param_width_match;
	wire  [5:0]  width_decoder_out;
	wire  [4:0]  width_decoder_param_select;
	wire  write_data;
	wire  write_init;
	wire  write_init_counter;
	wire  write_load;
	wire  write_post_data;
	wire  write_pre_data;
	wire  write_wait;

	// synopsys translate_off
	initial
		asim_data_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asim_data_reg <= 8'b0;
		else if  (asmi_data_valid == 1'b1)   asim_data_reg <= {asmi_dataout[0], asmi_dataout[1], asmi_dataout[2], asmi_dataout[3], asmi_dataout[4], asmi_dataout[5], asmi_dataout[6], asmi_dataout[7]};
	// synopsys translate_off
	initial
		asmi_addr_st[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[0:0] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[0:0] == 1'b1)   asmi_addr_st[0:0] <= wire_asmi_addr_st_d[0:0];
	// synopsys translate_off
	initial
		asmi_addr_st[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[1:1] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[1:1] == 1'b1)   asmi_addr_st[1:1] <= wire_asmi_addr_st_d[1:1];
	// synopsys translate_off
	initial
		asmi_addr_st[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[2:2] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[2:2] == 1'b1)   asmi_addr_st[2:2] <= wire_asmi_addr_st_d[2:2];
	// synopsys translate_off
	initial
		asmi_addr_st[3:3] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[3:3] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[3:3] == 1'b1)   asmi_addr_st[3:3] <= wire_asmi_addr_st_d[3:3];
	// synopsys translate_off
	initial
		asmi_addr_st[4:4] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[4:4] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[4:4] == 1'b1)   asmi_addr_st[4:4] <= wire_asmi_addr_st_d[4:4];
	// synopsys translate_off
	initial
		asmi_addr_st[5:5] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[5:5] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[5:5] == 1'b1)   asmi_addr_st[5:5] <= wire_asmi_addr_st_d[5:5];
	// synopsys translate_off
	initial
		asmi_addr_st[6:6] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[6:6] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[6:6] == 1'b1)   asmi_addr_st[6:6] <= wire_asmi_addr_st_d[6:6];
	// synopsys translate_off
	initial
		asmi_addr_st[7:7] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[7:7] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[7:7] == 1'b1)   asmi_addr_st[7:7] <= wire_asmi_addr_st_d[7:7];
	// synopsys translate_off
	initial
		asmi_addr_st[8:8] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[8:8] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[8:8] == 1'b1)   asmi_addr_st[8:8] <= wire_asmi_addr_st_d[8:8];
	// synopsys translate_off
	initial
		asmi_addr_st[9:9] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[9:9] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[9:9] == 1'b1)   asmi_addr_st[9:9] <= wire_asmi_addr_st_d[9:9];
	// synopsys translate_off
	initial
		asmi_addr_st[10:10] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[10:10] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[10:10] == 1'b1)   asmi_addr_st[10:10] <= wire_asmi_addr_st_d[10:10];
	// synopsys translate_off
	initial
		asmi_addr_st[11:11] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[11:11] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[11:11] == 1'b1)   asmi_addr_st[11:11] <= wire_asmi_addr_st_d[11:11];
	// synopsys translate_off
	initial
		asmi_addr_st[12:12] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[12:12] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[12:12] == 1'b1)   asmi_addr_st[12:12] <= wire_asmi_addr_st_d[12:12];
	// synopsys translate_off
	initial
		asmi_addr_st[13:13] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[13:13] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[13:13] == 1'b1)   asmi_addr_st[13:13] <= wire_asmi_addr_st_d[13:13];
	// synopsys translate_off
	initial
		asmi_addr_st[14:14] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[14:14] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[14:14] == 1'b1)   asmi_addr_st[14:14] <= wire_asmi_addr_st_d[14:14];
	// synopsys translate_off
	initial
		asmi_addr_st[15:15] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[15:15] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[15:15] == 1'b1)   asmi_addr_st[15:15] <= wire_asmi_addr_st_d[15:15];
	// synopsys translate_off
	initial
		asmi_addr_st[16:16] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[16:16] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[16:16] == 1'b1)   asmi_addr_st[16:16] <= wire_asmi_addr_st_d[16:16];
	// synopsys translate_off
	initial
		asmi_addr_st[17:17] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[17:17] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[17:17] == 1'b1)   asmi_addr_st[17:17] <= wire_asmi_addr_st_d[17:17];
	// synopsys translate_off
	initial
		asmi_addr_st[18:18] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[18:18] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[18:18] == 1'b1)   asmi_addr_st[18:18] <= wire_asmi_addr_st_d[18:18];
	// synopsys translate_off
	initial
		asmi_addr_st[19:19] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[19:19] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[19:19] == 1'b1)   asmi_addr_st[19:19] <= wire_asmi_addr_st_d[19:19];
	// synopsys translate_off
	initial
		asmi_addr_st[20:20] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[20:20] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[20:20] == 1'b1)   asmi_addr_st[20:20] <= wire_asmi_addr_st_d[20:20];
	// synopsys translate_off
	initial
		asmi_addr_st[21:21] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[21:21] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[21:21] == 1'b1)   asmi_addr_st[21:21] <= wire_asmi_addr_st_d[21:21];
	// synopsys translate_off
	initial
		asmi_addr_st[22:22] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[22:22] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[22:22] == 1'b1)   asmi_addr_st[22:22] <= wire_asmi_addr_st_d[22:22];
	// synopsys translate_off
	initial
		asmi_addr_st[23:23] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[23:23] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[23:23] == 1'b1)   asmi_addr_st[23:23] <= wire_asmi_addr_st_d[23:23];
	// synopsys translate_off
	initial
		asmi_addr_st[24:24] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[24:24] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[24:24] == 1'b1)   asmi_addr_st[24:24] <= wire_asmi_addr_st_d[24:24];
	// synopsys translate_off
	initial
		asmi_addr_st[25:25] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[25:25] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[25:25] == 1'b1)   asmi_addr_st[25:25] <= wire_asmi_addr_st_d[25:25];
	// synopsys translate_off
	initial
		asmi_addr_st[26:26] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[26:26] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[26:26] == 1'b1)   asmi_addr_st[26:26] <= wire_asmi_addr_st_d[26:26];
	// synopsys translate_off
	initial
		asmi_addr_st[27:27] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[27:27] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[27:27] == 1'b1)   asmi_addr_st[27:27] <= wire_asmi_addr_st_d[27:27];
	// synopsys translate_off
	initial
		asmi_addr_st[28:28] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[28:28] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[28:28] == 1'b1)   asmi_addr_st[28:28] <= wire_asmi_addr_st_d[28:28];
	// synopsys translate_off
	initial
		asmi_addr_st[29:29] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[29:29] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[29:29] == 1'b1)   asmi_addr_st[29:29] <= wire_asmi_addr_st_d[29:29];
	// synopsys translate_off
	initial
		asmi_addr_st[30:30] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[30:30] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[30:30] == 1'b1)   asmi_addr_st[30:30] <= wire_asmi_addr_st_d[30:30];
	// synopsys translate_off
	initial
		asmi_addr_st[31:31] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_addr_st[31:31] <= 1'b0;
		else if  (wire_asmi_addr_st_ena[31:31] == 1'b1)   asmi_addr_st[31:31] <= wire_asmi_addr_st_d[31:31];
	assign
		wire_asmi_addr_st_d = {((shift_reg_q[23] & get_addr) | (wire_add_sub12_result[31] & asmi_read_wire)), ((shift_reg_q[22] & get_addr) | (wire_add_sub12_result[30] & asmi_read_wire)), ((shift_reg_q[21] & get_addr) | (wire_add_sub12_result[29] & asmi_read_wire)), ((shift_reg_q[20] & get_addr) | (wire_add_sub12_result[28] & asmi_read_wire)), ((shift_reg_q[19] & get_addr) | (wire_add_sub12_result[27] & asmi_read_wire)), ((shift_reg_q[18] & get_addr) | (wire_add_sub12_result[26] & asmi_read_wire)), ((shift_reg_q[17] & get_addr) | (wire_add_sub12_result[25] & asmi_read_wire)), ((shift_reg_q[16] & get_addr) | (wire_add_sub12_result[24] & asmi_read_wire)), ((shift_reg_q[15] & get_addr) | (wire_add_sub12_result[23] & asmi_read_wire)), ((shift_reg_q[14] & get_addr) | (wire_add_sub12_result[22] & asmi_read_wire)), ((shift_reg_q[13] & get_addr) | (wire_add_sub12_result[21] & asmi_read_wire)), ((shift_reg_q[12] & get_addr) | (wire_add_sub12_result[20] & asmi_read_wire)), ((shift_reg_q[11] & get_addr) | (wire_add_sub12_result[19] & asmi_read_wire)), ((shift_reg_q[10] & get_addr) | (wire_add_sub12_result[18] & asmi_read_wire)), ((shift_reg_q[9] & get_addr) | (wire_add_sub12_result[17] & asmi_read_wire)), ((shift_reg_q[8] & get_addr) | (wire_add_sub12_result[16] & asmi_read_wire)), ((shift_reg_q[7] & get_addr) | (wire_add_sub12_result[15] & asmi_read_wire)), ((shift_reg_q[6] & get_addr) | (wire_add_sub12_result[14] & asmi_read_wire)), ((shift_reg_q[5] & get_addr) | (wire_add_sub12_result[13] & asmi_read_wire)), ((shift_reg_q[4] & get_addr) | (wire_add_sub12_result[12] & asmi_read_wire)), ((shift_reg_q[3] & get_addr) | (wire_add_sub12_result[11] & asmi_read_wire)), ((shift_reg_q[2] & get_addr) | (wire_add_sub12_result[10] & asmi_read_wire)), ((shift_reg_q[1] & get_addr) | (wire_add_sub12_result[9] & asmi_read_wire)), ((shift_reg_q[0] & get_addr) | (wire_add_sub12_result[8] & asmi_read_wire)), (wire_add_sub12_result[7] & asmi_read_wire), (wire_add_sub12_result[6] & asmi_read_wire), (wire_add_sub12_result[5] & asmi_read_wire), (wire_add_sub12_result[4]
 & asmi_read_wire), (wire_add_sub12_result[3] & asmi_read_wire), (wire_add_sub12_result[2] & asmi_read_wire), (wire_add_sub12_result[1] & asmi_read_wire), (wire_add_sub12_result[0] & asmi_read_wire)};
	assign
		wire_asmi_addr_st_ena = {32{(get_addr | asmi_read_wire)}};
	// synopsys translate_off
	initial
		asmi_read_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) asmi_read_reg <= 1'b0;
		else if  (check_busy_dffe == 1'b1)   asmi_read_reg <= ((wire_cntr8_q[2] & (~ wire_cntr8_q[1])) & wire_cntr8_q[0]);
	// synopsys translate_off
	initial
		cal_addr_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) cal_addr_reg <= 1'b0;
		else if  (check_busy_dffe == 1'b1)   cal_addr_reg <= (get_addr_reg | ((wire_cntr8_q[2] & (~ wire_cntr8_q[1])) & (~ wire_cntr8_q[0])));
	// synopsys translate_off
	initial
		check_busy_dffe = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) check_busy_dffe <= 1'b0;
		else  check_busy_dffe <= ((wire_cntr7_q[2] | wire_cntr7_q[1]) | wire_cntr7_q[0]);
	// synopsys translate_off
	initial
		crc_cal_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) crc_cal_reg <= 1'b0;
		else  crc_cal_reg <= (((~ wire_cntr8_q[2]) & wire_cntr8_q[1]) & wire_cntr8_q[0]);
	// synopsys translate_off
	initial
		crc_check_end_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) crc_check_end_reg <= 1'b0;
		else  crc_check_end_reg <= (((wire_cntr7_q[2] & wire_cntr7_q[1]) & (~ wire_cntr7_q[0])) & wire_cntr10_cout);
	// synopsys translate_off
	initial
		crc_chk_st_dffe = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) crc_chk_st_dffe <= 1'b0;
		else  crc_chk_st_dffe <= crc_check_st_wire;
	// synopsys translate_off
	initial
		crc_done_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) crc_done_reg <= 1'b0;
		else if  (wire_crc_done_reg_ena == 1'b1) 
			if (chk_pof_counter_start == 1'b1) crc_done_reg <= 1'b0;
			else  crc_done_reg <= pof_counter_40;
	assign
		wire_crc_done_reg_ena = (pof_counter_40 | chk_pof_counter_start);
	// synopsys translate_off
	initial
		crc_high = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) crc_high <= 8'b0;
		else if  (load_crc_high == 1'b1)   crc_high <= asim_data_reg;
	// synopsys translate_off
	initial
		crc_low = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) crc_low <= 8'b0;
		else if  (load_crc_low == 1'b1)   crc_low <= asim_data_reg;
	// synopsys translate_off
	initial
		crc_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) crc_reg <= {16{1'b1}};
		else if  (crc_enable_wire == 1'b1) 
			if (crc_check_st_wire == 1'b1) crc_reg <= {{1{1'b1}}, {15{1'b1}}};
			else  crc_reg <= crc_reg_wire;
	// synopsys translate_off
	initial
		dataa_switch[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[0:0] <= 1'b0;
		else if  (wire_dataa_switch_ena[0:0] == 1'b1)   dataa_switch[0:0] <= wire_dataa_switch_d[0:0];
	// synopsys translate_off
	initial
		dataa_switch[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[1:1] <= 1'b0;
		else if  (wire_dataa_switch_ena[1:1] == 1'b1)   dataa_switch[1:1] <= wire_dataa_switch_d[1:1];
	// synopsys translate_off
	initial
		dataa_switch[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[2:2] <= 1'b0;
		else if  (wire_dataa_switch_ena[2:2] == 1'b1)   dataa_switch[2:2] <= wire_dataa_switch_d[2:2];
	// synopsys translate_off
	initial
		dataa_switch[3:3] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[3:3] <= 1'b0;
		else if  (wire_dataa_switch_ena[3:3] == 1'b1)   dataa_switch[3:3] <= wire_dataa_switch_d[3:3];
	// synopsys translate_off
	initial
		dataa_switch[4:4] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[4:4] <= 1'b0;
		else if  (wire_dataa_switch_ena[4:4] == 1'b1)   dataa_switch[4:4] <= wire_dataa_switch_d[4:4];
	// synopsys translate_off
	initial
		dataa_switch[5:5] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[5:5] <= 1'b0;
		else if  (wire_dataa_switch_ena[5:5] == 1'b1)   dataa_switch[5:5] <= wire_dataa_switch_d[5:5];
	// synopsys translate_off
	initial
		dataa_switch[6:6] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[6:6] <= 1'b0;
		else if  (wire_dataa_switch_ena[6:6] == 1'b1)   dataa_switch[6:6] <= wire_dataa_switch_d[6:6];
	// synopsys translate_off
	initial
		dataa_switch[7:7] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[7:7] <= 1'b0;
		else if  (wire_dataa_switch_ena[7:7] == 1'b1)   dataa_switch[7:7] <= wire_dataa_switch_d[7:7];
	// synopsys translate_off
	initial
		dataa_switch[8:8] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[8:8] <= 1'b0;
		else if  (wire_dataa_switch_ena[8:8] == 1'b1)   dataa_switch[8:8] <= wire_dataa_switch_d[8:8];
	// synopsys translate_off
	initial
		dataa_switch[9:9] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[9:9] <= 1'b0;
		else if  (wire_dataa_switch_ena[9:9] == 1'b1)   dataa_switch[9:9] <= wire_dataa_switch_d[9:9];
	// synopsys translate_off
	initial
		dataa_switch[10:10] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[10:10] <= 1'b0;
		else if  (wire_dataa_switch_ena[10:10] == 1'b1)   dataa_switch[10:10] <= wire_dataa_switch_d[10:10];
	// synopsys translate_off
	initial
		dataa_switch[11:11] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[11:11] <= 1'b0;
		else if  (wire_dataa_switch_ena[11:11] == 1'b1)   dataa_switch[11:11] <= wire_dataa_switch_d[11:11];
	// synopsys translate_off
	initial
		dataa_switch[12:12] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[12:12] <= 1'b0;
		else if  (wire_dataa_switch_ena[12:12] == 1'b1)   dataa_switch[12:12] <= wire_dataa_switch_d[12:12];
	// synopsys translate_off
	initial
		dataa_switch[13:13] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[13:13] <= 1'b0;
		else if  (wire_dataa_switch_ena[13:13] == 1'b1)   dataa_switch[13:13] <= wire_dataa_switch_d[13:13];
	// synopsys translate_off
	initial
		dataa_switch[14:14] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[14:14] <= 1'b0;
		else if  (wire_dataa_switch_ena[14:14] == 1'b1)   dataa_switch[14:14] <= wire_dataa_switch_d[14:14];
	// synopsys translate_off
	initial
		dataa_switch[15:15] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[15:15] <= 1'b0;
		else if  (wire_dataa_switch_ena[15:15] == 1'b1)   dataa_switch[15:15] <= wire_dataa_switch_d[15:15];
	// synopsys translate_off
	initial
		dataa_switch[16:16] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[16:16] <= 1'b0;
		else if  (wire_dataa_switch_ena[16:16] == 1'b1)   dataa_switch[16:16] <= wire_dataa_switch_d[16:16];
	// synopsys translate_off
	initial
		dataa_switch[17:17] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[17:17] <= 1'b0;
		else if  (wire_dataa_switch_ena[17:17] == 1'b1)   dataa_switch[17:17] <= wire_dataa_switch_d[17:17];
	// synopsys translate_off
	initial
		dataa_switch[18:18] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[18:18] <= 1'b0;
		else if  (wire_dataa_switch_ena[18:18] == 1'b1)   dataa_switch[18:18] <= wire_dataa_switch_d[18:18];
	// synopsys translate_off
	initial
		dataa_switch[19:19] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[19:19] <= 1'b0;
		else if  (wire_dataa_switch_ena[19:19] == 1'b1)   dataa_switch[19:19] <= wire_dataa_switch_d[19:19];
	// synopsys translate_off
	initial
		dataa_switch[20:20] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[20:20] <= 1'b0;
		else if  (wire_dataa_switch_ena[20:20] == 1'b1)   dataa_switch[20:20] <= wire_dataa_switch_d[20:20];
	// synopsys translate_off
	initial
		dataa_switch[21:21] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[21:21] <= 1'b0;
		else if  (wire_dataa_switch_ena[21:21] == 1'b1)   dataa_switch[21:21] <= wire_dataa_switch_d[21:21];
	// synopsys translate_off
	initial
		dataa_switch[22:22] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[22:22] <= 1'b0;
		else if  (wire_dataa_switch_ena[22:22] == 1'b1)   dataa_switch[22:22] <= wire_dataa_switch_d[22:22];
	// synopsys translate_off
	initial
		dataa_switch[23:23] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[23:23] <= 1'b0;
		else if  (wire_dataa_switch_ena[23:23] == 1'b1)   dataa_switch[23:23] <= wire_dataa_switch_d[23:23];
	// synopsys translate_off
	initial
		dataa_switch[24:24] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[24:24] <= 1'b0;
		else if  (wire_dataa_switch_ena[24:24] == 1'b1)   dataa_switch[24:24] <= wire_dataa_switch_d[24:24];
	// synopsys translate_off
	initial
		dataa_switch[25:25] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[25:25] <= 1'b0;
		else if  (wire_dataa_switch_ena[25:25] == 1'b1)   dataa_switch[25:25] <= wire_dataa_switch_d[25:25];
	// synopsys translate_off
	initial
		dataa_switch[26:26] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[26:26] <= 1'b0;
		else if  (wire_dataa_switch_ena[26:26] == 1'b1)   dataa_switch[26:26] <= wire_dataa_switch_d[26:26];
	// synopsys translate_off
	initial
		dataa_switch[27:27] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[27:27] <= 1'b0;
		else if  (wire_dataa_switch_ena[27:27] == 1'b1)   dataa_switch[27:27] <= wire_dataa_switch_d[27:27];
	// synopsys translate_off
	initial
		dataa_switch[28:28] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[28:28] <= 1'b0;
		else if  (wire_dataa_switch_ena[28:28] == 1'b1)   dataa_switch[28:28] <= wire_dataa_switch_d[28:28];
	// synopsys translate_off
	initial
		dataa_switch[29:29] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[29:29] <= 1'b0;
		else if  (wire_dataa_switch_ena[29:29] == 1'b1)   dataa_switch[29:29] <= wire_dataa_switch_d[29:29];
	// synopsys translate_off
	initial
		dataa_switch[30:30] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[30:30] <= 1'b0;
		else if  (wire_dataa_switch_ena[30:30] == 1'b1)   dataa_switch[30:30] <= wire_dataa_switch_d[30:30];
	// synopsys translate_off
	initial
		dataa_switch[31:31] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dataa_switch[31:31] <= 1'b0;
		else if  (wire_dataa_switch_ena[31:31] == 1'b1)   dataa_switch[31:31] <= wire_dataa_switch_d[31:31];
	assign
		wire_dataa_switch_d = {{24{1'b0}}, (get_addr & (~ crc_check_st)), {4{1'b0}}, (get_addr & (~ crc_check_st)), 1'b0, ((~ get_addr) & crc_check_st)};
	assign
		wire_dataa_switch_ena = {32{(get_addr | crc_check_st)}};
	// synopsys translate_off
	initial
		dffe4a[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[0:0] <= 1'b0;
		else if  (wire_dffe4a_ena[0:0] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[0:0] <= 1'b0;
			else  dffe4a[0:0] <= ((shift_reg_load_enable & ((((data_in[8] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[0] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[1:1]));
	// synopsys translate_off
	initial
		dffe4a[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[1:1] <= 1'b0;
		else if  (wire_dffe4a_ena[1:1] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[1:1] <= 1'b0;
			else  dffe4a[1:1] <= ((shift_reg_load_enable & ((((data_in[9] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[1] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[2:2]));
	// synopsys translate_off
	initial
		dffe4a[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[2:2] <= 1'b0;
		else if  (wire_dffe4a_ena[2:2] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[2:2] <= 1'b0;
			else  dffe4a[2:2] <= ((shift_reg_load_enable & ((((data_in[10] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[2] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[3:3]));
	// synopsys translate_off
	initial
		dffe4a[3:3] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[3:3] <= 1'b0;
		else if  (wire_dffe4a_ena[3:3] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[3:3] <= 1'b0;
			else  dffe4a[3:3] <= ((shift_reg_load_enable & ((((data_in[11] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[3] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[4:4]));
	// synopsys translate_off
	initial
		dffe4a[4:4] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[4:4] <= 1'b0;
		else if  (wire_dffe4a_ena[4:4] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[4:4] <= 1'b0;
			else  dffe4a[4:4] <= ((shift_reg_load_enable & ((((data_in[12] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[4] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[5:5]));
	// synopsys translate_off
	initial
		dffe4a[5:5] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[5:5] <= 1'b0;
		else if  (wire_dffe4a_ena[5:5] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[5:5] <= 1'b0;
			else  dffe4a[5:5] <= ((shift_reg_load_enable & ((((data_in[13] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[5] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[6:6]));
	// synopsys translate_off
	initial
		dffe4a[6:6] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[6:6] <= 1'b0;
		else if  (wire_dffe4a_ena[6:6] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[6:6] <= 1'b0;
			else  dffe4a[6:6] <= ((shift_reg_load_enable & ((((data_in[14] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[6] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[7:7]));
	// synopsys translate_off
	initial
		dffe4a[7:7] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[7:7] <= 1'b0;
		else if  (wire_dffe4a_ena[7:7] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[7:7] <= 1'b0;
			else  dffe4a[7:7] <= ((shift_reg_load_enable & ((((data_in[15] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[7] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[8:8]));
	// synopsys translate_off
	initial
		dffe4a[8:8] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[8:8] <= 1'b0;
		else if  (wire_dffe4a_ena[8:8] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[8:8] <= 1'b0;
			else  dffe4a[8:8] <= ((shift_reg_load_enable & ((((data_in[16] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[8] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[9:9]));
	// synopsys translate_off
	initial
		dffe4a[9:9] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[9:9] <= 1'b0;
		else if  (wire_dffe4a_ena[9:9] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[9:9] <= 1'b0;
			else  dffe4a[9:9] <= ((shift_reg_load_enable & ((((data_in[17] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[9] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[10:10]));
	// synopsys translate_off
	initial
		dffe4a[10:10] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[10:10] <= 1'b0;
		else if  (wire_dffe4a_ena[10:10] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[10:10] <= 1'b0;
			else  dffe4a[10:10] <= ((shift_reg_load_enable & ((((data_in[18] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[10] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[11:11]));
	// synopsys translate_off
	initial
		dffe4a[11:11] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[11:11] <= 1'b0;
		else if  (wire_dffe4a_ena[11:11] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[11:11] <= 1'b0;
			else  dffe4a[11:11] <= ((shift_reg_load_enable & ((((data_in[19] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[11] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[12:12]));
	// synopsys translate_off
	initial
		dffe4a[12:12] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[12:12] <= 1'b0;
		else if  (wire_dffe4a_ena[12:12] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[12:12] <= 1'b0;
			else  dffe4a[12:12] <= ((shift_reg_load_enable & ((((data_in[20] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[12] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[13:13]));
	// synopsys translate_off
	initial
		dffe4a[13:13] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[13:13] <= 1'b0;
		else if  (wire_dffe4a_ena[13:13] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[13:13] <= 1'b0;
			else  dffe4a[13:13] <= ((shift_reg_load_enable & ((((data_in[21] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[13] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[14:14]));
	// synopsys translate_off
	initial
		dffe4a[14:14] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[14:14] <= 1'b0;
		else if  (wire_dffe4a_ena[14:14] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[14:14] <= 1'b0;
			else  dffe4a[14:14] <= ((shift_reg_load_enable & ((((data_in[22] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[14] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[15:15]));
	// synopsys translate_off
	initial
		dffe4a[15:15] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[15:15] <= 1'b0;
		else if  (wire_dffe4a_ena[15:15] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[15:15] <= 1'b0;
			else  dffe4a[15:15] <= ((shift_reg_load_enable & ((((data_in[23] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[15] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[16:16]));
	// synopsys translate_off
	initial
		dffe4a[16:16] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[16:16] <= 1'b0;
		else if  (wire_dffe4a_ena[16:16] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[16:16] <= 1'b0;
			else  dffe4a[16:16] <= ((shift_reg_load_enable & ((((data_in[24] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[16] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[17:17]));
	// synopsys translate_off
	initial
		dffe4a[17:17] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[17:17] <= 1'b0;
		else if  (wire_dffe4a_ena[17:17] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[17:17] <= 1'b0;
			else  dffe4a[17:17] <= ((shift_reg_load_enable & ((((data_in[25] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[17] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[18:18]));
	// synopsys translate_off
	initial
		dffe4a[18:18] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[18:18] <= 1'b0;
		else if  (wire_dffe4a_ena[18:18] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[18:18] <= 1'b0;
			else  dffe4a[18:18] <= ((shift_reg_load_enable & ((((data_in[26] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[18] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[19:19]));
	// synopsys translate_off
	initial
		dffe4a[19:19] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[19:19] <= 1'b0;
		else if  (wire_dffe4a_ena[19:19] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[19:19] <= 1'b0;
			else  dffe4a[19:19] <= ((shift_reg_load_enable & ((((data_in[27] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[19] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[20:20]));
	// synopsys translate_off
	initial
		dffe4a[20:20] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[20:20] <= 1'b0;
		else if  (wire_dffe4a_ena[20:20] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[20:20] <= 1'b0;
			else  dffe4a[20:20] <= ((shift_reg_load_enable & ((((data_in[28] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[20] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[21:21]));
	// synopsys translate_off
	initial
		dffe4a[21:21] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[21:21] <= 1'b0;
		else if  (wire_dffe4a_ena[21:21] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[21:21] <= 1'b0;
			else  dffe4a[21:21] <= ((shift_reg_load_enable & ((((data_in[29] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[21] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[22:22]));
	// synopsys translate_off
	initial
		dffe4a[22:22] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[22:22] <= 1'b0;
		else if  (wire_dffe4a_ena[22:22] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[22:22] <= 1'b0;
			else  dffe4a[22:22] <= ((shift_reg_load_enable & ((((data_in[30] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[22] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[23:23]));
	// synopsys translate_off
	initial
		dffe4a[23:23] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[23:23] <= 1'b0;
		else if  (wire_dffe4a_ena[23:23] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[23:23] <= 1'b0;
			else  dffe4a[23:23] <= ((shift_reg_load_enable & ((((data_in[31] & param[2]) & (~ param[1])) & (~ param[0])) | (data_in[23] & (~ ((param[2] & (~ param[1])) & (~ param[0])))))) | ((~ shift_reg_load_enable) & dffe4a[24:24]));
	// synopsys translate_off
	initial
		dffe4a[24:24] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[24:24] <= 1'b0;
		else if  (wire_dffe4a_ena[24:24] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[24:24] <= 1'b0;
			else  dffe4a[24:24] <= ((~ shift_reg_load_enable) & dffe4a[25:25]);
	// synopsys translate_off
	initial
		dffe4a[25:25] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[25:25] <= 1'b0;
		else if  (wire_dffe4a_ena[25:25] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[25:25] <= 1'b0;
			else  dffe4a[25:25] <= ((~ shift_reg_load_enable) & dffe4a[26:26]);
	// synopsys translate_off
	initial
		dffe4a[26:26] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[26:26] <= 1'b0;
		else if  (wire_dffe4a_ena[26:26] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[26:26] <= 1'b0;
			else  dffe4a[26:26] <= ((~ shift_reg_load_enable) & dffe4a[27:27]);
	// synopsys translate_off
	initial
		dffe4a[27:27] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[27:27] <= 1'b0;
		else if  (wire_dffe4a_ena[27:27] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[27:27] <= 1'b0;
			else  dffe4a[27:27] <= ((~ shift_reg_load_enable) & dffe4a[28:28]);
	// synopsys translate_off
	initial
		dffe4a[28:28] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[28:28] <= 1'b0;
		else if  (wire_dffe4a_ena[28:28] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[28:28] <= 1'b0;
			else  dffe4a[28:28] <= ((~ shift_reg_load_enable) & dffe4a[29:29]);
	// synopsys translate_off
	initial
		dffe4a[29:29] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[29:29] <= 1'b0;
		else if  (wire_dffe4a_ena[29:29] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[29:29] <= 1'b0;
			else  dffe4a[29:29] <= ((~ shift_reg_load_enable) & dffe4a[30:30]);
	// synopsys translate_off
	initial
		dffe4a[30:30] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[30:30] <= 1'b0;
		else if  (wire_dffe4a_ena[30:30] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[30:30] <= 1'b0;
			else  dffe4a[30:30] <= ((~ shift_reg_load_enable) & dffe4a[31:31]);
	// synopsys translate_off
	initial
		dffe4a[31:31] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe4a[31:31] <= 1'b0;
		else if  (wire_dffe4a_ena[31:31] == 1'b1) 
			if (shift_reg_clear == 1'b1) dffe4a[31:31] <= 1'b0;
			else  dffe4a[31:31] <= ((~ shift_reg_load_enable) & shift_reg_serial_in);
	assign
		wire_dffe4a_ena = {32{((shift_reg_load_enable | shift_reg_shift_enable) | shift_reg_clear)}};
	// synopsys translate_off
	initial
		dffe5 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe5 <= 1'b0;
		else  dffe5 <= rublock_regout;
	// synopsys translate_off
	initial
		dffe6a[0:0] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe6a[0:0] <= 1'b0;
		else if  (wire_dffe6a_ena[0:0] == 1'b1)   dffe6a[0:0] <= param_port_combine[0:0];
	// synopsys translate_off
	initial
		dffe6a[1:1] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe6a[1:1] <= 1'b0;
		else if  (wire_dffe6a_ena[1:1] == 1'b1)   dffe6a[1:1] <= param_port_combine[1:1];
	// synopsys translate_off
	initial
		dffe6a[2:2] = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) dffe6a[2:2] <= 1'b0;
		else if  (wire_dffe6a_ena[2:2] == 1'b1)   dffe6a[2:2] <= param_port_combine[2:2];
	assign
		wire_dffe6a_ena = {3{(idle & ((write_param | read_param) | read_control_reg))}};
	// synopsys translate_off
	initial
		get_addr_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) get_addr_reg <= 1'b0;
		else  get_addr_reg <= (((~ wire_cntr7_q[2]) & wire_cntr7_q[1]) & wire_cntr7_q[0]);
	// synopsys translate_off
	initial
		idle_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) idle_state <= {1{1'b1}};
		else  idle_state <= ((((((((idle & (~ read_param)) & (~ write_param)) & (~ read_control_reg)) | write_wait) | (read_data & width_counter_all_done)) | (read_post & width_counter_all_done)) | power_up) & (~ check_busy_dffe));
	// synopsys translate_off
	initial
		idle_write_wait = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) idle_write_wait <= 1'b0;
		else  idle_write_wait <= ((((((((idle & (~ read_param)) & (~ write_param)) & (~ read_control_reg)) | write_wait) | (read_data & width_counter_all_done)) | (read_post & width_counter_all_done)) | power_up) & write_load);
	// synopsys translate_off
	initial
		load_crc_high_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) load_crc_high_reg <= 1'b0;
		else  load_crc_high_reg <= ((((~ wire_cntr8_q[2]) & wire_cntr8_q[1]) & (~ wire_cntr8_q[0])) & (((((((wire_cntr10_q[7] & (~ wire_cntr10_q[6])) & wire_cntr10_q[5]) & (~ wire_cntr10_q[4])) & (~ wire_cntr10_q[3])) & (~ wire_cntr10_q[2])) & wire_cntr10_q[1]) & wire_cntr10_q[0]));
	// synopsys translate_off
	initial
		load_crc_low_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) load_crc_low_reg <= 1'b0;
		else  load_crc_low_reg <= ((((~ wire_cntr8_q[2]) & wire_cntr8_q[1]) & (~ wire_cntr8_q[0])) & (((((((wire_cntr10_q[7] & (~ wire_cntr10_q[6])) & wire_cntr10_q[5]) & (~ wire_cntr10_q[4])) & (~ wire_cntr10_q[3])) & (~ wire_cntr10_q[2])) & wire_cntr10_q[1]) & (~ wire_cntr10_q[0])));
	// synopsys translate_off
	initial
		load_data_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) load_data_reg <= 1'b0;
		else  load_data_reg <= (((~ wire_cntr8_q[2]) & wire_cntr8_q[1]) & (~ wire_cntr8_q[0]));
	// synopsys translate_off
	initial
		pof_counter_l42 = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) pof_counter_l42 <= 1'b0;
		else
			if (crc_check_st_wire == 1'b1) pof_counter_l42 <= 1'b0;
			else  pof_counter_l42 <= ((((wire_cntr10_q[7] & wire_cntr10_q[5]) & wire_cntr10_q[1]) & wire_cntr10_q[0]) | ((wire_cntr10_q[7] & wire_cntr10_q[5]) & wire_cntr10_q[2]));
	// synopsys translate_off
	initial
		pof_error_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) pof_error_reg <= 1'b0;
		else if  (wire_pof_error_reg_ena == 1'b1) 
			if (crc_check_st_wire == 1'b1) pof_error_reg <= 1'b0;
			else  pof_error_reg <= pof_error_wire;
	assign
		wire_pof_error_reg_ena = (crc_check_end | crc_check_st_wire);
	// synopsys translate_off
	initial
		re_config_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) re_config_reg <= 1'b0;
		else
			if (crc_check_st_wire == 1'b1) re_config_reg <= 1'b0;
			else  re_config_reg <= (ru_reconfig_pof & (~ pof_error_reg));
	// synopsys translate_off
	initial
		read_address_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) read_address_state <= 1'b0;
		else if  (wire_read_address_state_ena == 1'b1)   read_address_state <= (((read_param | write_param) & ((param[2] & (~ param[1])) & (~ param[0]))) & (~ (((~ idle) | check_busy_dffe) | ru_reconfig_pof)));
	assign
		wire_read_address_state_ena = (read_param | write_param);
	// synopsys translate_off
	initial
		read_control_reg_dffe = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) read_control_reg_dffe <= 1'b0;
		else  read_control_reg_dffe <= (((~ wire_cntr7_q[2]) & (~ wire_cntr7_q[1])) & wire_cntr7_q[0]);
	// synopsys translate_off
	initial
		read_data_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) read_data_state <= 1'b0;
		else  read_data_state <= (((read_init_counter & bit_counter_param_start_match) | (read_pre_data & bit_counter_param_start_match)) | ((read_data & (~ width_counter_param_width_match)) & (~ width_counter_all_done)));
	// synopsys translate_off
	initial
		read_init_counter_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) read_init_counter_state <= 1'b0;
		else  read_init_counter_state <= read_init;
	// synopsys translate_off
	initial
		read_init_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) read_init_state <= 1'b0;
		else  read_init_state <= (idle & (read_param | read_control_reg));
	// synopsys translate_off
	initial
		read_post_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) read_post_state <= 1'b0;
		else  read_post_state <= (((read_data & width_counter_param_width_match) & (~ width_counter_all_done)) | (read_post & (~ width_counter_all_done)));
	// synopsys translate_off
	initial
		read_pre_data_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) read_pre_data_state <= 1'b0;
		else  read_pre_data_state <= ((read_init_counter & (~ bit_counter_param_start_match)) | (read_pre_data & (~ bit_counter_param_start_match)));
	// synopsys translate_off
	initial
		reconfig_width_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) reconfig_width_reg <= 1'b0;
		else
			if (wire_cntr11_cout == 1'b1) reconfig_width_reg <= 1'b0;
			else  reconfig_width_reg <= (((wire_cntr7_q[2] & wire_cntr7_q[1]) & wire_cntr7_q[0]) | reconfig_width_reg);
	// synopsys translate_off
	initial
		ru_reconfig_pof_reg = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) ru_reconfig_pof_reg <= 1'b0;
		else  ru_reconfig_pof_reg <= (((wire_cntr7_q[2] & wire_cntr7_q[1]) & wire_cntr7_q[0]) | ((wire_cntr11_q[2] | wire_cntr11_q[1]) | wire_cntr11_q[0]));
	// synopsys translate_off
	initial
		write_data_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) write_data_state <= 1'b0;
		else  write_data_state <= (((write_init_counter & bit_counter_param_start_match) | (write_pre_data & bit_counter_param_start_match)) | ((write_data & (~ width_counter_param_width_match)) & (~ bit_counter_all_done)));
	// synopsys translate_off
	initial
		write_init_counter_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) write_init_counter_state <= 1'b0;
		else  write_init_counter_state <= write_init;
	// synopsys translate_off
	initial
		write_init_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) write_init_state <= 1'b0;
		else  write_init_state <= (idle & write_param);
	// synopsys translate_off
	initial
		write_load_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) write_load_state <= 1'b0;
		else  write_load_state <= ((write_data & bit_counter_all_done) | (write_post_data & bit_counter_all_done));
	// synopsys translate_off
	initial
		write_post_data_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) write_post_data_state <= 1'b0;
		else  write_post_data_state <= (((write_data & width_counter_param_width_match) & (~ bit_counter_all_done)) | (write_post_data & (~ bit_counter_all_done)));
	// synopsys translate_off
	initial
		write_pre_data_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) write_pre_data_state <= 1'b0;
		else  write_pre_data_state <= ((write_init_counter & (~ bit_counter_param_start_match)) | (write_pre_data & (~ bit_counter_param_start_match)));
	// synopsys translate_off
	initial
		write_wait_state = 0;
	// synopsys translate_on
	always @ ( posedge clock or  posedge reset)
		if (reset == 1'b1) write_wait_state <= 1'b0;
		else  write_wait_state <= write_load;
	lpm_add_sub   add_sub12
	( 
	.aclr(reset),
	.clken(cal_addr),
	.clock(clock),
	.cout(),
	.dataa(dataa_switch),
	.datab(asmi_addr_st),
	.overflow(),
	.result(wire_add_sub12_result)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.add_sub(1'b1),
	.cin()
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		add_sub12.lpm_direction = "ADD",
		add_sub12.lpm_pipeline = 1,
		add_sub12.lpm_width = 32,
		add_sub12.lpm_type = "lpm_add_sub";
	lpm_counter   cntr10
	( 
	.aclr(reset),
	.clk_en((asmi_read_wire | ((wire_cntr7_q[2] & (~ wire_cntr7_q[1])) & wire_cntr7_q[0]))),
	.clock(clock),
	.cout(wire_cntr10_cout),
	.eq(),
	.q(wire_cntr10_q),
	.sclr(crc_check_st)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.cnt_en(1'b1),
	.data({8{1'b0}}),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr10.lpm_modulus = 165,
		cntr10.lpm_port_updown = "PORT_UNUSED",
		cntr10.lpm_width = 8,
		cntr10.lpm_type = "lpm_counter";
	lpm_counter   cntr11
	( 
	.aclr(reset),
	.clk_en((((wire_cntr7_q[2] & wire_cntr7_q[1]) & wire_cntr7_q[0]) | reconfig_width_reg)),
	.clock(clock),
	.cout(wire_cntr11_cout),
	.eq(),
	.q(wire_cntr11_q)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.cnt_en(1'b1),
	.data({3{1'b0}}),
	.sclr(1'b0),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr11.lpm_modulus = 4,
		cntr11.lpm_port_updown = "PORT_UNUSED",
		cntr11.lpm_width = 3,
		cntr11.lpm_type = "lpm_counter";
	lpm_counter   cntr2
	( 
	.aclr(reset),
	.clock(clock),
	.cnt_en(bit_counter_enable),
	.cout(),
	.eq(),
	.q(wire_cntr2_q),
	.sclr(bit_counter_clear)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.clk_en(1'b1),
	.data({6{1'b0}}),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr2.lpm_direction = "UP",
		cntr2.lpm_port_updown = "PORT_UNUSED",
		cntr2.lpm_width = 6,
		cntr2.lpm_type = "lpm_counter";
	lpm_counter   cntr3
	( 
	.aclr(reset),
	.clock(clock),
	.cnt_en(width_counter_enable),
	.cout(),
	.eq(),
	.q(wire_cntr3_q),
	.sclr(width_counter_clear)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.clk_en(1'b1),
	.data({6{1'b0}}),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr3.lpm_direction = "UP",
		cntr3.lpm_port_updown = "PORT_UNUSED",
		cntr3.lpm_width = 6,
		cntr3.lpm_type = "lpm_counter";
	lpm_counter   cntr7
	( 
	.aclr(reset),
	.clk_en(chk_pof_counter_enable),
	.clock(clock),
	.cout(),
	.eq(),
	.q(wire_cntr7_q)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.cnt_en(1'b1),
	.data({3{1'b0}}),
	.sclr(1'b0),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr7.lpm_port_updown = "PORT_UNUSED",
		cntr7.lpm_width = 3,
		cntr7.lpm_type = "lpm_counter";
	lpm_counter   cntr8
	( 
	.aclr(reset),
	.clk_en(chk_crc_counter_enable),
	.clock(clock),
	.cout(),
	.data({{2{1'b0}}, 1'b1}),
	.eq(),
	.q(wire_cntr8_q),
	.sload(asmi_read_reg)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.cnt_en(1'b1),
	.sclr(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr8.lpm_modulus = 7,
		cntr8.lpm_port_updown = "PORT_UNUSED",
		cntr8.lpm_width = 3,
		cntr8.lpm_type = "lpm_counter";
	lpm_counter   cntr9
	( 
	.aclr(reset),
	.clk_en(crc_cal_reg),
	.clock(clock),
	.cout(),
	.eq(),
	.q(wire_cntr9_q)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aload(1'b0),
	.aset(1'b0),
	.cin(1'b1),
	.cnt_en(1'b1),
	.data({3{1'b0}}),
	.sclr(1'b0),
	.sload(1'b0),
	.sset(1'b0),
	.updown(1'b1)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		cntr9.lpm_modulus = 8,
		cntr9.lpm_port_updown = "PORT_UNUSED",
		cntr9.lpm_width = 3,
		cntr9.lpm_type = "lpm_counter";
	lpm_shiftreg   shift_reg13
	( 
	.aclr(reset),
	.clock(clock),
	.data(asim_data_reg),
	.enable((crc_cal | load_data)),
	.load(load_data),
	.q(),
	.sclr(crc_check_st),
	.shiftout(wire_shift_reg13_shiftout)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_off
	`endif
	,
	.aset(1'b0),
	.shiftin(1'b1),
	.sset(1'b0)
	`ifndef FORMAL_VERIFICATION
	// synopsys translate_on
	`endif
	);
	defparam
		shift_reg13.lpm_direction = "RIGHT",
		shift_reg13.lpm_width = 8,
		shift_reg13.lpm_type = "lpm_shiftreg";
	cyclonev_rublock   sd1
	( 
	.captnupdt(rublock_captnupdt),
	.clk(rublock_clock),
	.rconfig(rublock_reconfig),
	.regin(rublock_regin),
	.regout(wire_sd1_regout),
	.rsttimer(reset_timer),
	.shiftnld(rublock_shiftnld));
	assign
		asmi_addr = wire_add_sub12_result,
		asmi_rden = asmi_read_out,
		asmi_read = asmi_read_out,
		asmi_read_out = ((crc_chk_st_dffe | asmi_read_reg) & (~ pof_counter_l42)),
		asmi_read_wire = (crc_chk_st_dffe | asmi_read_reg),
		bit_counter_all_done = (((((wire_cntr2_q[0] & wire_cntr2_q[1]) & (~ wire_cntr2_q[2])) & wire_cntr2_q[3]) & (~ wire_cntr2_q[4])) & wire_cntr2_q[5]),
		bit_counter_clear = (read_init | write_init),
		bit_counter_enable = (((((((((read_init | write_init) | read_init_counter) | write_init_counter) | read_pre_data) | write_pre_data) | read_data) | write_data) | read_post) | write_post_data),
		bit_counter_param_start = start_bit_decoder_out,
		bit_counter_param_start_match = ((((((~ w22w[0]) & (~ w22w[1])) & (~ w22w[2])) & (~ w22w[3])) & (~ w22w[4])) & (~ w22w[5])),
		busy = (((~ idle) | check_busy_dffe) | ru_reconfig_pof),
		cal_addr = cal_addr_reg,
		chk_crc_counter_enable = (((((((((((~ wire_cntr8_q[2]) & (~ wire_cntr8_q[1])) & (~ wire_cntr8_q[0])) & crc_check_st) | ((((~ wire_cntr8_q[2]) & (~ wire_cntr8_q[1])) & wire_cntr8_q[0]) & asmi_data_valid)) | (((~ wire_cntr8_q[2]) & wire_cntr8_q[1]) & (~ wire_cntr8_q[0]))) | ((((~ wire_cntr8_q[2]) & wire_cntr8_q[1]) & wire_cntr8_q[0]) & crc_shift_done)) | (((wire_cntr8_q[2] & (~ wire_cntr8_q[1])) & (~ wire_cntr8_q[0])) & (~ asmi_busy))) | ((wire_cntr8_q[2] & (~ wire_cntr8_q[1])) & wire_cntr8_q[0])) | (((wire_cntr8_q[2] & wire_cntr8_q[1]) & (~ wire_cntr8_q[0])) & wire_cntr10_cout)) | ((wire_cntr8_q[2] & wire_cntr8_q[1]) & (~ wire_cntr8_q[0]))),
		chk_pof_counter_enable = (((((((((((~ wire_cntr7_q[2]) & (~ wire_cntr7_q[1])) & (~ wire_cntr7_q[0])) & chk_pof_counter_start) | (((~ wire_cntr7_q[2]) & (~ wire_cntr7_q[1])) & wire_cntr7_q[0])) | (((((~ wire_cntr7_q[2]) & wire_cntr7_q[1]) & (~ wire_cntr7_q[0])) & (~ bit_counter_enable)) & (~ read_control_reg))) | (((~ wire_cntr7_q[2]) & wire_cntr7_q[1]) & wire_cntr7_q[0])) | ((wire_cntr7_q[2] & (~ wire_cntr7_q[1])) & (~ wire_cntr7_q[0]))) | ((wire_cntr7_q[2] & (~ wire_cntr7_q[1])) & wire_cntr7_q[0])) | (((wire_cntr7_q[2] & wire_cntr7_q[1]) & (~ wire_cntr7_q[0])) & wire_cntr10_cout)) | ((wire_cntr7_q[2] & wire_cntr7_q[1]) & wire_cntr7_q[0])),
		chk_pof_counter_start = (idle & reconfig),
		crc = crc_reg,
		crc_cal = (crc_cal_reg & (~ crc_done_reg)),
		crc_check_end = crc_check_end_reg,
		crc_check_st = crc_chk_st_dffe,
		crc_check_st_wire = ((wire_cntr7_q[2] & (~ wire_cntr7_q[1])) & wire_cntr7_q[0]),
		crc_enable_wire = (crc_cal | crc_check_st_wire),
		crc_reg_wire = {((halt_cal & crc_reg[15]) | ((~ halt_cal) & invert_bits)), ((halt_cal & crc_reg[14]) | ((~ halt_cal) & crc_reg[15])), ((halt_cal & crc_reg[13]) | ((~ halt_cal) & (crc_reg[14] ^ invert_bits))), ((halt_cal & crc_reg[12]) | ((~ halt_cal) & crc_reg[13])), ((halt_cal & crc_reg[11]) | ((~ halt_cal) & crc_reg[12])), ((halt_cal & crc_reg[10]) | ((~ halt_cal) & crc_reg[11])), ((halt_cal & crc_reg[9]) | ((~ halt_cal) & crc_reg[10])), ((halt_cal & crc_reg[8]) | ((~ halt_cal) & crc_reg[9])), ((halt_cal & crc_reg[7]) | ((~ halt_cal) & crc_reg[8])), ((halt_cal & crc_reg[6]) | ((~ halt_cal) & crc_reg[7])), ((halt_cal & crc_reg[5]) | ((~ halt_cal) & crc_reg[6])), ((halt_cal & crc_reg[4]) | ((~ halt_cal) & crc_reg[5])), ((halt_cal & crc_reg[3]) | ((~ halt_cal) & crc_reg[4])), ((halt_cal & crc_reg[2]) | ((~ halt_cal) & crc_reg[3])), ((halt_cal & crc_reg[1]) | ((~ halt_cal) & crc_reg[2])), ((halt_cal & crc_reg[0]) | ((~ halt_cal) & (crc_reg[1] ^ invert_bits)))},
		crc_shift_done = ((wire_cntr9_q[2] & wire_cntr9_q[1]) & (~ wire_cntr9_q[0])),
		data_out = {((read_address & dffe4a[23]) | ((~ read_address) & dffe4a[31])), ((read_address & dffe4a[22]) | ((~ read_address) & dffe4a[30])), ((read_address & dffe4a[21]) | ((~ read_address) & dffe4a[29])), ((read_address & dffe4a[20]) | ((~ read_address) & dffe4a[28])), ((read_address & dffe4a[19]) | ((~ read_address) & dffe4a[27])), ((read_address & dffe4a[18]) | ((~ read_address) & dffe4a[26])), ((read_address & dffe4a[17]) | ((~ read_address) & dffe4a[25])), ((read_address & dffe4a[16]) | ((~ read_address) & dffe4a[24])), ((read_address & dffe4a[15]) | ((~ read_address) & dffe4a[23])), ((read_address & dffe4a[14]) | ((~ read_address) & dffe4a[22])), ((read_address & dffe4a[13]) | ((~ read_address) & dffe4a[21])), ((read_address & dffe4a[12]) | ((~ read_address) & dffe4a[20])), ((read_address & dffe4a[11]) | ((~ read_address) & dffe4a[19])), ((read_address & dffe4a[10]) | ((~ read_address) & dffe4a[18])), ((read_address & dffe4a[9]) | ((~ read_address) & dffe4a[17])), ((read_address & dffe4a[8]) | ((~ read_address) & dffe4a[16])), ((read_address & dffe4a[7]) | ((~ read_address) & dffe4a[15])), ((read_address & dffe4a[6]) | ((~ read_address) & dffe4a[14])), ((read_address & dffe4a[5]) | ((~ read_address) & dffe4a[13])), ((read_address & dffe4a[4]) | ((~ read_address) & dffe4a[12])), ((read_address & dffe4a[3]) | ((~ read_address) & dffe4a[11])), ((read_address & dffe4a[2]) | ((~ read_address) & dffe4a[10])), ((read_address & dffe4a[1]) | ((~ read_address) & dffe4a[9])), ((read_address & dffe4a[0]) | ((~ read_address) & dffe4a[8])), ((~ read_address) & dffe4a[7]), ((~ read_address) & dffe4a[6]), ((~ read_address) & dffe4a[5]), ((~ read_address) & dffe4a[4]), ((~ read_address) & dffe4a[3]), ((~ read_address) & dffe4a[2]), ((~ read_address) & dffe4a[1]), ((~ read_address) & dffe4a[0])},
		get_addr = get_addr_reg,
		halt_cal = 1'b0,
		idle = idle_state,
		invert_bits = (wire_shift_reg13_shiftout ^ crc_reg[0]),
		load_crc_high = load_crc_high_reg,
		load_crc_low = load_crc_low_reg,
		load_data = load_data_reg,
		param_addr = {1'b1, {2{1'b0}}},
		param_decoder_param_latch = dffe6a,
		param_decoder_select = {((param_decoder_param_latch[0] & (~ param_decoder_param_latch[1])) & param_decoder_param_latch[2]), (((~ param_decoder_param_latch[0]) & (~ param_decoder_param_latch[1])) & param_decoder_param_latch[2]), ((param_decoder_param_latch[0] & param_decoder_param_latch[1]) & (~ param_decoder_param_latch[2])), (((~ param_decoder_param_latch[0]) & param_decoder_param_latch[1]) & (~ param_decoder_param_latch[2])), (((~ param_decoder_param_latch[0]) & (~ param_decoder_param_latch[1])) & (~ param_decoder_param_latch[2]))},
		param_port_combine = ((param & {3{(~ read_control_reg)}}) | ({3{read_control_reg}} & param_addr)),
		pof_counter_40 = (((((((wire_cntr10_q[7] & (~ wire_cntr10_q[6])) & wire_cntr10_q[5]) & (~ wire_cntr10_q[4])) & (~ wire_cntr10_q[3])) & (~ wire_cntr10_q[2])) & wire_cntr10_q[1]) & (~ wire_cntr10_q[0])),
		pof_error = pof_error_reg,
		pof_error_wire = ((((((((((((((((crc[0] ^ crc_low[0]) | (crc[8] ^ crc_high[0])) | (crc[1] ^ crc_low[1])) | (crc[9] ^ crc_high[1])) | (crc[2] ^ crc_low[2])) | (crc[10] ^ crc_high[2])) | (crc[3] ^ crc_low[3])) | (crc[11] ^ crc_high[3])) | (crc[4] ^ crc_low[4])) | (crc[12] ^ crc_high[4])) | (crc[5] ^ crc_low[5])) | (crc[13] ^ crc_high[5])) | (crc[6] ^ crc_low[6])) | (crc[14] ^ crc_high[6])) | (crc[7] ^ crc_low[7])) | (crc[15] ^ crc_high[7])),
		power_up = (((((((((((((~ idle) & (~ read_init)) & (~ read_init_counter)) & (~ read_pre_data)) & (~ read_data)) & (~ read_post)) & (~ write_init)) & (~ write_init_counter)) & (~ write_pre_data)) & (~ write_data)) & (~ write_post_data)) & (~ write_load)) & (~ write_wait)),
		read_address = read_address_state,
		read_control_reg = read_control_reg_dffe,
		read_data = read_data_state,
		read_init = read_init_state,
		read_init_counter = read_init_counter_state,
		read_post = read_post_state,
		read_pre_data = read_pre_data_state,
		ru_reconfig_pof = ru_reconfig_pof_reg,
		rublock_captnupdt = (~ write_load),
		rublock_clock = (~ (clock | idle_write_wait)),
		rublock_reconfig = re_config_reg,
		rublock_regin = ((rublock_regout_reg & (~ select_shift_nloop)) | (shift_reg_serial_out & select_shift_nloop)),
		rublock_regout = wire_sd1_regout,
		rublock_regout_reg = dffe5,
		rublock_shiftnld = (((((read_pre_data | write_pre_data) | read_data) | write_data) | read_post) | write_post_data),
		select_shift_nloop = ((read_data & (~ width_counter_param_width_match)) | (write_data & (~ width_counter_param_width_match))),
		shift_reg_clear = (idle & (read_param | read_control_reg)),
		shift_reg_load_enable = (idle & write_param),
		shift_reg_q = dffe4a,
		shift_reg_serial_in = (rublock_regout_reg & select_shift_nloop),
		shift_reg_serial_out = dffe4a[0:0],
		shift_reg_shift_enable = (((read_data | write_data) | read_post) | write_post_data),
		start_bit_decoder_out = (((({6{1'b0}} | {1'b0, {5{start_bit_decoder_param_select[1]}}}) | {1'b0, {4{start_bit_decoder_param_select[2]}}, 1'b0}) | {{3{1'b0}}, {2{start_bit_decoder_param_select[3]}}, 1'b0}) | {{3{1'b0}}, start_bit_decoder_param_select[4], 1'b0, start_bit_decoder_param_select[4]}),
		start_bit_decoder_param_select = param_decoder_select,
		w22w = (wire_cntr2_q ^ bit_counter_param_start),
		w53w = (wire_cntr3_q ^ width_counter_param_width),
		width_counter_all_done = (((((wire_cntr3_q[0] & wire_cntr3_q[1]) & wire_cntr3_q[2]) & wire_cntr3_q[3]) & wire_cntr3_q[4]) & (~ wire_cntr3_q[5])),
		width_counter_clear = (read_init | write_init),
		width_counter_enable = ((read_data | write_data) | read_post),
		width_counter_param_width = width_decoder_out,
		width_counter_param_width_match = ((((((~ w53w[0]) & (~ w53w[1])) & (~ w53w[2])) & (~ w53w[3])) & (~ w53w[4])) & (~ w53w[5])),
		width_decoder_out = (((({{3{1'b0}}, width_decoder_param_select[0], 1'b0, width_decoder_param_select[0]} | {{2{1'b0}}, {2{width_decoder_param_select[1]}}, {2{1'b0}}}) | {{5{1'b0}}, width_decoder_param_select[2]}) | {1'b0, {2{width_decoder_param_select[3]}}, {3{1'b0}}}) | {{5{1'b0}}, width_decoder_param_select[4]}),
		width_decoder_param_select = param_decoder_select,
		write_data = write_data_state,
		write_init = write_init_state,
		write_init_counter = write_init_counter_state,
		write_load = write_load_state,
		write_post_data = write_post_data_state,
		write_pre_data = write_pre_data_state,
		write_wait = write_wait_state;
endmodule //altera_remote_update_core
//VALID FILE
