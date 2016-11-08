/*

Copyright (C) 2006-2015, IPrium LLC.
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
	$Date:: 2015-11-24 17:08:10#$
	$Revision: 2922 $
	Designer	: IPrium LLC
	Contact		: support@iprium.com
*/
//--------------------------------------------------------------------------------------

`timescale 1ns / 1ps

module top5ceba4u15va (
	tx_ref_clk,
	irst,
	dac_dati,
	dac_datq
);

	// This file is for performance and resource estimation only
	// Do not use it for functionality testing

	// reference clock
	input							tx_ref_clk;

	// active '1' reset
	input							irst;

	// to avoid output trim
	output		[15:0]				dac_dati;
	output		[15:0]				dac_datq;



//==========================================================================
//
//	local wires section
//
//==========================================================================

	wire							tspattern_inst__iclk;
	wire							tspattern_inst__irdy;
	wire							tspattern_inst__irst;
	wire		[7:0]				tspattern_inst__odat;
	wire							tspattern_inst__osop;
	wire							tspattern_inst__oval;


	wire							tx_inst__iclk;
	wire		[7:0]				tx_inst__idat;
	wire		[31:0]				tx_inst__ifreq;
	wire		[15:0]				tx_inst__igain;
	wire		[1:0]				tx_inst__iguard;
	wire		[1:0]				tx_inst__imod;
	wire							tx_inst__irst;
	wire							tx_inst__isop;
	wire							tx_inst__ival;
	wire		[15:0]				tx_inst__odati;
	wire		[15:0]				tx_inst__odatq;
	wire							tx_inst__ordy;


//==========================================================================
//
//	extrnal pins section
//
//==========================================================================

	assign	dac_dati				= tx_inst__odati;
	assign	dac_datq				= tx_inst__odatq;


//==========================================================================
//
//	internal pins section
//
//==========================================================================

	assign	tspattern_inst__iclk				= tx_ref_clk;
	assign	tspattern_inst__irdy				= tx_inst__ordy;
	assign	tspattern_inst__irst				= irst;
//	assign	odat								= tspattern_inst__odat;
//	assign	osop								= tspattern_inst__osop;
//	assign	oval								= tspattern_inst__oval;


	assign	tx_inst__iclk						= tx_ref_clk;
	assign	tx_inst__idat						= tspattern_inst__odat;
	assign	tx_inst__ifreq						= 32'd0;
	assign	tx_inst__igain						= 16'd0;
	assign	tx_inst__iguard						= 2'd0;		// unused internally
	assign	tx_inst__imod						= 2'd0;		// unused internally
	assign	tx_inst__irst						= irst;
	assign	tx_inst__isop						= tspattern_inst__osop;
	assign	tx_inst__ival						= tspattern_inst__oval;
//	assign	odati								= tx_inst__odati;
//	assign	odatq								= tx_inst__odatq;
//	assign	ordy								= tx_inst__ordy;


//==========================================================================
//
//	tspattern
//
//==========================================================================
	tspattern			tspattern_inst			(	.iclk				(tspattern_inst__iclk),
													.irdy				(tspattern_inst__irdy),
													.irst				(tspattern_inst__irst),
													.odat				(tspattern_inst__odat),
													.osop				(tspattern_inst__osop),
													.oval				(tspattern_inst__oval)
												);


//==========================================================================
//
//	tx
//
//==========================================================================
	tx					tx_inst					(	.iclk				(tx_inst__iclk),
													.idat				(tx_inst__idat),
													.ifreq				(tx_inst__ifreq),
													.igain				(tx_inst__igain),
													.iguard				(tx_inst__iguard),
													.imod				(tx_inst__imod),
													.irst				(tx_inst__irst),
													.isop				(tx_inst__isop),
													.ival				(tx_inst__ival),
													.odati				(tx_inst__odati),
													.odatq				(tx_inst__odatq),
													.ordy				(tx_inst__ordy)
												);


endmodule
