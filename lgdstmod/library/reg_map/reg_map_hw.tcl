

package require -exact qsys 13.0

set_module_property NAME reg_map_v1_0
set_module_property DESCRIPTION "Fabric Register Interface"
set_module_property VERSION 1.0
set_module_property DISPLAY_NAME reg_map

# files

add_fileset quartus_synth QUARTUS_SYNTH "" "Quartus Synthesis"
set_fileset_property quartus_synth TOP_LEVEL reg_map_v1_0
add_fileset_file reg_map_v1_0_S00_AXI.v     VERILOG PATH ./hdl/reg_map_v1_0_S00_AXI.v 
add_fileset_file reg_map_v1_0.v             VERILOG PATH ./hdl/reg_map_v1_0.v TOP_LEVEL_FILE

# parameters

add_parameter C_S00_AXI_DATA_WIDTH INTEGER 32
set_parameter_property C_S00_AXI_DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property C_S00_AXI_DATA_WIDTH DISPLAY_NAME DATA_WIDTH
set_parameter_property C_S00_AXI_DATA_WIDTH TYPE INTEGER
set_parameter_property C_S00_AXI_DATA_WIDTH UNITS None
set_parameter_property C_S00_AXI_DATA_WIDTH HDL_PARAMETER true

add_parameter C_S00_AXI_ADDR_WIDTH INTEGER 16
set_parameter_property C_S00_AXI_ADDR_WIDTH DEFAULT_VALUE 16
set_parameter_property C_S00_AXI_ADDR_WIDTH DISPLAY_NAME ADDR_WIDTH
set_parameter_property C_S00_AXI_ADDR_WIDTH TYPE INTEGER
set_parameter_property C_S00_AXI_ADDR_WIDTH UNITS None
set_parameter_property C_S00_AXI_ADDR_WIDTH HDL_PARAMETER true

# axi4 slave

add_interface s_axi_clock clock end
add_interface_port s_axi_clock s00_axi_aclk clk Input 1

add_interface s_axi_reset reset end
set_interface_property s_axi_reset associatedClock s_axi_clock
add_interface_port s_axi_reset s00_axi_aresetn reset_n Input 1

add_interface s_axi axi4lite end
set_interface_property s_axi associatedClock s_axi_clock
set_interface_property s_axi associatedReset s_axi_reset
add_interface_port s_axi s00_axi_awvalid awvalid Input 1
add_interface_port s_axi s00_axi_awaddr awaddr Input C_S00_AXI_ADDR_WIDTH
add_interface_port s_axi s00_axi_awprot awprot Input 3
add_interface_port s_axi s00_axi_awready awready Output 1
add_interface_port s_axi s00_axi_wvalid wvalid Input 1
add_interface_port s_axi s00_axi_wdata wdata Input C_S00_AXI_DATA_WIDTH
add_interface_port s_axi s00_axi_wstrb wstrb Input (C_S00_AXI_DATA_WIDTH/8)
add_interface_port s_axi s00_axi_wready wready Output 1
add_interface_port s_axi s00_axi_bvalid bvalid Output 1
add_interface_port s_axi s00_axi_bresp bresp Output 2
add_interface_port s_axi s00_axi_bready bready Input 1
add_interface_port s_axi s00_axi_arvalid arvalid Input 1
add_interface_port s_axi s00_axi_araddr araddr Input C_S00_AXI_ADDR_WIDTH
add_interface_port s_axi s00_axi_arprot arprot Input 3
add_interface_port s_axi s00_axi_arready arready Output 1
add_interface_port s_axi s00_axi_rvalid rvalid Output 1
add_interface_port s_axi s00_axi_rresp rresp Output 2
add_interface_port s_axi s00_axi_rdata rdata Output C_S00_AXI_DATA_WIDTH
add_interface_port s_axi s00_axi_rready rready Input 1

# device interface

add_interface user_interface conduit end
set_interface_property user_interface associatedClock s_axi_clock
add_interface_port user_interface usr_rd_word_en   usr_rd_word_en Output 1
add_interface_port user_interface usr_rd_word_addr usr_rd_word_addr Output (C_S00_AXI_ADDR_WIDTH-2)
add_interface_port user_interface usr_rd_word_data usr_rd_word_data Input 32
add_interface_port user_interface usr_wr_word_en   usr_wr_word_en Output 1
add_interface_port user_interface usr_wr_byte_indx usr_wr_byte_indx Output 4
add_interface_port user_interface usr_wr_word_addr usr_wr_word_addr Output (C_S00_AXI_ADDR_WIDTH-2)
add_interface_port user_interface usr_wr_word_data usr_wr_word_data Output 32
add_interface_port user_interface test_out         test_out Output 256



