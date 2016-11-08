if ![file exists altera_mf] then {
  vlib altera_mf
  vlog -work altera_mf -nodebug -source -O0 -novopt -vlog01compat -nocovercells altera_src/altera_mf.v
}

if ![file exists altera_lnsim] then {
  vlib altera_lnsim
  vlog -sv -work altera_lnsim -nodebug -source -O0 -novopt -nocovercells altera_src/altera_lnsim.sv
}

if ![file exists cyclonev_atoms] then {
  vlib cyclonev_atoms
  vlog -work altera_lnsim -nodebug -source -O0 -novopt -nocovercells altera_src/cyclonev_atoms.v
}

if [file exists work] then {
    vdel -all -lib work
}
vlib work

vlog -O0 -f megacore.f 

vlog +incdir+../rtl -O0 -f lgdst_mod.f 
vlog -O0 -f test_module/test_module.f test_lgdst_mod.v
vsim -L altera_mf -L altera_lnsim -L cyclonev_atoms work.test_lgdst_mod -novopt

view wave -undock
if [file exists test_lgdst_mod.wave.do] then {
  do test_lgdst_mod.wave.do
} else {
  add wave -hex -group TOP i_dut/*
  write format wave test_lgdst_mod.wave.do
}
run -all
