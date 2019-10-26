/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_env.sv

    DESCRIPTION     environment containing the master and slave agents

 ****************************************************************************/

`ifndef FFT2_ENV_SV
`define FFT2_ENV_SV

/**
 * Class: fft2_env
 */
class fft2_env extends uvm_env;
    
    fft2_din_agent din_agent; 
    fft2_dout_agent dout_agent;
    fft2_init_agent init_agent;   

    fft2_config cfg; // uvc configuration
	fft2_scoreboard scb;
	fft2_ref_model ref_i;

    // UVM factory registration
    `uvm_component_utils_begin(fft2_env)
        `uvm_field_object(cfg, UVM_DEFAULT)
		`uvm_field_object(scb, UVM_DEFAULT)
        `uvm_field_object(ref_i, UVM_DEFAULT)
    `uvm_component_utils_end    

    // new - constructor
	function new(string name = "fft2_env", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new
    
    // UVM build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // get configuration from db or use default configuration if none is set
        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg)) begin
            `uvm_info("NOCONFIG", "Using default_fft2_config", UVM_LOW)
            fft2_config::type_id::set_type_override(default_fft2_config::get_type(), 1);
            cfg = fft2_config::type_id::create("cfg");
        end
              
        // set the write configuration
        if(cfg.has_dout) begin
            uvm_config_db#(fft2_config)::set(this, "dout_agent*", "fft2_config", cfg);
        end
        // set the read configuration
        if(cfg.has_din) begin
            uvm_config_db#(fft2_config)::set(this, "din_agent*", "fft2_config", cfg);
        end
        // set the init configuration
        if(cfg.has_init) begin
            uvm_config_db#(fft2_config)::set(this, "init_agent*", "fft2_config", cfg);
        end
        
        // create agents
        if(cfg.has_dout) begin
            dout_agent = fft2_dout_agent::type_id::create("dout_agent",this);
        end
        if(cfg.has_din) begin
            din_agent = fft2_din_agent::type_id::create("din_agent",this);
        end
        if(cfg.has_init) begin
            init_agent = fft2_init_agent::type_id::create("init_agent",this);
        end
		
		scb = fft2_scoreboard::type_id::create("scb", this);
		ref_i = fft2_ref_model::type_id::create("ref_i", this);
		
	endfunction : build_phase  
	
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		dout_agent.mon.item_collected_port.connect(scb.dout_detected);
		init_agent.mon.item_collected_port.connect(ref_i.port_init);
		din_agent.mon.item_collected_port.connect(ref_i.port_din);
		ref_i.item_collected_port.connect(scb.dout_expected);
	endfunction: connect_phase

endclass : fft2_env

`endif

