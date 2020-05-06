`ifndef FFT2_TEST_SIMPLE_SV
`define FFT2_TEST_SIMPLE_SV

class fft2_test_simple extends fft2_test_base;

    `uvm_component_utils (fft2_test_simple)

	rand bit [$clog2($clog2(FFT_SIZE)) - 1 : 0] log2h, log2w;
	
	fft2_din_simple_seq din_seq;
	fft2_dout_simple_seq dout_seq;
	fft2_init_simple_seq init_seq;

    function new(string name = "fft2_test_simple", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		din_seq = fft2_din_simple_seq::type_id::create("din_seq");
		dout_seq = fft2_dout_simple_seq::type_id::create("dout_seq");
		init_seq = fft2_init_simple_seq::type_id::create("init_seq");
    endfunction : build_phase

	// string test_file = "test-vals.txt";
	// int tf;
    
    task run_phase(uvm_phase phase);
		assert(std::randomize(log2h) with {log2h > 1; log2h < 7;});
		assert(std::randomize(log2w) with {log2w > 1; log2w < 7;});
		// log2w = 1;
		// log2h = log2w;
		din_seq.height = 2**log2h;
		din_seq.width  = 2**log2w;
		
		dout_seq.height = 2**log2h;
		dout_seq.width  = 2**log2w;
		
		init_seq.log2h  = log2h-1;
		init_seq.log2w  = log2w-1;
		init_seq.height = 2**log2h-1;
		init_seq.width  = 2**log2w-1;

		//tf = $fopen(test_file, "a");
		//$fwrite(tf, "log2h = %0d, log2w = %0d\n", log2h, log2w);
		//$fclose(tf); 	
		$display("TEST VALUES: width = %0d, height = %0d\n", 2**log2w, 2**log2h);	

		phase.raise_objection(this);	
		fork
			din_seq.start(env.din_agent.seqr);
			dout_seq.start(env.dout_agent.seqr);
			init_seq.start(env.init_agent.seqr);
		join
		phase.drop_objection(this);
    endtask : run_phase

endclass : fft2_test_simple

`endif

