`ifndef FFT2_DIN_SIMPLE_SEQ_SV
`define FFT2_DIN_SIMPLE_SEQ_SV

class fft2_din_simple_seq extends fft2_din_base_seq;
	
    `uvm_object_utils(fft2_din_simple_seq)

	rand int height, width;
	int f_is_open;
	string file = "dout-monitor-orig.txt";

	int addr = 0; // not important
	int i = 0;
	int j = 0;
	
	int matrix_re[0:FFT_SIZE][0:FFT_SIZE];
	int matrix_im[0:FFT_SIZE][0:FFT_SIZE];
	
	function new(string name = "fft2_din_simple_seq");
		super.new(name);
	endfunction : new

    virtual task body();
	 	$display("DIN_SIMPLE_SEQ: width, height = %d, %d", width, height);
		 
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})

		// `uvm_do_with(req, { dataRE_i == 32'h10000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h20000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h30000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h40000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h50000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h60000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h70000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h80000; dataIM_i == 32'h0;})

		// `uvm_do_with(req, { dataRE_i == 32'h10000; dataIM_i == 32'h90000;})
		// `uvm_do_with(req, { dataRE_i == 32'h20000; dataIM_i == 32'ha0000;})
		// `uvm_do_with(req, { dataRE_i == 32'h30000; dataIM_i == 32'hb0000;})
		// `uvm_do_with(req, { dataRE_i == 32'h40000; dataIM_i == 32'hc0000;})
		// `uvm_do_with(req, { dataRE_i == 32'h50000; dataIM_i == 32'hd0000;})
		// `uvm_do_with(req, { dataRE_i == 32'h60000; dataIM_i == 32'he0000;})
		// `uvm_do_with(req, { dataRE_i == 32'h70000; dataIM_i == 32'hf0000;})
		// `uvm_do_with(req, { dataRE_i == 32'h80000; dataIM_i == 32'h00000;})

		// `uvm_do_with(req, { dataRE_i == -65536; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == -65536;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})

		// repeat(width*(height-1))
		// 	`uvm_do_with(req, { dataRE_i == 32'h0; dataIM_i == 32'h0;})

		repeat(width*(height))
			`uvm_do_with(req, { dataRE_i [DATA_WIDTH-1 : DATA_WIDTH-8] == 16'h0; dataIM_i [DATA_WIDTH-1 : DATA_WIDTH-8] == 16'h0;})
	
		// repeat(width*(height))
		// 	`uvm_do_with(req, { dataRE_i [DATA_WIDTH-1 : DATA_WIDTH-16] == 16'h0; dataIM_i == 32'h0;})

		// otvaranje fajla
		// $display("Otvaranje fajla");
		f_is_open = $fopen(file, "r");  
		if(f_is_open) begin
			// $display("File simple seq was opened successfully");
		end	else begin
			$display("File simple seq was not opened successfully");
		end

		i = 0;
		j = 0;

		#10us
		repeat(width*height) begin
			$fscanf(f_is_open, "%d, %d, %d", addr, matrix_re[i][j], matrix_im[i][j]);
			// $display("Ucitao na lokaciji %d %d , vrednosti %d %d %d", i, j, addr, matrix_re[i][j], matrix_im[i][j]);
			j = j + 1;
			if (j == width) begin
				j = 0;
				i = i+1;
			end
		end
		
		$fclose(file);
		i=0;
		j=0;
		repeat(width*height) begin
			`uvm_do_with(req, {dataRE_i==matrix_re[j][i]; dataIM_i==matrix_im[j][i];})
			//$display("width: %d height: %d", width, height);
			//$display("vals: %d %d %d", matrix_re[j][i], i , j);
			j = j + 1;
			if (j == width) begin
				j = 0;
				i = i + 1;
			end
			// procitas red iz fajla i dodelis vrednost nekim promenljivima
			// `uvm_do_with... te vrednosti prosledis din transakciji
		end

    endtask : body
    
endclass : fft2_din_simple_seq

`endif
