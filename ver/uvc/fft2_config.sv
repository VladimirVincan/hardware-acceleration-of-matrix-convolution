/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_config.sv

    DESCRIPTION     contains main and default configurations

 ****************************************************************************/

`ifndef FFT2_CONFIG_SV
`define FFT2_CONFIG_SV

/**
 * Class: fft2_config
 */
class fft2_config extends uvm_object;

    bit has_din;
    bit has_dout;
    bit has_init;

    // configurations for every agent
    fft2_dout_config dout_cfg;
    fft2_din_config din_cfg;
    fft2_init_config init_cfg;

    // control
    bit has_checks = 1;
    bit has_coverage = 1;

    // UVM factory registration
    `uvm_object_utils_begin(fft2_config)
        `uvm_field_int(has_dout, UVM_DEFAULT)
        `uvm_field_int(has_din, UVM_DEFAULT)
        `uvm_field_int(has_init, UVM_DEFAULT)
        `uvm_field_object(dout_cfg, UVM_DEFAULT)
        `uvm_field_object(din_cfg, UVM_DEFAULT)
        `uvm_field_object(init_cfg, UVM_DEFAULT)
        `uvm_field_int(has_checks, UVM_DEFAULT)
        `uvm_field_int(has_coverage, UVM_DEFAULT)
    `uvm_object_utils_end

    // new - constructor
    function new(string name = "fft2_config");
        super.new(name);
    endfunction : new
    
    // additional class methods
    extern function void add_dout(uvm_active_passive_enum is_active = UVM_ACTIVE);
    extern function void add_din(uvm_active_passive_enum is_active = UVM_ACTIVE);
    extern function void add_init(uvm_active_passive_enum is_active = UVM_ACTIVE);


endclass : fft2_config

// creates and configures a dout agent configuration
function void fft2_config::add_dout(uvm_active_passive_enum is_active = UVM_ACTIVE);
    has_dout = 1;
    dout_cfg = fft2_dout_config::type_id::create("dout_cfg");
    dout_cfg.is_active = is_active;
    dout_cfg.has_checks = has_checks;
    dout_cfg.has_coverage = has_coverage;
endfunction : add_dout

// creates and configures a din agent configuration
function void fft2_config::add_din(uvm_active_passive_enum is_active = UVM_ACTIVE);
    has_din = 1;
    din_cfg = fft2_din_config::type_id::create("din_cfg");
    din_cfg.is_active = is_active;
    din_cfg.has_checks = has_checks;
    din_cfg.has_coverage = has_coverage;
endfunction : add_din

// creates and configures a init agent configuration
function void fft2_config::add_init(uvm_active_passive_enum is_active = UVM_ACTIVE);
    has_init = 1;
    init_cfg = fft2_init_config::type_id::create("init_cfg");
    init_cfg.is_active = is_active;
    init_cfg.has_checks = has_checks;
    init_cfg.has_coverage = has_coverage;
endfunction : add_init

/**
 * Class: default_fft2_config
 * 
 * Description: default configuration - one master, no slaves
 */
class default_fft2_config extends fft2_config;

    `uvm_object_utils(default_fft2_config)

    function new(string name = "default_fft2_config");
        super.new(name);
        add_dout(UVM_ACTIVE);
        add_din(UVM_ACTIVE);
        add_init(UVM_ACTIVE);
    endfunction : new

endclass : default_fft2_config

`endif
