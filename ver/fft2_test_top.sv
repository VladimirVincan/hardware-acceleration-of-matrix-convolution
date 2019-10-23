/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_test_top.sv

    DESCRIPTION     top

 ****************************************************************************/

`ifndef FFT2_TEST_TOP_SV
`define FFT2_TEST_TOP_SV

module fft2_test_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import fft2_pkg::*;
    
    `include "fft2_test_lib.sv" // 'include "ime-testa.sv"
    
    //`include "../dut/fft2.vhd"

    logic clk;
    logic rst;
    
    fft2_din_if #(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)) din_vif(clk, rst);
	fft2_dout_if #(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)) dout_vif(clk, rst);
    fft2_init_if #(.FFT_SIZE(FFT_SIZE)) init_vif(clk, rst);
       
    fft2 #( .FFT_SIZE(FFT_SIZE),
					 .FIXED_POINT_WIDTH(FIXED_POINT_WIDTH),
					 .DATA_WIDTH(DATA_WIDTH)
        ) dut (
				.clk(clk),
				.rst(rst),
				
				.data_i_addr_o    (din_vif.data_i_addr_o ),
				.dataRE_i    (din_vif.dataRE_i ),
				.dataIM_i    (din_vif.dataIM_i ),
				.data_rd_o    (din_vif.data_rd_o ),
				.data_rd_i    (din_vif.data_rd_i ),
				
				.data_o_addr_o    (dout_vif.data_o_addr_o ),
				.dataRE_o    (dout_vif.dataRE_o ),
				.dataIM_o    (dout_vif.dataIM_o ),
				.data_wr_o    (dout_vif.data_wr_o ),
				.data_wr_i    (dout_vif.data_wr_i ),
				
				.log2w    (init_vif.log2w ),
				.width    (init_vif.width ),
				.log2h    (init_vif.log2h ),
				.height    (init_vif.height ),
				.start    (init_vif.start ),
				.ready    (init_vif.ready )
		        );

    initial begin
        uvm_config_db#(virtual fft2_din_if #(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)))::set(null,"uvm_test_top.*","fft2_din_if", din_vif);
        uvm_config_db#(virtual fft2_dout_if #(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)))::set(null,"uvm_test_top.*","fft2_dout_if", dout_vif);
        uvm_config_db#(virtual fft2_init_if #(.FFT_SIZE(FFT_SIZE)))::set(null,"uvm_test_top.*","fft2_init_if", init_vif);
        run_test();
    end
    
    initial begin
        clk <= 1'b0;
		rst <= 1'b1;
        #10 rst <= 1'b0;
    end

    always #10 clk = ~clk;    

endmodule : fft2_test_top

`endif

