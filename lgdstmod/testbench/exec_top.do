#vlog -O0 -f megacore.f 

vlog +incdir+../rtl -O0 -f lgdst_mod.f 
vlog -O0 -f test_module/test_module.f test_lgdst_mod.v

restart -f 
#WaveRestoreZoom {257205 ps} {1219397 ps}
run -all
