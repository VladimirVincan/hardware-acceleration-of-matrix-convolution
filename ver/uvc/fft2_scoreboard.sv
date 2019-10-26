`ifndef FFT2_SCOREBOARD_SV
`define FFT2_SCOREBOARD_SV

`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_detected)

class fft2_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fft2_scoreboard)
	
	uvm_analysis_imp_expected #(fft2_dout_din_transaction, fft2_scoreboard) dout_expected;
	uvm_analysis_imp_detected #(fft2_dout_din_transaction, fft2_scoreboard) dout_detected;
	
	uvm_tlm_analysis_fifo #(fft2_dout_din_transaction) dout_expected_fifo;
	uvm_tlm_analysis_fifo #(fft2_dout_din_transaction) dout_detected_fifo;
	
	fft2_dout_din_transaction dout_expected_tr;
	fft2_dout_din_transaction dout_detected_tr;

	int num_of_successful_tr = 0;
	int num_of_failed_tr = 0;
	
	function new(string name = "fft2_scoreboard", uvm_component parent = null);
		super.new(name, parent);
		dout_expected_tr = new("dout_expected_tr");
		dout_detected_tr = new("dout_detected_tr");
	endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		dout_expected = new("dout_expected", this);
		dout_detected = new("dout_detected", this);
		
		dout_expected_fifo = new("dout_expected_fifo", this);
		dout_detected_fifo = new("dout_detected_fifo", this);
    endfunction : build_phase  

	
	task run();
		forever begin
			dout_expected_fifo.get(dout_expected_tr);
			dout_detected_fifo.get(dout_detected_tr);
			compare();
		end
	endtask: run
	
	virtual function void compare();
		$display("SCOREBOARD: %d %d %d %d", dout_expected_tr.dataRE_o, dout_detected_tr.dataRE_o, dout_expected_tr.dataIM_o, dout_detected_tr.dataIM_o);
		if((dout_expected_tr.dataRE_o == dout_detected_tr.dataRE_o) && (dout_expected_tr.dataIM_o == dout_detected_tr.dataIM_o)) begin
			`uvm_info(get_type_name() ,"Transaction success", UVM_HIGH);
			`uvm_info(get_type_name(), $sformatf("Tr expected :\n%s", dout_expected_tr.sprint()), UVM_HIGH)
			`uvm_info(get_type_name(), $sformatf("Tr detected :\n%s", dout_detected_tr.sprint()), UVM_HIGH)
			num_of_successful_tr++;
		end else begin
			`uvm_error(get_type_name() ,"Transaction fail");
			`uvm_info(get_type_name(), $sformatf("Tr expected :\n%s", dout_expected_tr.sprint()), UVM_LOW)
			`uvm_info(get_type_name(), $sformatf("Tr detected :\n%s", dout_detected_tr.sprint()), UVM_LOW)
			num_of_failed_tr++;
		end
	endfunction: compare
	
	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name() , $sformatf("Report: FFT2 scoreboard collected %0d successful transactions and %0d failed transactions. \n", num_of_successful_tr, num_of_failed_tr), UVM_LOW);
		if(!dout_expected_fifo.is_empty()) begin
			`uvm_info(get_type_name(), "Dout_expected_fifo not empty at the end.", UVM_LOW)
		end
		if(!dout_detected_fifo.is_empty()) begin
			`uvm_info(get_type_name(), "Dout_detected_fifo not empty at the end.", UVM_LOW)
		end
	endfunction: report_phase
	
	
	function void write_expected(fft2_dout_din_transaction seq_item);
		dout_expected_fifo.write(seq_item);
	endfunction
	
	function void write_detected(fft2_dout_din_transaction seq_item);
		dout_detected_fifo.write(seq_item);
	endfunction
endclass : fft2_scoreboard

`endif

