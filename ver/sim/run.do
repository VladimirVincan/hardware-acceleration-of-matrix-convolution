# set number of seeds
set num_seeds 50

if [file exists work] {
    vdel -all
}
vlib work
if [file exists covhtmlreport] {
    rm -r covhtmlreport
}
# if [file exists *.ucdb] {
#    rm *.ucdb
# }
rm *.ucdb

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

# regression 
for {set i 0} {$i < $num_seeds} {incr i 1} {
    vsim -c fft2_test_top -novopt -coverage +UVM_VERBOSITY=UVM_LOW +UVM_TESTNAME=fft2_test_simple -sv_seed random
    # coverage save -assert -directive -cvg -codeAll fft2-coverage-$i.ucdb 
    # coverage save -assert -directive -cvg -codeAll −onexit fft2-coverage-$i.ucdb
    onbreak {resume}
    run -all   
    onbreak {resume}
    coverage save -assert -directive -cvg -codeAll fft2-coverage-$i.ucdb 
}

vcover merge -strip 0 merged.ucdb fft2-coverage-*.ucdb
vcover report -html -htmldir covhtmlreport -threshL 50 -threshH 90 merged.ucdb
# vsim -i -viewcov merged.ucdb
# coverage report -html -htmldir covhtmlreport -threshL 50 -threshH 90
