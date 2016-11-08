/*

Copyright (C) 2006-2016, IPrium LLC.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

 *	Redistributions of source code must retain the above copyright notice and
	this list of conditions.
 *	Redistributions in binary form must reproduce the above copyright notice and
	this list of conditions in the documentation and/or other materials
	provided with the distribution.

*/

/*
	$Date:: 2016-01-27 14:04:11#$
	$Revision: 2991 $
	Designer	: IPrium LLC
	Contact		: support@iprium.com
*/
//--------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module tspattern (
	iclk,
	irdy,
	irst,
	odat,
	osop,
	oval
);

	input							iclk;
	input							irdy;
	input							irst;
	output	reg	[7:0]				odat;
	output	reg						osop;
	output							oval;




	reg			[7:0]				addr;
	reg								rst;
	reg			[7:0]				data;
	reg			[7:0]				subcnt;
	reg			[22:0]				mreg;

	assign	oval					= irdy;

initial begin
	addr	= 8'd0;
	subcnt	= 8'd0;
	mreg	= 23'd0;
end

always @(posedge iclk) begin
	if (irst) begin
		addr	<= 8'd0;
		data	<= 8'd0;
		mreg	<= 23'd0;
		odat	<= 8'd0;
		osop	<= 1'b0;
	end else begin
		if (irdy) begin
			case (addr)
			8'd0: begin
				data	<= 8'h47;			// SYNC
			end
			8'd1: begin
				data	<= 8'h1f;			// PID = 0x1F0F
			end
			8'd2: begin
				data	<= 8'h0f;
			end
			8'd3: begin
				data	<= 8'h10;
			end
			8'd4: begin
				data	<= subcnt;			// packet numerator
			end
			default: begin
				data	<= mreg[7:0];		// PRBS
				mreg	<= {mreg[14:0], ~(mreg[22:15] ^ mreg[17:10])};
			end
			endcase
			odat	<= data;

			rst		<= (addr == 8'd186);
			if (rst) begin
				addr	<= 'd0;
			end else begin
				addr	<= addr + 1'b1;
			end

			if (addr == 8'd1) begin
				subcnt	<= subcnt + 1'b1;
				osop	<= 1'b1;
			end else begin
				osop	<= 1'b0;
			end
		end
	end
end

endmodule
