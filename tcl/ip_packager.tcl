create_peripheral user.org user axil_bram_fft2 3.1 -dir /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo
add_peripheral_interface S00_AXI -interface_mode slave -axi_type lite [ipx::find_open_core user.org:user:axil_bram_fft2:3.1]
generate_peripheral -driver -bfm_example_design -debug_hw_example_design -force [ipx::find_open_core user.org:user:axil_bram_fft2:3.1]
write_peripheral [ipx::find_open_core user.org:user:axil_bram_fft2:3.1]
set_property  ip_repo_paths  {/home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/fft2_2.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/fft2_2.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/fft2_1.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_1.0} [current_project]
update_ip_catalog -rebuild
ipx::edit_ip_in_project -upgrade true -name edit_axil_bram_fft2_v3_1 -directory /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1/component.xml

update_compile_order -fileset sources_1
set_property taxonomy {/AXI_Peripheral /Digital_Signal_Processing/Transforms/FFTs} [ipx::current_core]
add_files -norecurse -copy_to /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1/src {/home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/mem_subsystem.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/bram_if.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/fft2.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/utils_pkg.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/axi_fft2_v1_0.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/butterfly.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/fft.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/axi_fft2_v1_0_S00_AXI.vhd}
update_compile_order -fileset sources_1
export_ip_user_files -of_objects  [get_files /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1/hdl/axil_bram_fft2_v3_1.vhd] -no_script -reset -force -quiet
export_ip_user_files -of_objects  [get_files /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1/hdl/axil_bram_fft2_v3_1_S00_AXI.vhd] -no_script -reset -force -quiet
remove_files  {/home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1/hdl/axil_bram_fft2_v3_1.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1/hdl/axil_bram_fft2_v3_1_S00_AXI.vhd}
update_compile_order -fileset sources_1
set_property top axi_fft2_v1_0 [current_fileset]

ipx::merge_project_changes files [ipx::current_core]
ipx::merge_project_changes hdl_parameters [ipx::current_core]
ipgui::add_param -name {DATA_WIDTH} -component [ipx::current_core] -display_name {Data Width} -show_label {true} -show_range {true} -widget {}
ipgui::add_param -name {FFT_SIZE} -component [ipx::current_core] -display_name {Fft Size} -show_label {true} -show_range {true} -widget {}
ipgui::add_param -name {FIXED_POINT_WIDTH} -component [ipx::current_core] -display_name {Fixed Point Width} -show_label {true} -show_range {true} -widget {}
ipgui::add_param -name {ADDR_WIDTH} -component [ipx::current_core] -display_name {Addr Width} -show_label {true} -show_range {true} -widget {}
set_property previous_version_for_upgrade user.org:user:axil_bram_fft2:3.1 [ipx::current_core]
set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1/FTN_user_axil_bram_fft2_3.1.zip [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project
update_ip_catalog -rebuild -repo_path /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axil_bram_fft2_3.1
