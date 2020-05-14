`ifndef FFT2_SCOREBOARD_SV
`define FFT2_SCOREBOARD_SV

`uvm_analysis_imp_decl(_init)
`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_detected)

class fft2_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fft2_scoreboard)
	
	uvm_analysis_imp_init #(fft2_init_transaction, fft2_scoreboard) port_init;
	uvm_analysis_imp_expected #(fft2_dout_din_transaction, fft2_scoreboard) din_expected;
	uvm_analysis_imp_detected #(fft2_dout_din_transaction, fft2_scoreboard) din_detected;
	uvm_analysis_imp_expected #(fft2_dout_din_transaction, fft2_scoreboard) dout_expected;
	uvm_analysis_imp_detected #(fft2_dout_din_transaction, fft2_scoreboard) dout_detected;

	uvm_tlm_analysis_fifo #(fft2_init_transaction) init_fifo;
	uvm_tlm_analysis_fifo #(fft2_dout_din_transaction) din_expected_fifo;
	uvm_tlm_analysis_fifo #(fft2_dout_din_transaction) din_detected_fifo;
	uvm_tlm_analysis_fifo #(fft2_dout_din_transaction) dout_expected_fifo;
	uvm_tlm_analysis_fifo #(fft2_dout_din_transaction) dout_detected_fifo;

	fft2_init_transaction init_tr;
	fft2_dout_din_transaction din_expected_tr;
	fft2_dout_din_transaction din_detected_tr;	
	fft2_dout_din_transaction dout_expected_tr;
	fft2_dout_din_transaction dout_detected_tr;

	int num_of_successful_tr = 0;
	int num_of_failed_tr = 0;

	int height, width;
	
	function new(string name = "fft2_scoreboard", uvm_component parent = null);
		super.new(name, parent);
		init_tr = new("init_tr");
		din_expected_tr = new("din_expected_tr");
		din_detected_tr = new("din_detected_tr");
		dout_expected_tr = new("dout_expected_tr");
		dout_detected_tr = new("dout_detected_tr");
	endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		port_init = new("port_init", this);
		din_expected = new("din_expected", this);
		din_detected = new("din_detected", this);
		dout_expected = new("dout_expected", this);
		dout_detected = new("dout_detected", this);
		
		init_fifo = new("init_fifo", this);
		din_expected_fifo = new("din_expected_fifo", this);
		din_detected_fifo = new("din_detected_fifo", this);
		dout_expected_fifo = new("dout_expected_fifo", this);
		dout_detected_fifo = new("dout_detected_fifo", this);
    endfunction : build_phase  

	
	task run();
		init_fifo.get(init_tr);
		width = init_tr.width + 1;
		height = init_tr.height + 1;
		forever begin
			repeat (width*height) begin
				din_expected_fifo.get(din_expected_tr);
				din_detected_fifo.get(din_detected_tr);
				compare_din();
			end
			repeat (width*height) begin
				dout_expected_fifo.get(dout_expected_tr);
				dout_detected_fifo.get(dout_detected_tr);
				compare_dout();
			end
		end
	endtask: run
	
	virtual function void compare_din();
		// $display("SCOREBOARD: %d %d %d %d", dout_expected_tr.dataRE_o, dout_detected_tr.dataRE_o, dout_expected_tr.dataIM_o, dout_detected_tr.dataIM_o);
		if (din_expected_tr.data_i_addr_o == din_detected_tr.data_i_addr_o) begin
			`uvm_info(get_type_name() ,"Transaction success", UVM_HIGH);
			`uvm_info(get_type_name(), $sformatf("Tr expected :\n%s", din_expected_tr.sprint()), UVM_HIGH)
			`uvm_info(get_type_name(), $sformatf("Tr detected :\n%s", din_detected_tr.sprint()), UVM_HIGH)
			num_of_successful_tr++;
		end else begin
			`uvm_error(get_type_name() ,"Transaction fail");
			`uvm_info(get_type_name(), $sformatf("Tr expected :\n%s", din_expected_tr.sprint()), UVM_LOW)
			`uvm_info(get_type_name(), $sformatf("Tr detected :\n%s", din_detected_tr.sprint()), UVM_LOW)
			num_of_failed_tr++;
		end
	endfunction: compare_din

	virtual function void compare_dout();
		// $display("SCOREBOARD: %d %d %d %d", dout_expected_tr.dataRE_o, dout_detected_tr.dataRE_o, dout_expected_tr.dataIM_o, dout_detected_tr.dataIM_o);
		if((dout_expected_tr.data_o_addr_o == dout_detected_tr.data_o_addr_o)
	    && (dout_expected_tr.dataRE_o == dout_detected_tr.dataRE_o) 
		&& (dout_expected_tr.dataIM_o == dout_detected_tr.dataIM_o)) begin
			`uvm_info(get_type_name() ,"Transaction success", UVM_HIGH);
			`uvm_info(get_type_name(), $sformatf("Dout tr expected :\n%s", dout_expected_tr.sprint()), UVM_HIGH)
			`uvm_info(get_type_name(), $sformatf("Dout tr detected :\n%s", dout_detected_tr.sprint()), UVM_HIGH)
			num_of_successful_tr++;
		end else begin
			`uvm_error(get_type_name() ,"Transaction fail");
			`uvm_info(get_type_name(), $sformatf("Dout tr expected :\n%s", dout_expected_tr.sprint()), UVM_LOW)
			`uvm_info(get_type_name(), $sformatf("Dout tr detected :\n%s", dout_detected_tr.sprint()), UVM_LOW)
			num_of_failed_tr++;
		end
	endfunction: compare_dout
	
	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name() , $sformatf("Report: FFT2 scoreboard collected %0d successful transactions and %0d failed transactions. \n", num_of_successful_tr, num_of_failed_tr), UVM_LOW);
		if(!dout_expected_fifo.is_empty()) begin
			`uvm_info(get_type_name(), "Dout_expected_fifo not empty at the end.", UVM_LOW)
		end
		if(!dout_detected_fifo.is_empty()) begin
			`uvm_info(get_type_name(), "Dout_detected_fifo not empty at the end.", UVM_LOW)
		end
	endfunction: report_phase
	
	
	function void write_init(fft2_init_transaction seq_item);
		init_fifo.write(seq_item);
	endfunction

	function void write_expected(fft2_dout_din_transaction seq_item);
		dout_expected_fifo.write(seq_item);
	endfunction
	
	function void write_detected(fft2_dout_din_transaction seq_item);
		dout_detected_fifo.write(seq_item);
	endfunction
endclass : fft2_scoreboard

`endif

