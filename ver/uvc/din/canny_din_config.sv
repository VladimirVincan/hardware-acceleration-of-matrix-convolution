`ifndef CANNY_DIN_CONFIG_SV
`define CANNY_DIN_CONFIG_SV

class canny_din_config extends uvm_object;

    bit has_checks                    = 0;
    bit has_coverage                  = 0;

    `uvm_object_utils_begin(canny_din_config)
        `uvm_field_int(has_checks, UVM_DEFAULT)
        `uvm_field_int(has_coverage, UVM_DEFAULT)    
    `uvm_object_utils_end

	function new(string name = "canny_din_config");
		super.new(name);
	endfunction : new

endclass : canny_din_config

`endif

