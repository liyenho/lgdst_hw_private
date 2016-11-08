set_global_assignment -entity "tx_clk_gen" -library "lib_tx_clk_gen" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "tx_clk_gen" -library "lib_tx_clk_gen" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "tx_clk_gen" -library "lib_tx_clk_gen" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_tx_clk_gen" -name SPD_FILE [file join $::quartus(sip_path) "tx_clk_gen.spd"]

set_global_assignment -library "lib_tx_clk_gen" -name MISC_FILE [file join $::quartus(sip_path) "tx_clk_gen_sim/tx_clk_gen.vo"]
