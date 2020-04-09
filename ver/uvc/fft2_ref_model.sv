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
	
	int arr_re[0:FFT_SIZE];
	int arr_im[0:FFT_SIZE];
	
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
	
	int i, j, k;
	int ii, jj, kk;
	int m, m2;
	
	int topRE, topIM, bottomRE, bottomIM, twiddle;
	longint topRE_tmp, topIM_tmp;
	longint botRE, botIM;
	longint bottomRE64, bottomIM64;
	
	int height, width, log2h, log2w;
	int coss, sinn;
	
	function void butterfly(int size);
		//$display("COS: %f", $cos(-2.0*3.14159265358979*twiddle/size));
		coss = int'($cos(-2.0*3.14159265358979*twiddle/size));
		sinn = int'($sin(-2.0*3.14159265358979*twiddle/size));
		//$display("COS: %f %d", $cos(-2.0*3.14159265358979*twiddle/size), coss);
		//$display("SIN: %f %d", $sin(-2.0*3.14159265358979*twiddle/size), sinn);
		
		botRE = coss* (2**FIXED_POINT_WIDTH)* longint'(bottomRE) - sinn*(2**FIXED_POINT_WIDTH)* longint'(bottomIM);
		botIM = sinn* (2**FIXED_POINT_WIDTH)* longint'(bottomRE) + coss*(2**FIXED_POINT_WIDTH)* longint'(bottomIM);
		//$display("PRVI DEO: %d %d", coss* (2**FIXED_POINT_WIDTH), coss* (2**FIXED_POINT_WIDTH)*bottomRE);
		//$display("bottom RE: %d botton IM: %d", bottomRE, bottomIM);
		botRE = botRE >> FIXED_POINT_WIDTH;
		botIM = botIM >> FIXED_POINT_WIDTH;
		topRE_tmp = topRE + botRE;
		topIM_tmp = topIM + botIM;
		bottomRE = topRE - botRE;
		bottomIM = topIM - botIM;
		
		topRE = topRE_tmp;// >> FIXED_POINT_WIDTH;
		topIM = topIM_tmp;// >> FIXED_POINT_WIDTH;
		
		$display("top RE: %d botRE: %d", topRE, bottomRE);
		
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
					//$display("top: %d", kk);
					//$display("bot: %d", kk+m2);
					butterfly(size);
					
					arr_re[kk] = topRE;
					arr_im[kk] = topIM;
					arr_re[kk+m2] = bottomRE;
					arr_im[kk+m2] = bottomIM;
				end
			end
		end
	endfunction: fft
				
	task run();
		forever begin
			init_fifo.get(init_tr);
			init_tr.width += 1;
			init_tr.height += 1;
			init_tr.log2h += 1;
			init_tr.log2w += 1;
			
			width = init_tr.width;
			height = init_tr.height;
			log2h = init_tr.log2h;
			log2w = init_tr.log2w;
			
			$display("REF_MODEL: %d %d %d %d", init_tr.width, init_tr.height, init_tr.log2h, init_tr.log2w);
			
			repeat(width*height) begin
				$display("REF_MODEL: break1");
				din_fifo.get(din_tr);
				$display("DIN: %d %d", din_tr.dataRE_i, din_tr.dataIM_i);
				matrix_re[i][j] = din_tr.dataRE_i;
				matrix_im[i][j] = din_tr.dataIM_i;
				j = j + 1;
				if (j == width) begin
					j = 0;
					i = i+1;
				end
			end
			
			$display("REF_MODEL: break2");

			for(i = 0; i < height; i++) begin
				for(j = 0; j < width; j++) begin
					$display("MATRICA 0. red: %d kol: %d re: %d im: %d", j, i, matrix_re[i][j], matrix_im[i][j]);
				end
			end
			
			for(i = 0; i < height; i++) begin
				for(j = 0; j < width; j++) begin
					int reversed =0;
					int temp = j;
					for(k = 0; k < log2w-1; ++k) begin
						reversed=reversed << 1;
						reversed = reversed | (temp & 1);
						
						temp = temp >> 1;
					end
					arr_re[j] = matrix_re[i][reversed];
					arr_im[j] = matrix_im[i][reversed];
					//$display("Reversed: %d", reversed);
				end
				fft(log2w, width);
				for (j=0;j<width;j++) begin
					matrix_re[i][j] = arr_re[j];
					matrix_im[i][j] = arr_im[j];
				end
			end
			
			for(i = 0; i < height; i++) begin
				for(j = 0; j < width; j++) begin
					$display("MATRICA 1. red: %d kol: %d re: %d im: %d", j, i, matrix_re[i][j], matrix_im[i][j]);
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
					int reversed =0;
					int temp = i;
					for(k = 0; k < log2h-1; ++k) begin
						reversed=reversed << 1;
						reversed = reversed | (temp & 1);
						temp = temp >> 1;
					end
					arr_re[i] = matrix_re[reversed][j];
					arr_im[i] = matrix_im[reversed][j];
					//$display("Reversed2: %d", reversed);
				end
				fft(log2h, height);
				for (i=0;i<height;i++) begin
					matrix_re[i][j] = arr_re[i];
					matrix_im[i][j] = arr_im[i];
				end
			end
			
			for(i = 0; i < height; i++) begin
				for(j = 0; j < width; j++) begin
					$display("MATRICA 2. red: %d kol: %d re: %d im: %d", j, i, matrix_re[i][j], matrix_im[i][j]);
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

