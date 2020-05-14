set root_dir [pwd]/..
set result_dir $root_dir/result
set release_dir $root_dir/release
file mkdir $result_dir/
file mkdir $release_dir/
set project_name "project_fft2"
set design_name "design_fft2"
set jobs_num 4

# ===========================================
# CREATE BLOCK DESIGN
# ===========================================

create_bd_design $design_name
update_compile_order -fileset sources_1
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
startgroup
create_bd_cell -type ip -vlnv FTN:user:AXI_FFT2:1.0 AXI_FFT2_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_1
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_1
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0
endgroup

set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells blk_mem_gen_0]
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells blk_mem_gen_1]
set_property -dict [list CONFIG.NUM_MI {3}] [get_bd_cells axi_interconnect_0]
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_0]
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_1]
set_property -dict [list CONFIG.MASTER_TYPE {BRAM_CTRL} CONFIG.READ_WRITE_MODE {}] [get_bd_intf_pins AXI_FFT2_0/bram_re]
set_property -dict [list CONFIG.MASTER_TYPE {BRAM_CTRL} CONFIG.READ_WRITE_MODE {}] [get_bd_intf_pins AXI_FFT2_0/bram_im]

connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins AXI_FFT2_0/s00_axi]
connect_bd_intf_net [get_bd_intf_pins AXI_FFT2_0/bram_re] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins AXI_FFT2_0/bram_im] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTB]
connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
connect_bd_intf_net [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_pins axi_bram_ctrl_1/S_AXI]
connect_bd_intf_net [get_bd_intf_pins processing_system7_0/M_AXI_GP0] -boundary_type upper [get_bd_intf_pins axi_interconnect_0/S00_AXI]
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins axi_interconnect_0/ACLK]
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins AXI_FFT2_0/s00_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N]
connect_bd_net [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins axi_interconnect_0/ARESETN]
connect_bd_net [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins AXI_FFT2_0/s00_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]

apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

regenerate_bd_layout
assign_bd_address
save_bd_design

# ===========================================
# GENERATE BLOCK DESIGN
# ===========================================

generate_target all [get_files  $result_dir/$project_name.srcs/sources_1/bd/$design_name/$design_name.bd]
catch { config_ip_cache -export [get_ips -all design_fft2_xbar_0] }
catch { config_ip_cache -export [get_ips -all design_fft2_axi_bram_ctrl_0_0] }
catch { config_ip_cache -export [get_ips -all design_fft2_axi_bram_ctrl_1_0] }
catch { config_ip_cache -export [get_ips -all design_fft2_auto_pc_1] }
catch { config_ip_cache -export [get_ips -all design_fft2_auto_pc_0] }
export_ip_user_files -of_objects [get_files $result_dir/$project_name.srcs/sources_1/bd/$design_name/$design_name.bd] -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] $result_dir/$project_name.srcs/sources_1/bd/$design_name/$design_name.bd]
launch_runs -jobs 4 "${design_name}_xbar_0_synth_1 ${design_name}_axi_bram_ctrl_0_0_synth_1 ${design_name}_axi_bram_ctrl_1_0_synth_1"
export_simulation -of_objects [get_files $result_dir/$project_name.srcs/sources_1/bd/$design_name/$design_name.bd] -directory $result_dir/$project_name.ip_user_files/sim_scripts -ip_user_files_dir $result_dir/$project_name.ip_user_files -ipstatic_source_dir $result_dir/$project_name.ip_user_files/ipstatic -lib_map_path [list {modelsim=$result_dir/$project_name.cache/compile_simlib/modelsim} {questa=$result_dir/$project_name.cache/compile_simlib/questa} {ies=$result_dir/$project_name.cache/compile_simlib/ies} {xcelium=$result_dir/$project_name.cache/compile_simlib/xcelium} {vcs=$result_dir/$project_name.cache/compile_simlib/vcs} {riviera=$result_dir/$project_name.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet

# ===========================================
# MAKE WRAPPER
# ===========================================

make_wrapper -files [get_files $result_dir/$project_name.srcs/sources_1/bd/$design_name/$design_name.bd] -top
add_files -norecurse $result_dir/$project_name.srcs/sources_1/bd/$design_name/hdl/${design_name}_wrapper.vhd
update_compile_order -fileset sources_1
set_property top design_fft2_wrapper [current_fileset]
update_compile_order -fileset sources_1

# ===========================================
# SYNTHESIS
# ===========================================

set synth_command "launch_runs synth_1 -jobs $jobs_num"
eval $synth_command
wait_on_run synth_1

# ===========================================
# IMPLEMENTATION
# ===========================================

set_property STEPS.WRITE_BITSTREAM.TCL.PRE [pwd]/pre_write_bitstream.tcl [get_runs impl_1]

set impl_command "launch_runs impl_1 -to_step write_bitstream -jobs $jobs_num"
eval $impl_command
wait_on_run impl_1

# ===========================================
# COPY BITSTREAM TO RELEASE FOLDER
# ===========================================

file copy -force $result_dir/$project_name.runs/impl_1/${design_name}_wrapper.bit $release_dir/${design_name}_wrapper.bit
