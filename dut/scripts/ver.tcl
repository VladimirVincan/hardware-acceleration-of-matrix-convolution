set root_dir [pwd]/../ver-vivado
# set vivado_dir /tools/Xilinx/Vivado/2019.2/bin
set SIMULATION_NUM 1

# ===========================================
# ADD FILES
# ===========================================

add_files -fileset sim_1 $root_dir/uvc/init/sequences/fft2_init_seq_lib.sv
add_files -fileset sim_1 $root_dir/uvc/init/sequences/fft2_init_base_seq.sv
add_files -fileset sim_1 $root_dir/uvc/init/sequences/fft2_init_simple_seq.sv
add_files -fileset sim_1 $root_dir/uvc/init/fft2_init_driver.sv
add_files -fileset sim_1 $root_dir/uvc/init/fft2_init_config.sv
add_files -fileset sim_1 $root_dir/uvc/init/fft2_init_agent.sv
add_files -fileset sim_1 $root_dir/uvc/init/fft2_init_sequencer.sv
add_files -fileset sim_1 $root_dir/uvc/init/fft2_init_monitor.sv

add_files -fileset sim_1 $root_dir/uvc/din/sequences/fft2_din_seq_lib.sv
add_files -fileset sim_1 $root_dir/uvc/din/sequences/fft2_din_simple_seq.sv
add_files -fileset sim_1 $root_dir/uvc/din/sequences/fft2_din_base_seq.sv
add_files -fileset sim_1 $root_dir/uvc/din/fft2_din_sequencer.sv
add_files -fileset sim_1 $root_dir/uvc/din/fft2_din_monitor.sv
add_files -fileset sim_1 $root_dir/uvc/din/fft2_din_agent.sv
add_files -fileset sim_1 $root_dir/uvc/din/fft2_din_config.sv
add_files -fileset sim_1 $root_dir/uvc/din/fft2_din_driver.sv

add_files -fileset sim_1 $root_dir/uvc/dout/sequences/fft2_dout_seq_lib.sv
add_files -fileset sim_1 $root_dir/uvc/dout/sequences/fft2_dout_simple_seq.sv
add_files -fileset sim_1 $root_dir/uvc/dout/sequences/fft2_dout_base_seq.sv
add_files -fileset sim_1 $root_dir/uvc/dout/fft2_dout_driver.sv
add_files -fileset sim_1 $root_dir/uvc/dout/fft2_dout_monitor.sv
add_files -fileset sim_1 $root_dir/uvc/dout/fft2_dout_agent.sv
add_files -fileset sim_1 $root_dir/uvc/dout/fft2_dout_sequencer.sv
add_files -fileset sim_1 $root_dir/uvc/dout/fft2_dout_config.sv

add_files -fileset sim_1 $root_dir/uvc/fft2_init_if.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_config.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_scoreboard.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_ref_model.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_din_if.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_env.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_dout_din_transaction.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_dout_if.sv
add_files -fileset sim_1 $root_dir/uvc/fft2_init_transaction.sv

add_files -fileset sim_1 $root_dir/tests/fft2_test_lib.sv
add_files -fileset sim_1 $root_dir/tests/fft2_test_base.sv
add_files -fileset sim_1 $root_dir/tests/fft2_test_simple.sv

add_files -fileset sim_1 $root_dir/uvc/fft2_pkg.sv
add_files -fileset sim_1 $root_dir/fft2_test_top.sv

update_compile_order -fileset sim_1

# ===========================================
# SET UP COMPILER
# ===========================================

set_property -name {xsim.compile.xvlog.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.elaborate.xelab.more_options} -value {-L uvm} -objects [get_filesets sim_1]
set_property -name {xsim.simulate.xsim.more_options} -value {-testplusarg UVM_TESTNAME=fft2_test_simple -testplusarg UVM_VERBOSITY=UVM_LOW -sv_seed random -runall} -objects [get_filesets sim_1]

# ===========================================
# SET UP SIMULATION SETTINGS
# ===========================================

set_property top fft2_test_top [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {10ms} -objects [get_filesets sim_1]
update_compile_order -fileset sim_1

# ===========================================
# SET UP MANUAL COMPILE ORDER
# ===========================================

set_property source_mgmt_mode DisplayOnly [current_project]
reorder_files -fileset sim_1 -front $root_dir/uvc/fft2_env.sv
reorder_files -fileset sim_1 -front $root_dir/tests/fft2_test_lib.sv
reorder_files -fileset sim_1 -front $root_dir/uvc/init/sequences/fft2_init_seq_lib.sv
reorder_files -fileset sim_1 -front $root_dir/uvc/din/sequences/fft2_din_seq_lib.sv
reorder_files -fileset sim_1 -front $root_dir/uvc/dout/sequences/fft2_dout_seq_lib.sv
reorder_files -fileset sim_1 -front $root_dir/uvc/fft2_pkg.sv
reorder_files -fileset sim_1 -back $root_dir/fft2_test_top.sv

# ===========================================
# LAUNCH SIMULATION
# ===========================================

# launch_simulation
# relaunch_sim
# close_sim

for {set i 0} {$i < $SIMULATION_NUM} {incr i} {
    set db_name "covdb_$i" ;
    set xsim_command "set_property -name \{xsim.simulate.xsim.more_options\} -value \{-testplusarg UVM_TESTNAME=fft2_test_simple -testplusarg UVM_VERBOSITY=UVM_LOW -sv_seed random -runall -cov_db_name $db_name\} -objects \[get_filesets sim_1\]"
    eval $xsim_command
    launch_simulation
    if {$i+1 < $SIMULATION_NUM} {
        close_sim
    }
}
