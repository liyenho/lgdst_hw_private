set_global_assignment -entity "tx_clk_gen_debug" -library "lib_tx_clk_gen_debug" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "tx_clk_gen_debug" -library "lib_tx_clk_gen_debug" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "tx_clk_gen_debug" -library "lib_tx_clk_gen_debug" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_tx_clk_gen_debug" -name SPD_FILE [file join $::quartus(sip_path) "tx_clk_gen_debug.spd"]

set_global_assignment -library "lib_tx_clk_gen_debug" -name MISC_FILE [file join $::quartus(sip_path) "tx_clk_gen_debug_sim/tx_clk_gen_debug.vo"]
