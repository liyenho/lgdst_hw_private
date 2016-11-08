set_global_assignment -entity "b2b_pll" -library "lib_b2b_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "b2b_pll" -library "lib_b2b_pll" -name IP_TOOL_VERSION "15.0"
set_global_assignment -entity "b2b_pll" -library "lib_b2b_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_b2b_pll" -name SPD_FILE [file join $::quartus(sip_path) "b2b_pll.spd"]

set_global_assignment -library "lib_b2b_pll" -name MISC_FILE [file join $::quartus(sip_path) "b2b_pll_sim/b2b_pll.vo"]
