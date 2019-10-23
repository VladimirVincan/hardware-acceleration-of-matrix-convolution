`ifndef CANNY_DOUT_DRIVER_SV
`define CANNY_DOUT_DRIVER_SV

class canny_dout_driver extends uvm_driver #(canny_stream_data_seq_item, canny_stream_data_seq_item);
    
    virtual canny_stream_if#(.DATA_WIDTH(4*W_DATA)) dout_vif;
    
    canny_config cfg;
    
    `uvm_component_utils_begin(canny_dout_driver)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end       

	function new(string name = "canny_dout_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(canny_config)::get(this, "*", "canny_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase
 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual canny_stream_if#(.DATA_WIDTH(4*W_DATA)))::get(this, "", "canny_dout_if", dout_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".dout_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task get_and_drive();
    extern virtual task reset();
    extern virtual task drive_tr (canny_stream_data_seq_item tr);
    
endclass : canny_dout_driver

task canny_dout_driver::run_phase(uvm_phase phase);
    reset();
    forever begin
        fork
            get_and_drive();
            @(negedge dout_vif.arst);
        join_any
        disable fork;
        reset();
    end
endtask : run_phase

task canny_dout_driver::reset();
    `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
	
    dout_vif.tready    <= 1'b0;
	
    @(posedge dout_vif.arst);
endtask : reset

task canny_dout_driver::get_and_drive();
    forever begin
        seq_item_port.get_next_item(req);
        drive_tr(req);
        seq_item_port.item_done();
    end
endtask : get_and_drive

task canny_dout_driver::drive_tr (canny_stream_data_seq_item tr);
    @(posedge dout_vif.clk);
    if (tr.delay > 0) begin
        repeat(tr.delay) @(posedge dout_vif.clk);
    end
    dout_vif.tready    <= 1'b1;
	@(posedge dout_vif.clk iff dout_vif.tvalid);
	dout_vif.tready <= 1'b0;
    `uvm_info(get_type_name(), $sformatf("CANNY Finished Driving tr \n%s", tr.sprint()), UVM_HIGH)
endtask : drive_tr

`endif

