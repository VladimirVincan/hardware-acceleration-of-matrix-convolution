`ifndef FFT2_DIN_SIMPLE_SEQ_SV
`define FFT2_DIN_SIMPLE_SEQ_SV

class fft2_din_simple_seq extends fft2_din_base_seq;
	
    `uvm_object_utils(fft2_din_simple_seq)

	rand int height, width;
	
	function new(string name = "fft2_din_simple_seq");
		super.new(name);
	endfunction : new

    virtual task body();
		repeat(width*height)
			`uvm_do(req)
			
		// otvaranje fajla
		
		repeat(width*height)
			`uvm_do(req)
			// procitas red iz fajla i dodelis vrednost nekim promenljivima
			// `uvm_do_with... te vrednosti prosledis din transakciji
			
    endtask : body
    
endclass : fft2_din_simple_seq

`endif
