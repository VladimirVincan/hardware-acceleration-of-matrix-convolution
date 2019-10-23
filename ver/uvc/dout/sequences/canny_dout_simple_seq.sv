`ifndef CANNY_DOUT_SIMPLE_SEQ_SV
`define CANNY_DOUT_SIMPLE_SEQ_SV

class canny_dout_simple_seq extends canny_dout_base_seq;
    
    rand int unsigned layer_num;
    rand int unsigned x_size, y_size;
	int layer_cnt;
	
    `uvm_object_utils(canny_dout_simple_seq)

	function new(string name = "canny_dout_simple_seq");
		super.new(name);
	endfunction : new

    virtual task body();
		for(layer_cnt = 0; layer_cnt < layer_num; layer_cnt++) begin
			repeat(x_size*y_size) begin
				`uvm_do(req)
			end
		end
		repeat((x_size*y_size/2)*2) begin
			`uvm_do_with(req, {req.layer == layer_cnt;})
		end
		#5000ns;
    endtask : body
    
endclass : canny_dout_simple_seq

`endif
