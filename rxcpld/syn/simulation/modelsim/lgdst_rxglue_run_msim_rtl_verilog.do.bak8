transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/sncvs/rxcpld/working/rxcpld160523_v2_ctrl_led_ver_readback/rtl {/sncvs/rxcpld/working/rxcpld160523_v2_ctrl_led_ver_readback/rtl/ver_info.v}
vlog -vlog01compat -work work +incdir+C:/sncvs/rxcpld/working/rxcpld160523_v2_ctrl_led_ver_readback/rtl {C:/sncvs/rxcpld/working/rxcpld160523_v2_ctrl_led_ver_readback/rtl/lgdst_rxglue.v}

vlog -vlog01compat -work work +incdir+C:/sncvs/rxcpld/working/rxcpld160523_v2_ctrl_led_ver_readback/syn/../testbench {C:/sncvs/rxcpld/working/rxcpld160523_v2_ctrl_led_ver_readback/syn/../testbench/test_lgdst_rxglue.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L maxv_ver -L rtl_work -L work -voptargs="+acc"  test_lgdst_rxglue

add wave *
view structure
view signals
run -all
