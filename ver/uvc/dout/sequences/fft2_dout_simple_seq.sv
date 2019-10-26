`ifndef FFT2_DOUT_SIMPLE_SEQ_SV
`define FFT2_DOUT_SIMPLE_SEQ_SV

class fft2_dout_simple_seq extends fft2_dout_base_seq;
	
    `uvm_object_utils(fft2_dout_simple_seq)

	rand int height, width;
	
	function new(string name = "fft2_dout_simple_seq");
		super.new(name);
	endfunction : new

    virtual task body();
		repeat(width*height*2)
			`uvm_do(req)
    endtask : body
    
endclass : fft2_dout_simple_seq

`endif
