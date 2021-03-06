`ifndef FFT2_DIN_DRIVER_SV
`define FFT2_DIN_DRIVER_SV

class fft2_din_driver extends uvm_driver #(fft2_dout_din_transaction, fft2_dout_din_transaction);
    
    virtual fft2_din_if#(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)) din_vif;
    fft2_config cfg;
    
    `uvm_component_utils_begin(fft2_din_driver)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end       

	function new(string name = "fft2_din_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fft2_config)::get(this, "*", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase
 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual fft2_din_if#(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)))::get(this, "", "fft2_din_if", din_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".din_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task get_and_drive();
    extern virtual task reset();
    extern virtual task drive_tr (fft2_dout_din_transaction tr);
    
endclass : fft2_din_driver

task fft2_din_driver::run_phase(uvm_phase phase);
    reset();
    forever begin
        fork
            get_and_drive();
            @(posedge din_vif.rst);
        join_any
        disable fork;
        reset();
    end
endtask : run_phase

task fft2_din_driver::reset();
    `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
	
    din_vif.dataRE_i    <= {DATA_WIDTH {1'b0}};
    din_vif.dataIM_i    <= {DATA_WIDTH {1'b0}};
    din_vif.data_rd_i   <= 1'b0;

    @(negedge din_vif.rst);
endtask : reset

task fft2_din_driver::get_and_drive();
    forever begin
        //$display("DIN_DRIVER: break1");
        seq_item_port.get_next_item(req);
        //$display("DIN_DRIVER: break2");
        drive_tr(req);
        //$display("DIN_DRIVER: ovde");
        seq_item_port.item_done();
    end
endtask : get_and_drive

task fft2_din_driver::drive_tr (fft2_dout_din_transaction tr);
	
    din_vif.dataRE_i    <= tr.dataRE_i;
    din_vif.dataIM_i    <= tr.dataIM_i;
	din_vif.data_rd_i <= 1'b0;
    //$display("DIN_DRIVER: break3: %d", din_vif.data_rd_o);
	@(posedge din_vif.clk iff din_vif.data_rd_o == 1'b1);
    //$display("DIN_DRIVER: break4: %d", din_vif.data_rd_o);
	din_vif.data_rd_i <= 1'b1;
	@(posedge din_vif.clk iff din_vif.data_rd_o == 1'b0);
    //$display("DIN_DRIVER: break5: %d", din_vif.data_rd_o);
	din_vif.data_rd_i <= 1'b0;
    `uvm_info(get_type_name(), $sformatf("FFT2 Finished Driving tr \n%s", tr.sprint()), UVM_HIGH)
endtask : drive_tr

`endif

