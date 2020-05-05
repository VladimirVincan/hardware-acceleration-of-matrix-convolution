`ifndef FFT2_REF_MODEL_SV
`define FFT2_REF_MODEL_SV

`uvm_analysis_imp_decl(_init)
`uvm_analysis_imp_decl(_din)

class fft2_ref_model extends uvm_component;
    `uvm_component_utils(fft2_ref_model)

	uvm_analysis_port #(fft2_dout_din_transaction) item_collected_port;
	
	uvm_analysis_imp_init #(fft2_init_transaction, fft2_ref_model) port_init;
	uvm_analysis_imp_din #(fft2_dout_din_transaction, fft2_ref_model) port_din;
	
	uvm_tlm_analysis_fifo #(fft2_init_transaction) init_fifo;
	uvm_tlm_analysis_fifo #(fft2_dout_din_transaction) din_fifo;
	
	fft2_init_transaction init_tr;
	fft2_dout_din_transaction din_tr;
	fft2_dout_din_transaction dout_tr;
	
	int matrix_re[0:FFT_SIZE][0:FFT_SIZE];
	int matrix_im[0:FFT_SIZE][0:FFT_SIZE];
	real dataRE, dataIM;
	
	int arr_re[0:FFT_SIZE];
	int arr_im[0:FFT_SIZE];

	string ref_model_file = "ref-model.txt";
	int rmf;
	string ref_model_file_orig = "ref-model-orig.txt";
	int rmfo;
	string matrix_file = "matrix.in";
	int mif;
	
	function new(string name = "fft2_ref_model", uvm_component parent = null);
		super.new(name, parent);
		item_collected_port = new("item_collected_port", this);
		init_tr = new("cfg_tr");
		din_tr = new("din_tr");
		dout_tr = new("dout_tr");
	endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		port_init = new("port_cfg", this);
		port_din = new("port_din", this);
		
		init_fifo = new("cfg_fifo", this);
		din_fifo = new("din_fifo", this);
    endfunction : build_phase  
	
	int i, j, k, l, mm;
	int ii, jj, kk;
	int m, m2;
	
	int topRE, topIM, bottomRE, bottomIM, twiddle;
	longint topRE_tmp, topIM_tmp;
	longint botRE, botIM;
	longint bottomRE64, bottomIM64;
	
	int height, width, log2h, log2w;
	int test_display =1;
	longint coss, sinn;

	function void print_arr();
		for(l = 0; l < height; l++) begin
			$display("ARRAY TEST. red: %0d re: %0d", l, arr_re[l]);
		end
	endfunction: print_arr

	function void print_matrix();
		for(l = 0; l < height; l++) begin
			for(mm = 0; mm < width; mm++) begin
				$display("MATRICA TEST. red: %0d kol: %0d re: %0d im: %0d", mm, l, matrix_re[l][mm], matrix_im[l][mm]);
			end
		end
	endfunction: print_matrix
	
	// vhdl math_2_pi 6.28318530717958647693
	function void butterfly(int size);
		//$display("COS: %f", $cos(-2.0*3.14159265358979*twiddle/size));
		// use $rtoi() ? 
		coss = int'($cos(-6.28318530717958647693*twiddle/size) *(2**FIXED_POINT_WIDTH));
		sinn = int'($sin(-6.28318530717958647693*twiddle/size) *(2**FIXED_POINT_WIDTH));
		// $display("twiddle: %0d size: %0d", twiddle,size);
		// $display("COS: %f %0d", $cos(-2.0*3.14159265358979*twiddle/size), coss);
		// $display("SIN: %f %0d", $sin(-2.0*3.14159265358979*twiddle/size), sinn);

		//$display("BEFOR top RE: %0d botRE: %0d", topRE, bottomRE);
		//$display("BEFOR top IM: %0d botIM: %0d", topIM, bottomIM);
		
		botRE = ((coss* longint'(bottomRE)) >> FIXED_POINT_WIDTH) - ((sinn* longint'(bottomIM)) >> FIXED_POINT_WIDTH);
		botIM = ((sinn* longint'(bottomRE)) >> FIXED_POINT_WIDTH) + ((coss* longint'(bottomIM)) >> FIXED_POINT_WIDTH);
		// $display("COSIN: %0d %0d", coss* (2**FIXED_POINT_WIDTH), coss* (2**FIXED_POINT_WIDTH)*bottomRE);
		// if (test_display == 1) begin
		// 	$display("mult1 = %0h", coss* longint'(bottomRE));
		// 	$display("mult2 = %0h", sinn* longint'(bottomIM));
		// 	$display("mult3 = %0h", sinn* longint'(bottomRE));
		// 	$display("mult4 = %0h", coss* longint'(bottomIM));
		// 	$display("sumRE = %0h", botRE);
		// 	$display("sumIM = %0h", botIM);
		// end

		//botRE = botRE >> FIXED_POINT_WIDTH;
		//botIM = botIM >> FIXED_POINT_WIDTH;
		// $display("BOTOM botRE: %0d botIM: %0d", botRE, botIM);

		topRE_tmp = topRE + botRE;
		topIM_tmp = topIM + botIM;
		bottomRE = topRE - botRE;
		bottomIM = topIM - botIM;
		
		topRE = topRE_tmp;// >> FIXED_POINT_WIDTH;
		topIM = topIM_tmp;// >> FIXED_POINT_WIDTH;
		
		// $display("AFTER top RE: %0d botRE: %0d", topRE, bottomRE);
		// $display("AFTER top IM: %0d botIM: %0d", topIM, bottomIM);
		
		//bottomRE = bottomRE64 >> FIXED_POINT_WIDTH;
		//bottomIM = bottomIM64 >> FIXED_POINT_WIDTH;
		
	endfunction: butterfly

	function void fft(int log2s, int size);
		for (ii=0;ii<log2s;++ii) begin
			m = 1 << (ii+1);
			m2 = 1 << ii;
			for (jj = 0; jj < m2; ++jj) begin
				for (kk = jj; kk < size; kk+=m) begin
					topRE = arr_re[kk];
					topIM = arr_im[kk];
					bottomRE = arr_re[kk+m2];
					bottomIM = arr_im[kk+m2];
					twiddle = jj << (log2s-ii-1);
					// if (test_display == 1) begin
					// 	$display("[BEFOR]  topRE: %0h topIM: %0h  |  botRE: %0h botIM: %0h", topRE, topIM, bottomRE, bottomIM);
					// end
					//$display("fft twiddle: %0d", twiddle);
					//$display("top: %0d", kk);
					//$display("bot: %0d", kk+m2);
					butterfly(size);
					
					arr_re[kk] = topRE;
					arr_im[kk] = topIM;
					arr_re[kk+m2] = bottomRE;
					arr_im[kk+m2] = bottomIM;
					// if (test_display == 1) begin
					// 	$display("[AFTER]  topRE: %0h topIM: %0h  |  botRE: %0h botIM: %0h\n", topRE, topIM, bottomRE, bottomIM);
					// end
				end
			end
		end
	endfunction: fft
				
	task run();
		forever begin
			// for (int iter=0;iter<8;++iter) begin
			// 	$display("coss[%0d,16]: %0h", iter, int'($cos(-6.28318530717958647693*iter/16) *(2**FIXED_POINT_WIDTH)));
			// end
			// for (int iter=0;iter<8;++iter) begin
			// 	$display("sinn[%0d,16]: %0h", iter, int'($sin(-6.28318530717958647693*iter/16) *(2**FIXED_POINT_WIDTH)));
			// end

			init_fifo.get(init_tr);
			init_tr.width += 1;
			init_tr.height += 1;
			init_tr.log2h += 1;
			init_tr.log2w += 1;
			
			width = init_tr.width;
			height = init_tr.height;
			log2h = init_tr.log2h;
			log2w = init_tr.log2w;
			
			// $display("REF_MODEL: %0d %0d %0d %0d", init_tr.width, init_tr.height, init_tr.log2h, init_tr.log2w);
			rmf = $fopen(ref_model_file, "w");
			$fclose(rmf); 
			rmf = $fopen(ref_model_file_orig, "w");
			$fclose(rmfo); 
			mif = $fopen(matrix_file, "w");
			$fclose(mif);
			
			repeat(width*height) begin
				din_fifo.get(din_tr);
				matrix_re[i][j] = din_tr.dataRE_i;
				matrix_im[i][j] = din_tr.dataIM_i;
				j = j + 1;
				if (j == width) begin
					j = 0;
					i = i+1;
				end
			end
		
			rmfo = $fopen(ref_model_file_orig, "a");
			$fwrite(rmfo,"----------------0----------------\n");
			$fclose(rmfo);
			rmf = $fopen(ref_model_file, "a");
			$fwrite(rmf,"----------------0----------------\n");
			$fclose(rmf);
			//$display("\n----------------0----------------");

			for(i = 0; i < height; i++) begin
				for(j = 0; j < width; j++) begin
					int reversed =0;
					int temp = j;
					int kkk;

					$cast(dataRE, matrix_re[i][j]);
        			$cast(dataIM, matrix_im[i][j]);
					// $display("MATRICA 0. [%0d,%0d] re: %0f im: %0f", i,j, dataRE/65536.0, dataIM/65536.0);
					rmfo = $fopen(ref_model_file_orig, "a"); 
					$fwrite(rmfo, "MATRICA 0. [%0d,%0d] re: %0h im: %0h \n", i,j, matrix_re[i][j], matrix_im[i][j]);
					$fclose(rmfo);
					rmf = $fopen(ref_model_file, "a"); 
					$fwrite(rmf, "MATRICA 0. [%0d,%0d] re: %0f im: %0f \n", i,j, dataRE/65536.0, dataIM/65536.0);
					$fclose(rmf);

					// int k;
					for (kkk=0;kkk<log2w;++kkk) begin
						reversed=reversed << 1;
						reversed = reversed | (temp & 1);
						temp = temp >> 1;
					end
					$cast(dataRE, matrix_re[i][reversed]);
					mif = $fopen(matrix_file, "a"); 
					$fwrite(mif, "%0f ", dataRE/65536.0);
					$fclose(mif);
				end
				mif = $fopen(matrix_file, "a"); 
				$fwrite(mif, "\n");
				$fclose(mif);
			end
			
			for(i = 0; i < height; i++) begin
				//print_arr();
				for(j = 0; j < width; j++) begin
					int reversed = j;
					// int reversed =0;
					// int temp = j;
					// for(k = 0; k < log2w; ++k) begin
					// 	reversed=reversed << 1;
					// 	reversed = reversed | (temp & 1);
					// 	temp = temp >> 1;
					// end
					arr_re[j] = matrix_re[i][reversed];
					arr_im[j] = matrix_im[i][reversed];
					//$display("Reversed: %0d", reversed);
				end
				//print_arr();
				fft(log2w, width);
				test_display = 0;
				for (j=0;j<width;j++) begin
					matrix_re[i][j] = arr_re[j];
					matrix_im[i][j] = arr_im[j];
				end
			end

			rmfo = $fopen(ref_model_file_orig, "a");
			$fwrite(rmfo,"----------------1----------------\n");
			$fclose(rmfo);
			rmf = $fopen(ref_model_file, "a");
			$fwrite(rmf,"----------------1----------------\n");
			$fclose(rmf);
			//$display("\n----------------1----------------");

			for(i = 0; i < height; i++) begin
				for(j = 0; j < width; j++) begin
					$cast(dataRE, matrix_re[i][j]);
        			$cast(dataIM, matrix_im[i][j]);
					//$display("MATRICA 1. [%0d,%0d] re: %0f im: %0f", i,j, dataRE/65536.0, dataIM/65536.0);
					rmfo = $fopen(ref_model_file_orig, "a"); 
					$fwrite(rmfo, "MATRICA 1. [%0d,%0d] re: %0h im: %0h \n", i,j, matrix_re[i][j], matrix_im[i][j]);
					$fclose(rmfo);
					rmf = $fopen(ref_model_file, "a"); 
					$fwrite(rmf, "MATRICA 1. [%0d,%0d] re: %0f im: %0f \n", i,j, dataRE/65536.0, dataIM/65536.0);
					$fclose(rmf);
				end
			end
			for(i = 0; i < height; i++) begin
				for(j = 0; j < width; j++) begin
					dout_tr = fft2_dout_din_transaction::type_id::create("dout_tr");
					dout_tr.dataRE_o = matrix_re[i][j];
					dout_tr.dataIM_o = matrix_im[i][j];
					item_collected_port.write(dout_tr);
				end
			end

			for(j = 0; j < width; j++) begin
				for(i = 0; i < height; i++) begin
					// int reversed = i;
					int reversed =0;
					int temp = i;
					for(k = 0; k < log2h; ++k) begin
						reversed=reversed << 1;
						reversed = reversed | (temp & 1);
						temp = temp >> 1;
					end
					arr_re[i] = matrix_re[reversed][j];
					arr_im[i] = matrix_im[reversed][j];
					//$display("Reversed2: %0d", reversed);
				end
				fft(log2h, height);
				for (i=0;i<height;i++) begin
					matrix_re[i][j] = arr_re[i];
					matrix_im[i][j] = arr_im[i];
				end
			end


			rmfo = $fopen(ref_model_file_orig, "a");
			$fwrite(rmfo,"----------------2----------------\n");
			$fclose(rmfo);
			rmf = $fopen(ref_model_file, "a");
			$fwrite(rmf,"----------------2----------------\n");
			$fclose(rmf);
			//$display("\n----------------2----------------");
			

			
			for(j = 0; j < width; j++) begin
				for(i = 0; i < height; i++) begin
					$cast(dataRE, matrix_re[i][j]);
        			$cast(dataIM, matrix_im[i][j]);
					//$display("MATRICA 2. [%0d,%0d] re: %0f im: %0f", i,j, dataRE/65536.0, dataIM/65536.0);
					rmfo = $fopen(ref_model_file_orig, "a"); 
					$fwrite(rmfo, "MATRICA 2. [%0d,%0d] re: %0h im: %0h \n", i,j, matrix_re[i][j], matrix_im[i][j]);
					$fclose(rmfo);
					rmf = $fopen(ref_model_file, "a"); 
					$fwrite(rmf, "MATRICA 2. [%0d,%0d] re: %0f im: %0f \n", i,j, dataRE/65536.0, dataIM/65536.0);
					$fclose(rmf);
				end
			end
			
			for(i = 0; i < width; i++) begin
				for(j = 0; j < height; j++) begin
					dout_tr = fft2_dout_din_transaction::type_id::create("dout_tr");
					dout_tr.dataRE_o = matrix_re[j][i];
					dout_tr.dataIM_o = matrix_im[j][i];
					item_collected_port.write(dout_tr);
				end
			end
		end
	endtask: run
	
	function void write_init(fft2_init_transaction seq_item);
		init_fifo.write(seq_item);
	endfunction: write_init
	
	function void write_din(fft2_dout_din_transaction seq_item);
		din_fifo.write(seq_item);
	endfunction: write_din
	
	
endclass : fft2_ref_model


`endif

