`ifndef CANNY_DIN_AGENT_SV
`define CANNY_DIN_AGENT_SV

class canny_din_agent extends uvm_agent;

    canny_config       cfg;

    canny_din_driver       drv;
    canny_din_sequencer    seqr;
    canny_din_monitor      mon;

    `uvm_component_utils_begin(canny_din_agent)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end    

	function new(string name = "canny_din_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(canny_config)::get(this, "", "canny_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

		seqr = canny_din_sequencer::type_id::create("seqr", this);
		drv = canny_din_driver::type_id::create("drv", this);
        mon = canny_din_monitor::type_id::create("mon", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
		drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction : connect_phase
    
endclass : canny_din_agent

`endif

