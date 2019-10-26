`ifndef FFT2_INIT_BASE_SEQ_SV
`define FFT2_INIT_BASE_SEQ_SV
    
class fft2_init_base_seq extends uvm_sequence #(fft2_init_transaction, fft2_init_transaction);
    
    `uvm_declare_p_sequencer(fft2_init_sequencer)
    `uvm_object_utils(fft2_init_base_seq)

	function new(string name = "fft2_init_base_seq");
		super.new(name);
	endfunction : new

endclass : fft2_init_base_seq

`endif

