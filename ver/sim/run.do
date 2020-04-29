if [file exists work] {
    vdel -all
}
vlib work

vcom ../rtl/utils_pkg.vhd
vcom ../rtl/butterfly.vhd
vcom ../rtl/fft.vhd
vcom ../rtl/fft2.vhd

vlog -sv \
    +incdir+$env(UVM_HOME) \
    +incdir+../uvc \
    +incdir+../tests \
    ../uvc/fft2_pkg.sv \
    ../fft2_test_top.sv

vsim fft2_test_top -novopt -coverage +UVM_VERBOSITY=UVM_LOW +UVM_MAX_QUIT_COUNT=5 +UVM_TESTNAME=fft2_test_simple -sv_seed random 
run -all
    
