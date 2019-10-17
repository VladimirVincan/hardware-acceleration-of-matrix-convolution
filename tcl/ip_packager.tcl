create_peripheral user.org user axi_fft2 3.0 -dir /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo
add_peripheral_interface S00_AXI -interface_mode slave -axi_type lite [ipx::find_open_core user.org:user:axi_fft2:3.0]
generate_peripheral -driver -bfm_example_design -debug_hw_example_design -force [ipx::find_open_core user.org:user:axi_fft2:3.0]
write_peripheral [ipx::find_open_core user.org:user:axi_fft2:3.0]
set_property  ip_repo_paths  {/home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/fft2_2.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/fft2_2.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/fft2_1.0 /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_1.0} [current_project]
update_ip_catalog -rebuild
ipx::edit_ip_in_project -upgrade true -name edit_axi_fft2_v3_0 -directory /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0/component.xml
update_compile_order -fileset sources_1
add_files -norecurse -copy_to /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0/src {/home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/mem_subsystem.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/bram_if.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/fft2.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/utils_pkg.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/butterfly.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/axi_fft2_v1_0.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/rtl/fft.vhd /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip/axi_fft2_v1_0_S00_AXI.vhd}
update_compile_order -fileset sources_1
ipx::merge_project_changes files [ipx::current_core]
set_property taxonomy {/AXI_Peripheral /Digital_Signal_Processing/Transforms/FFTs} [ipx::current_core]
export_ip_user_files -of_objects  [get_files /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0/hdl/axi_fft2_v3_0.vhd] -no_script -reset -force -quiet
remove_files  /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0/hdl/axi_fft2_v3_0.vhd
update_compile_order -fileset sources_1
set_property top axi_fft2_v1_0 [current_fileset]
export_ip_user_files -of_objects  [get_files /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0/hdl/axi_fft2_v3_0_S00_AXI.vhd] -no_script -reset -force -quiet
remove_files  /home/bici/Desktop/hardware-acceleration-of-matrix-convolution/ip_repo/axi_fft2_3.0/hdl/axi_fft2_v3_0_S00_AXI.vhd
ipx::merge_project_changes files [ipx::current_core]
ipx::merge_project_changes hdl_parameters [ipx::current_core]
ipgui::add_param -name {DATA_WIDTH} -component [ipx::current_core] -display_name {Data Width} -show_label {true} -show_range {true} -widget {}
ipgui::add_param -name {FFT_SIZE} -component [ipx::current_core] -display_name {Fft Size} -show_label {true} -show_range {true} -widget {}
ipgui::add_param -name {FIXED_POINT_WIDTH} -component [ipx::current_core] -display_name {Fixed Point Width} -show_label {true} -show_range {true} -widget {}
ipgui::add_param -name {ADDR_WIDTH} -component [ipx::current_core] -display_name {Addr Width} -show_label {true} -show_range {true} -widget {}
