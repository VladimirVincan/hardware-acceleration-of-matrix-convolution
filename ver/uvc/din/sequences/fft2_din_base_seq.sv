`ifndef FFT2_DIN_BASE_SEQ_SV
`define FFT2_DIN_BASE_SEQ_SV
    
class fft2_din_base_seq extends uvm_sequence #(fft2_dout_din_transaction, fft2_dout_din_transaction);
    
    `uvm_declare_p_sequencer(fft2_din_sequencer)
    `uvm_object_utils(fft2_din_base_seq)

	function new(string name = "fft2_din_base_seq");
		super.new(name);
	endfunction : new

endclass : fft2_din_base_seq

`endif

