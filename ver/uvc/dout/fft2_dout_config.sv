/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_master_config.sv

    DESCRIPTION     master configuration object

 ****************************************************************************/

`ifndef FFT2_DOUT_CONFIG_SV
`define FFT2_DOUT_CONFIG_SV

/**
 * Class: fft2_dout_config
 */
class fft2_dout_config extends uvm_object;

    // is agent active or passive
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    // checks and coverage control
    bit has_checks                    = 1;
    bit has_coverage                  = 1;

    // UVM factory registration
    `uvm_object_utils_begin(fft2_dout_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
        `uvm_field_int(has_checks, UVM_DEFAULT)
        `uvm_field_int(has_coverage, UVM_DEFAULT)    
    `uvm_object_utils_end

    // new - constructor
	function new(string name = "fft2_dout_config");
		super.new(name);
	endfunction : new

endclass : fft2_dout_config

`endif

