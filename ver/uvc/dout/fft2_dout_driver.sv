`ifndef FFT2_DOUT_DRIVER_SV
`define FFT2_DOUT_DRIVER_SV

class fft2_dout_driver extends uvm_driver #(fft2_dout_din_transaction, fft2_dout_din_transaction);
    
    virtual fft2_dout_if#(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)) dout_vif;
    fft2_config cfg;
    
    `uvm_component_utils_begin(fft2_dout_driver)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end       

	function new(string name = "fft2_dout_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fft2_config)::get(this, "*", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase
 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual fft2_dout_if#(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)))::get(this, "", "fft2_dout_if", dout_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".dout_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task get_and_drive();
    extern virtual task reset();
    extern virtual task drive_tr (fft2_dout_din_transaction tr);
    
endclass : fft2_dout_driver

task fft2_dout_driver::run_phase(uvm_phase phase);
    reset();
    forever begin
        fork
            get_and_drive();
            @(posedge dout_vif.rst);
        join_any
        disable fork;
        reset();
    end
endtask : run_phase

task fft2_dout_driver::reset();
    `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
	
    dout_vif.data_wr_i   <= 1'b0;
		
    @(negedge dout_vif.rst);
endtask : reset

task fft2_dout_driver::get_and_drive();
    forever begin
        seq_item_port.get_next_item(req);
        drive_tr(req);
        $display("DOUT_DRIVER: ovde");
        seq_item_port.item_done();
    end
endtask : get_and_drive

task fft2_dout_driver::drive_tr (fft2_dout_din_transaction tr);

    dout_vif.data_wr_i <= 1'b0;
	@(posedge dout_vif.clk iff dout_vif.data_wr_o);
	dout_vif.data_wr_i <= 1'b1;
	@(posedge dout_vif.clk iff dout_vif.data_wr_o == 1'b0);
	dout_vif.data_wr_i <= 1'b0;
    `uvm_info(get_type_name(), $sformatf("FFT2 Finished Driving tr \n%s", tr.sprint()), UVM_HIGH)
endtask : drive_tr

`endif

