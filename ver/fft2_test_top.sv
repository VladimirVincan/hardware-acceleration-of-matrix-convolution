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
    
    //`include "../dut/fft2_ip_v1_0.vhd"

    logic clk;
    logic rst;
    
    fft2_din_if #(.DATA_WIDTH(4*W_DATA)) din_vif(clk, rst);
	fft2_dout_if #(.ADDR_WIDTH(W_BUFFER), .DATA_WIDTH(W_BUFFER)) dout_vif(clk, rst);
    fft2_init_if #(.DATA_WIDTH(4*W_DATA)) dout_vif(clk, rst, arst);
       
    fft2_ip_v1_0 #( .C_din_TDATA_WIDTH(4*W_DATA),
					 .C_dout_TDATA_WIDTH(4*W_DATA),
					 .C_cfg_DATA_WIDTH(W_BUFFER),
					 .C_cfg_ADDR_WIDTH(W_BUFFER),
					 .C_cmd_dm_din_TDATA_WIDTH(40+W_BUFFER),
					 .W_BUFFER(W_BUFFER),
					 .C_cmd_dm_dout_TDATA_WIDTH(40+W_BUFFER)
        ) dut (
				.din_aclk(clk),
				.cfg_aclk(clk),
				.cfg_aresetn(arst),
				
				.cfg_awaddr   (cfg_vif.awaddr),
				.cfg_awprot   (cfg_vif.awprot),
				.cfg_awvalid   (cfg_vif.awvalid),
				.cfg_awready   (cfg_vif.awready),
				.cfg_wdata   (cfg_vif.wdata),
				.cfg_wstrb   (cfg_vif.wstrb),
				.cfg_wvalid   (cfg_vif.wvalid),
				.cfg_wready   (cfg_vif.wready),
				.cfg_bresp   (cfg_vif.bresp),
				.cfg_bvalid   (cfg_vif.bvalid),
				.cfg_bready   (cfg_vif.bready),
				.cfg_araddr   (cfg_vif.araddr),
				.cfg_arprot   (cfg_vif.arprot),
				.cfg_arvalid   (cfg_vif.arvalid),
				.cfg_arready   (cfg_vif.arready),
				.cfg_rdata   (cfg_vif.rdata),
				.cfg_rresp   (cfg_vif.rresp),
				.cfg_rvalid   (cfg_vif.rvalid),
				.cfg_rready   (cfg_vif.rready),
			
				.din_tready   (din_vif.tready),
				.din_tdata   (din_vif.tdata),
				.din_tstrb   (din_vif.tstrb),
				.din_tlast   (din_vif.tlast),
				.din_tvalid   (din_vif.tvalid),

				.dout_tready   (dout_vif.tready),
				.dout_tdata   (dout_vif.tdata),
				.dout_tstrb   (dout_vif.tstrb),
				.dout_tlast   (dout_vif.tlast),
				.dout_tvalid   (dout_vif.tvalid),   
	
				.cmd_dm_din_tready   (cmd_din_vif.tready),
				.cmd_dm_din_tdata   (cmd_din_vif.tdata),
				.cmd_dm_din_tstrb   (cmd_din_vif.tstrb),
				.cmd_dm_din_tlast   (cmd_din_vif.tlast),
				.cmd_dm_din_tvalid   (cmd_din_vif.tvalid), 		

				.cmd_dm_dout_tready   (cmd_dout_vif.tready),
				.cmd_dm_dout_tdata   (cmd_dout_vif.tdata),
				.cmd_dm_dout_tstrb   (cmd_dout_vif.tstrb),
				.cmd_dm_dout_tlast   (cmd_dout_vif.tlast),
				.cmd_dm_dout_tvalid   (cmd_dout_vif.tvalid), 				
			
				.rst (rst)
        );

    initial begin
        uvm_config_db#(virtual fft2_lite_if #(.ADDR_WIDTH(W_BUFFER), .DATA_WIDTH(W_BUFFER)))::set(null,"uvm_test_top.*","fft2_cfg_if", cfg_vif);
        uvm_config_db#(virtual fft2_stream_if #(.DATA_WIDTH(4*W_DATA)))::set(null,"uvm_test_top.*","fft2_din_if", din_vif);
        uvm_config_db#(virtual fft2_stream_if #(.DATA_WIDTH(4*W_DATA)))::set(null,"uvm_test_top.*","fft2_dout_if", dout_vif);
        uvm_config_db#(virtual fft2_stream_if #(.DATA_WIDTH(40+W_BUFFER)))::set(null,"uvm_test_top.*","fft2_cmd_din_if", cmd_din_vif);
        uvm_config_db#(virtual fft2_stream_if #(.DATA_WIDTH(40+W_BUFFER)))::set(null,"uvm_test_top.*","fft2_cmd_dout_if", cmd_dout_vif);
        run_test();
    end
    
    initial begin
        clk <= 1'b0;
        arst <= 1'b0;
		rst <= 1'b1;
        #40 arst <= 1'b1;
        rst <= 1'b0;
    end

    always #10 clk = ~clk;    

endmodule : fft2_test_top

`endif

