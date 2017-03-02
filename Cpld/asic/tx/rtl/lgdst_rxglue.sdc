## Generated SDC file "E:/Projects/SN4Enc Prj_Code/lgdst_rxglue/rtl/lgdst_rxglue.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 15.1.0 Build 185 10/21/2015 SJ Standard Edition"

## DATE    "Sun Mar 06 17:30:43 2016"

##
## DEVICE  "5M40ZM64C5"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clk}]
create_clock -name {ts_clk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {ts_clk}]
create_clock -name {spi0_spclk} -period 20.000 -waveform { 0.000 10.000 } [get_ports {spi0_spck}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {spi0_spclk}]  3.000 [get_ports {ad_spi_sdio}]
set_input_delay -add_delay  -clock [get_clocks {spi0_spclk}]  3.000 [get_ports {spi0_mosi}]
set_input_delay -add_delay  -clock [get_clocks {spi0_spclk}]  3.000 [get_ports {spi0_npcs0}]
set_input_delay -add_delay  -clock [get_clocks {spi0_spclk}]  3.000 [get_ports {spi0_spck}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {ts_clk}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {ts_d0}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {ts_sync}]
set_input_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {ts_valid}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {spi0_spclk}]  3.000 [get_ports {ad_spi_cs}]
set_output_delay -add_delay  -clock [get_clocks {spi0_spclk}]  0.000 [get_ports {ad_spi_sclk}]
set_output_delay -add_delay  -clock [get_clocks {spi0_spclk}]  3.000 [get_ports {spi0_miso}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {spi5_mosi}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {spi5_npcs0}]
set_output_delay -add_delay  -clock [get_clocks {clk}]  3.000 [get_ports {spi5_spck}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -from [get_keepers {ad_spi_oe_b}] -to [get_ports {ad_spi_sdio}] 22.000
set_max_delay -from [get_keepers {ad_spi_oe_b}] -to [get_ports {ad_spi_sdio}] 22.000
set_max_delay -from [get_keepers {spi0_mosi}] -to [get_ports {ad_spi_sdio}] 22.000
set_max_delay -from [get_ports {spi0_mosi}] -to [get_keepers {ad_spi_sdio}] 22.000
set_max_delay -from [get_ports {spi0_npcs0}] -to [get_keepers {ad_spi_sdio}] 22.000
set_max_delay -from [get_ports {spi0_npcs0}] -to [get_keepers {ad_spi_cs}] 22.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -from [get_ports {spi0_mosi}] -to [get_keepers {ad_spi_sdio}] 8.000
set_min_delay -from [get_ports {spi0_npcs0}] -to [get_keepers {ad_spi_sdio}] 8.000
set_min_delay -from [get_keepers {ad_spi_oe_b}] -to [get_ports {ad_spi_sdio}] 8.000


#**************************************************************
# Set Input Transition
#**************************************************************

