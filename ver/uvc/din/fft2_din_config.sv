`ifndef FFT2_DIN_CONFIG_SV
`define FFT2_DIN_CONFIG_SV

class fft2_din_config extends uvm_object;

	// is agent active or passive
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    // checks and coverage control
    bit has_checks                    = 1;
    bit has_coverage                  = 1;

    // UVM factory registration
    `uvm_object_utils_begin(fft2_din_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
        `uvm_field_int(has_checks, UVM_DEFAULT)
        `uvm_field_int(has_coverage, UVM_DEFAULT)    
    `uvm_object_utils_end

    // new - constructor
	function new(string name = "fft2_din_config");
		super.new(name);
	endfunction : new

endclass : fft2_din_config

`endif

