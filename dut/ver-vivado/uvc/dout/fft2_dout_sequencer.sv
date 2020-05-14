/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_dout_sequencer.sv

    DESCRIPTION     

 ****************************************************************************/

`ifndef FFT2_DOUT_SEQUENCER_SV
`define FFT2_DOUT_SEQUENCER_SV

/**
 * Class: fft2_dout_sequencer
 */
class fft2_dout_sequencer extends uvm_sequencer #(fft2_dout_din_transaction);
    
    // configuration
    fft2_config cfg;    
    
    // UVM factory registration
    `uvm_component_utils_begin(fft2_dout_sequencer)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end

    // new - constructor
	function new(string name = "fft2_dout_sequencer", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
    
    // UVM build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // get configuration object from db
        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase    

endclass : fft2_dout_sequencer

`endif