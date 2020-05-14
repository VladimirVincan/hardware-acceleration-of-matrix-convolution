/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_dout_agent.sv

    DESCRIPTION     dout agent

 ****************************************************************************/

`ifndef FFT2_DOUT_AGENT_SV
`define FFT2_DOUT_AGENT_SV
    
/**
 * Class: fft2_dout_agent
 */
class fft2_dout_agent extends uvm_agent;
    
    // configuration object
    fft2_config       cfg;

    // components
    fft2_dout_driver       drv;
    fft2_dout_sequencer    seqr;
    fft2_dout_monitor      mon;

    // UVM factory registration
    `uvm_component_utils_begin(fft2_dout_agent)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end    

    // new - constructor
	function new(string name = "fft2_dout_agent", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
    
    // UVM build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // get configuration object from db
        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

        // create driver and sequencer if agent is active
        if(cfg.dout_cfg.is_active == UVM_ACTIVE) begin
            seqr = fft2_dout_sequencer::type_id::create("seqr", this);
            drv = fft2_dout_driver::type_id::create("drv", this);
        end
        // always create monitor
        mon = fft2_dout_monitor::type_id::create("mon", this);
    endfunction : build_phase

    // UVM connect_phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // connect driver and sequencer if agent is active
        if(cfg.dout_cfg.is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction : connect_phase
    
endclass : fft2_dout_agent

`endif

