set_global_assignment -entity "pll_for_lvds_tx" -library "lib_pll_for_lvds_tx" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_for_lvds_tx" -library "lib_pll_for_lvds_tx" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "pll_for_lvds_tx" -library "lib_pll_for_lvds_tx" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_for_lvds_tx" -name SPD_FILE [file join $::quartus(sip_path) "pll_for_lvds_tx.spd"]

set_global_assignment -library "lib_pll_for_lvds_tx" -name MISC_FILE [file join $::quartus(sip_path) "pll_for_lvds_tx_sim/pll_for_lvds_tx.vo"]
