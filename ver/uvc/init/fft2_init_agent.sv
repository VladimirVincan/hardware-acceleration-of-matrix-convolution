`ifndef FFT2_INIT_AGENT_SV
`define FFT2_INIT_AGENT_SV

class fft2_init_agent extends uvm_agent;

    fft2_config       cfg;

    fft2_init_driver       drv;
    fft2_init_sequencer    seqr;
    fft2_init_monitor      mon;

    `uvm_component_utils_begin(fft2_init_agent)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end    

	function new(string name = "fft2_init_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

		seqr = fft2_init_sequencer::type_id::create("seqr", this);
		drv = fft2_init_driver::type_id::create("drv", this);
        mon = fft2_init_monitor::type_id::create("mon", this);
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
		drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction : connect_phase
    
endclass : fft2_init_agent

`endif

