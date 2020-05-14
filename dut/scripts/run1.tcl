# ===========================================
# CREATE PROJECT
# ===========================================

set root_dir [pwd]/..
set result_dir $root_dir/result
set release_dir $root_dir/release
file mkdir $result_dir/
file mkdir $release_dir/
set project_name "project_fft2"
set design_name "design_fft2"
set jobs_num 4

create_project $project_name $result_dir -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]
set_property target_language VHDL [current_project]

# ===========================================
# ADDING SOURCES
# ===========================================

add_files -norecurse ${root_dir}/rtl/mem_subsystem.vhd
add_files -norecurse ${root_dir}/rtl/axi_fft2_v1_0_S00_AXI.vhd
add_files -norecurse ${root_dir}/rtl/fft2.vhd
add_files -norecurse ${root_dir}/rtl/butterfly.vhd
add_files -norecurse ${root_dir}/rtl/axi_fft2_v1_0.vhd
add_files -norecurse ${root_dir}/rtl/fft.vhd
add_files -norecurse ${root_dir}/rtl/bram_if.vhd
add_files -norecurse ${root_dir}/rtl/utils_pkg.vhd
add_files -fileset constrs_1 -norecurse ${root_dir}/constraints/clk_constraints.xdc
update_compile_order -fileset sources_1

# ===========================================
# IP PACKAGING
# ===========================================

ipx::package_project -force $result_dir -vendor user.org -library user -taxonomy /UserIP
set_property vendor FTN [ipx::current_core]
set_property name AXI_FFT2 [ipx::current_core]
set_property display_name AXI_FFT2_v1_0 [ipx::current_core]
set_property description {Two-dimensional FFT module with AXI interface} [ipx::current_core]
set_property company_url http://www.ftn.uns.ac.rs [ipx::current_core]
set_property vendor_display_name FTN [ipx::current_core]
set_property taxonomy {/Digital_Signal_Processing/Transforms/FFTs /Embedded_Processing/AXI_Peripheral /UserIP} [ipx::current_core]
set_property supported_families {zynq Production} [ipx::current_core]

ipx::infer_bus_interface {clka rsta ena addra dina douta wea} xilinx.com:interface:bram_rtl:1.0 [ipx::current_core]
set_property name bram_re [ipx::get_bus_interfaces bram_1 -of_objects [ipx::current_core]]
ipx::infer_bus_interface {clkb rstb enb addrb dinb doutb web} xilinx.com:interface:bram_rtl:1.0 [ipx::current_core]
set_property name bram_im [ipx::get_bus_interfaces bram_1 -of_objects [ipx::current_core]]

# ===========================================
# PACKAGE IP BUTTON -- DOESN'T WORK
# ===========================================

set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property ip_repo_paths ../result/ [current_project]
update_ip_catalog
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core $result_dir/FTN_user_AXI_FFT2_1.0.zip [ipx::current_core]
# close_project
