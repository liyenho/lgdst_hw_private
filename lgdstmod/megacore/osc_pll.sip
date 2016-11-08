set_global_assignment -entity "osc_pll" -library "lib_osc_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "osc_pll" -library "lib_osc_pll" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "osc_pll" -library "lib_osc_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_osc_pll" -name SPD_FILE [file join $::quartus(sip_path) "osc_pll.spd"]

set_global_assignment -library "lib_osc_pll" -name MISC_FILE [file join $::quartus(sip_path) "osc_pll_sim/osc_pll.vo"]
