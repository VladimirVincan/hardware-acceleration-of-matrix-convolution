onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fft2_test_top/dut/clk
add wave -noupdate /fft2_test_top/dut/rst
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/data_i_addr_o
add wave -noupdate -expand -group fft2 -color Blue -radix hexadecimal /fft2_test_top/dut/dataRE_i
add wave -noupdate -expand -group fft2 -color Blue -radix hexadecimal /fft2_test_top/dut/dataIM_i
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/data_rd_o
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/data_rd_i
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/data_o_addr_o
add wave -noupdate -expand -group fft2 -color Blue -radix hexadecimal /fft2_test_top/dut/dataRE_o
add wave -noupdate -expand -group fft2 -color Blue -radix hexadecimal /fft2_test_top/dut/dataIM_o
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/data_wr_o
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/data_wr_i
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/log2w
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/width
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/log2h
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/height
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/start
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/ready
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/state_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/i_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/j_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/log2w_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/width_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/log2h_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/height_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/fft_data_i_addr_o_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/fft_data_o_addr_o_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/log2s_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/size_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/fft_data_rd_o_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/fft_data_wr_o_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/fft_start_r
add wave -noupdate -expand -group fft2 /fft2_test_top/dut/fft_ready_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_i_addr_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_rd_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_rd_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_o_addr_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_wr_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_wr_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/log2s
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/size
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/start
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/ready
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/state_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/i_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/j_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/k_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/jj_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/kk_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/reversed_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/temp_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/m2_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/addr_top
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/addr_bot
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE_top_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE_bot_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM_top_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM_bot_i
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE_top_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE_bot_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM_top_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM_bot_o
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/wr_top_s
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/wr_bot_s
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/rd_s
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/butterfly_start_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/butterfly_ready_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/topRE_i_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/topIM_i_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/botRE_i_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/botIM_i_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/topRE_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/topIM_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/botRE_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/botIM_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_i_addr_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_rd_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_rd_i_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_o_addr_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataRE_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/dataIM_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_wr_o_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/data_wr_i_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/log2s_r
add wave -noupdate -expand -group fft /fft2_test_top/dut/fft/size_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topRE_i
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topIM_i
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomRE_i
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomIM_i
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topRE_o
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topIM_o
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomRE_o
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomIM_o
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/k
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/size
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/start
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/ready
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/wCOS
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/wSIN
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/sumRE_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/sumIM_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/mult1_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/mult2_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/mult3_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/mult4_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topRE_o_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topIM_o_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomRE_o_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomIM_o_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topRE_i_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/topIM_i_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomRE_i_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/bottomIM_i_r
add wave -noupdate -expand -group butterfly /fft2_test_top/dut/fft/butterfly/state_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {60114 ns} 0}
configure wave -namecolwidth 293
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {52007 ns} {69845 ns}
