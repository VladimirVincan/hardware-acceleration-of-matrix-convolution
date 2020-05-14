`ifndef FFT2_DIN_SIMPLE_SEQ_SV
`define FFT2_DIN_SIMPLE_SEQ_SV

class fft2_din_simple_seq extends fft2_din_base_seq;
	
    `uvm_object_utils(fft2_din_simple_seq)

	rand int height, width, log2h, log2w;
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
	 	//$display("DIN_SIMPLE_SEQ: width, height = %d, %d", width, height);
		 
		repeat(width*height)
			`uvm_do(req)
		// `uvm_do_with(req, { dataRE_i == 32'h00000; dataIM_i == 32'h0;})

		// otvaranje fajla
		// $display("Otvaranje fajla");
		f_is_open = $fopen(file, "r");  
		if(f_is_open) begin
			$display("File simple seq was opened successfully");
		end	else begin
			$display("File simple seq was not opened successfully");
		end

		i = 0;
		j = 0;

		#100us
		repeat(width*height) begin
			$fscanf(f_is_open, "%d, %h, %h", addr, matrix_re[i][j], matrix_im[i][j]);
			// $display("Ucitao na lokaciji %d %d , vrednosti %d %d %d", i, j, addr, matrix_re[i][j], matrix_im[i][j]);
			j = j + 1;
			if (j == width) begin
				j = 0;
				i = i+1;
			end
		end
		
		$fclose(file);
		for (j = 0; j<width; ++j) begin
			for (i = 0; i<height; ++i) begin
				int reversed =0;
				int temp = i;
				for(int k = 0; k < $clog2(height); ++k) begin
					reversed=reversed << 1;
					reversed = reversed | (temp & 1);
					temp = temp >> 1;
				end
				`uvm_do_with(req, {dataRE_i==matrix_re[reversed][j]; dataIM_i==matrix_im[reversed][j];})
				// $display("width: %0d height: %0d log2w: %0d", width, height, log2w);
				// $display("[%0d, %0d] %0d %0d", i,j, matrix_re[reversed][j], matrix_im[reversed][j]);
			end
		end
		
	
    endtask : body
    
endclass : fft2_din_simple_seq

`endif
