if ![file exists altera_primitives] then {
  vlib altera_primitives
  vlog -work altera_primitives -nodebug -source -O0 -novopt -vlog01compat -nocovercells altera_src/altera_primitives.v
}

if [file exists work] then {
    vdel -all -lib work
}
vlib work

vlog +incdir+../rtl -O0 -f lgdst_rxglue.f 
vlog -O0 -f test_module/test_module.f test_lgdst_rxglue.v
vsim -L altera_primitives work.test_lgdst_rxglue -novopt

view wave -undock
if [file exists test_lgdst_rxglue.wave.do] then {
  do test_lgdst_rxglue.wave.do
} else {
  add wave -hex -group TOP i_dut/*
  write format wave test_lgdst_rxglue.wave.do
}
run -all
