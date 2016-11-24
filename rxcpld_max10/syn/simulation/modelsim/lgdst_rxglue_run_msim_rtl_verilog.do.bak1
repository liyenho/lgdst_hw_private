transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/rtl {F:/github/lgdst_hw/rxcpld161121_v2_max10/rtl/i2c_dummy.v}
vlog -vlog01compat -work work +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/rtl {F:/github/lgdst_hw/rxcpld161121_v2_max10/rtl/spi_prog.v}
vlog -vlog01compat -work work +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/flash_pll.v}
vlog -vlog01compat -work work +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/db {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/db/flash_pll_altpll.v}
vlib onchip_flash
vmap onchip_flash onchip_flash
vlog -vlog01compat -work onchip_flash +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/onchip_flash.v}
vlog -vlog01compat -work onchip_flash +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules/altera_onchip_flash_util.v}
vlog -vlog01compat -work onchip_flash +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules/altera_onchip_flash.v}
vlog -vlog01compat -work onchip_flash +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules/altera_onchip_flash_avmm_data_controller.v}
vlog -vlog01compat -work onchip_flash +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/onchip_flash/synthesis/submodules/altera_onchip_flash_avmm_csr_controller.v}
vlog -vlog01compat -work work +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/rtl {F:/github/lgdst_hw/rxcpld161121_v2_max10/rtl/lgdst_rxglue.v}

vlog -vlog01compat -work work +incdir+F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/../testbench {F:/github/lgdst_hw/rxcpld161121_v2_max10/syn/../testbench/test_lgdst_rxglue.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -L onchip_flash -voptargs="+acc"  test_lgdst_rxglue

add wave *
view structure
view signals
run -all
