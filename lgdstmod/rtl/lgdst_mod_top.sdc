## Generated SDC file "E:/Projects/SN4Enc Prj_Code/lgdst_mod/rtl/lgdst_mod_top.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 15.0.2 Build 153 07/15/2015 SJ Full Version"

## DATE    "Sun Jan 10 00:28:20 2016"

##
## DEVICE  "5CEFA4U19C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {spi1_spck} -period 25.000 -waveform { 0.000 12.500 } [get_ports {spi1_spck}]
create_clock -name {clk_24m} -period 41.666 -waveform { 0.000 20.833 } [get_ports {clk_24M}]
#create_clock -name {adi_clk_out} -period 25.000 -waveform { 0.000 12.500 } [get_ports {adi_clk_out}]
#create_clock -name {clk1} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk1p}]
create_clock -name {i2smclk} -period 25.000 -waveform { 0.000 12.500 } [get_ports {i2smclk}]
create_clock -name {i2sck0} -period 25.000 -waveform { 0.000 12.500 } [get_ports {i2sck0}]
#create_clock -name {adi_data_clk} -period 13.680 -waveform { 0.000 6.840 } [get_ports {adi_data_clk_p}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {clk300m} -source [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50.000 -multiply_by 25 -divide_by 2 -master_clock {clk_24m} [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
create_generated_clock -name {pll_clk12m} -source [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 25 -master_clock {clk300m} [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {pll_clk50m} -source [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 6 -master_clock {clk300m} [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] 
create_generated_clock -name {pll_clk100m} -source [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 3 -master_clock {clk300m} [get_pins {i_osc_pll|osc_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 
#create_generated_clock -name {clk438} -source [get_pins {i_adi_tx_rx|tx_clk_gen_i|tx_clk_gen2_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50.000 -multiply_by 12 -divide_by 2 -master_clock {adi_data_clk} [get_pins {i_adi_tx_rx|tx_clk_gen_i|tx_clk_gen2_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
#create_generated_clock -name {pll_clk146m} -source [get_pins {i_adi_tx_rx|tx_clk_gen_i|tx_clk_gen2_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 3 -master_clock {clk438} [get_pins {i_adi_tx_rx|tx_clk_gen_i|tx_clk_gen2_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 
#create_generated_clock -name {i_b2b_pll|b2b_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} -source [get_pins {i_b2b_pll|b2b_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|refclkin}] -duty_cycle 50.000 -multiply_by 6 -divide_by 2 -master_clock {clk1} [get_pins {i_b2b_pll|b2b_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]}] 
#create_generated_clock -name {i_b2b_pll|b2b_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk} -source [get_pins {i_b2b_pll|b2b_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 3 -master_clock {i_b2b_pll|b2b_pll_inst|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]} [get_pins {i_b2b_pll|b2b_pll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {i2sck0}]  -rise_to [get_clocks {i2sck0}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {i2sck0}]  -rise_to [get_clocks {i2sck0}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {clk_24m}] -rise_to [get_clocks {clk_24m}] -setup 0.280  
set_clock_uncertainty -rise_from [get_clocks {clk_24m}] -rise_to [get_clocks {clk_24m}] -hold 0.270  
set_clock_uncertainty -rise_from [get_clocks {pll_clk146m}]  -rise_to [get_clocks {pll_clk146m}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_clk146m}]  -rise_to [get_clocks {pll_clk146m}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {pll_clk50m}] -rise_to [get_clocks {pll_clk50m}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {pll_clk50m}] -rise_to [get_clocks {pll_clk50m}] -hold 0.060  
set_clock_uncertainty -rise_from [get_clocks {adi_data_clk}] -rise_to [get_clocks {adi_data_clk}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {adi_data_clk}] -rise_to [get_clocks {adi_data_clk}] -hold 0.060  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock [get_clocks adi_data_clk] -max 0.300 [get_ports adi_rx_*] -add_delay
set_input_delay -clock [get_clocks adi_data_clk] -min 0 [get_ports adi_rx_*] -add_delay


#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from [get_registers {rst_b}]  
set_false_path -from [get_clocks {spi1_spck}] -to [get_clocks {pll_clk50m}]
set_false_path -from [get_clocks {pll_clk50m}] -to [get_clocks {spi1_spck}]
set_false_path -from [get_clocks {pll_clk50m}] -to [get_clocks {adi_data_clk}]
set_false_path -from [get_clocks {adi_data_clk}]    -to [get_clocks {pll_clk50m}]
set_false_path -from [get_clocks {pll_clk146m}]     -to [get_clocks {clk_24m}]
set_false_path -from [get_clocks {pll_clk146m}]     -to [get_clocks {pll_clk50m}]
set_false_path -from [get_clocks {pll_clk146m}]     -to [get_clocks {adi_data_clk}]
set_false_path -from [get_clocks {pll_clk50m}]      -to [get_clocks {pll_clk146m}]
set_false_path -from [get_clocks {clk_24m}]         -to [get_clocks {pll_clk50m}]
set_false_path -from [get_clocks {clk_24m}]         -to [get_clocks {pll_clk146m}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_ue9:dffpipe9|dffe10a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_te9:dffpipe6|dffe7a*}]
set_false_path -from [get_keepers {lgdst_mod_core:i_core|cbr_gen[1]}] -to [get_keepers {rf_vid_server:i_rf_vid_svr|cbr_vid_buffer:vid_buffer|cbr_vid_buffer_fifo:i_vid_buffer|dcfifo:dcfifo_component|dcfifo_6rt1:auto_generated|a_graycounter_ldc:wrptr_g1p|counter8a9}]

set_false_path -from [get_clocks {pll_clk50m}] -to [get_clocks {clk_24m}]
set_false_path -from [get_clocks {clk_24m}] -to [get_clocks {pll_clk50m}]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

#create_clock -name {adi_pll_clk_in} -period 13.6 [get_ports {adi_pll_clk_in}]

#for 8MHz
# create_clock -name {adi_data_clk} -period 13.6 [get_ports {adi_data_clk_p}] -waveform { 0.000 7.8 }
# create_clock -period 13.6 -name v_rx_clk -waveform { 0.000 7.8 }

create_clock -name {adi_data_clk} -period 18.2 [get_ports {adi_data_clk_p}] -waveform { 0.000 9.1 }
create_clock -period 18.2 -name v_rx_clk -waveform { 0.000 9.1 }

derive_pll_clocks
derive_clock_uncertainty

#create_clock -period 54.6 -name v_rx_clk -waveform { 0.000 27.3 }
#create_clock -name {adi_pll_clk_in} -period 54.6 [get_ports {adi_pll_clk_in}]
#create_clock -name {adi_data_clk} -period 54.6 [get_ports {adi_data_clk_p}] -waveform { 0.000 27.3 }

set_false_path -from [get_clocks {adi_data_clk}] -to [get_clocks {pll_clk50m}]
set_false_path -from [get_clocks {pll_clk50m}] -to [get_clocks {adi_data_clk}]

set_false_path -from [get_clocks {pll_clk50m}] -to [get_clocks {nios_subsystem|axi_ad9361|i_dev_if|i_clk|pll_for_lvds_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_false_path -from [get_clocks {nios_subsystem|axi_ad9361|i_dev_if|i_clk|pll_for_lvds_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {pll_clk50m}]
set_false_path -from [get_clocks {i_tx_clk_gen|tx_clk_gen_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -to [get_clocks {pll_clk50m}]
set_false_path -from [get_clocks {pll_clk50m}] -to [get_clocks {i_tx_clk_gen|tx_clk_gen_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]

set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_frame_p}]
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[0]}]
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[1]}]
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[2]}]
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[3]}]
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[4]}]
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[5]}]

#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_frame_p}] -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[0]}]  -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[1]}]  -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[2]}]  -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[3]}]  -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[4]}]  -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[5]}]  -add_delay

set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_frame_p}] -clock_fall -add_delay
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[0]}] -clock_fall -add_delay
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[1]}] -clock_fall -add_delay
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[2]}] -clock_fall -add_delay
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[3]}] -clock_fall -add_delay
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[4]}] -clock_fall -add_delay
set_input_delay   -clock {v_rx_clk} -max  1.25 [get_ports {adi_rx_p[5]}] -clock_fall -add_delay

#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_frame_p}]     -clock_fall -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[0]}]   -clock_fall -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[1]}]   -clock_fall -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[2]}]   -clock_fall -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[3]}]   -clock_fall -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[4]}]   -clock_fall -add_delay
#set_input_delay   -clock {v_rx_clk} -min  0.25 [get_ports {adi_rx_p[5]}]   -clock_fall -add_delay

#create_generated_clock -source [get_ports {adi_data_clk_p}] -name v_tx_clk [get_ports {adi_fb_clk_p}] -phase 90
create_clock -name {adi_fb_clk} -period 18.2 [get_ports {adi_fb_clk_p}] -waveform { 0.000 9.1 }

#set_false_path -from clk_250m    -to v_tx_clk
#set_false_path -from v_tx_clk    -to clk_250m

set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_frame_p}]
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[0]}]
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[1]}]
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[2]}]
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[3]}]
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[4]}]
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[5]}]

set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_frame_p}]  -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[0]}]     -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[1]}]     -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[2]}]     -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[3]}]     -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[4]}]     -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[5]}]     -add_delay

set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_frame_p}]    -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[0]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[1]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[2]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[3]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[4]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -max  1.0 [get_ports {adi_tx_p[5]}]  -clock_fall -add_delay

set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_frame_p}]    -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[0]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[1]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[2]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[3]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[4]}]  -clock_fall -add_delay
set_output_delay  -clock {adi_fb_clk} -min  0.1 [get_ports {adi_tx_p[5]}]  -clock_fall -add_delay
