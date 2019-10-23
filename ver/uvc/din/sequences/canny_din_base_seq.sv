`ifndef CANNY_DIN_BASE_SEQ_SV
`define CANNY_DIN_BASE_SEQ_SV
    
class canny_din_base_seq extends uvm_sequence #(canny_stream_data_seq_item, canny_stream_data_seq_item);
    
    `uvm_declare_p_sequencer(canny_din_sequencer)
    `uvm_object_utils(canny_din_base_seq)

	function new(string name = "canny_din_base_seq");
		super.new(name);
	endfunction : new

endclass : canny_din_base_seq

`endif

