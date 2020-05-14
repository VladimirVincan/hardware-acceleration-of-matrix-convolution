`ifndef FFT2_INIT_SIMPLE_SEQ_SV
`define FFT2_INIT_SIMPLE_SEQ_SV

class fft2_init_simple_seq extends fft2_init_base_seq;
	
    `uvm_object_utils(fft2_init_simple_seq)

	rand int height, width;
	rand int log2w, log2h;
	
	function new(string name = "fft2_init_simple_seq");
		super.new(name);
	endfunction : new

    virtual task body();
		`uvm_do_with(req, {req.log2w == local::log2w; req.log2h == local::log2h; req.width == local::width; req.height == local::height;})
    endtask : body
    
endclass : fft2_init_simple_seq

`endif
