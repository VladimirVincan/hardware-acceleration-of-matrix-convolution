`ifndef FFT2_INIT_SEQUENCER_SV
`define FFT2_INIT_SEQUENCER_SV

class fft2_init_sequencer extends uvm_sequencer #(fft2_init_transaction, fft2_init_transaction);
    
    fft2_config cfg;    
    
    `uvm_component_utils_begin(fft2_init_sequencer)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end

	function new(string name = "fft2_init_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase    

endclass : fft2_init_sequencer

`endif

