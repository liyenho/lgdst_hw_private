transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/syn/db {C:/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/syn/db/io_buf.v}
vlog -vlog01compat -work work +incdir+/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/rtl {/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/rtl/ver_info.v}
vlog -vlog01compat -work work +incdir+C:/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/rtl {C:/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/rtl/lgdst_rxglue.v}

vlog -vlog01compat -work work +incdir+C:/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/syn/../testbench {C:/sncvs/rxcpld/working/rxcpld160513_v2_pin_test/syn/../testbench/test_lgdst_rxglue.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  test_lgdst_rxglue

add wave *
view structure
view signals
run -all
