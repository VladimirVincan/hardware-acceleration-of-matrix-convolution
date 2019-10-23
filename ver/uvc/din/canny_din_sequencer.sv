`ifndef CANNY_DIN_SEQUENCER_SV
`define CANNY_DIN_SEQUENCER_SV

class canny_din_sequencer extends uvm_sequencer #(canny_stream_data_seq_item, canny_stream_data_seq_item);
    
    canny_config cfg;    
    
    `uvm_component_utils_begin(canny_din_sequencer)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end

	function new(string name = "canny_din_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(canny_config)::get(this, "", "canny_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase    

endclass : canny_din_sequencer

`endif

