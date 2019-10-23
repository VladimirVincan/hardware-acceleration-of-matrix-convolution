`ifndef CANNY_DIN_SIMPLE_SEQ_SV
`define CANNY_DIN_SIMPLE_SEQ_SV

class canny_din_simple_seq extends canny_din_base_seq;
    int br = 0;
    rand int unsigned layer_num;
    rand int unsigned x_size, y_size;
	int cnt;
	longint value;
	int fd;
	string file_name;
	string num;
	int image = 0;
	
    `uvm_object_utils(canny_din_simple_seq)

	function new(string name = "canny_din_simple_seq");
		super.new(name);
	endfunction : new

    virtual task body();
		int i;
		int delitelj = 1;
        for(i = 0; i <= layer_num; i++) begin
			br = 0;
			if(i == 0) begin
				delitelj = 2;
			end else begin
				delitelj = 1;
			end;
			
			num.itoa(i-1+image); 
			file_name = {"layer_", num, ".txt"};
			if(i > 0) begin
				fd = $fopen(file_name, "r");  
				if(fd) begin
					//$display("File simple seq was opened successfully");
				end	else begin
					$display("File simple seq was NOT opened successfully");
				end
			end
			
			repeat((x_size*y_size/delitelj)-1) begin
				if(i == 0) begin
					//`uvm_do_with(req, {req.last == 1'b0; req.data == br;})
					`uvm_do_with(req, {req.last == 1'b0; req.data[2*W_DATA-1:W_DATA] == 16'h0; req.data[4*W_DATA-1:3*W_DATA] == 16'h0;})
				end else begin		
					$fscanf(fd, "%d. %d", cnt, value);
					while(cnt != br) begin
						$fscanf(fd, "%d. %d", cnt, value);
					end
					
					`uvm_do_with(req, {req.last == 1'b0; req.data == value;})
				end
				br++;
			end
			
			if(i == 0) begin
				`uvm_do_with(req, {req.last == 1'b1; req.data[2*W_DATA-1:W_DATA] == 16'h0; req.data[4*W_DATA-1:3*W_DATA] == 16'h0;})
			end else begin		
				$fscanf(fd, "%d. %d", cnt, value);
				while(cnt != br) begin
					$fscanf(fd, "%d. %d", cnt, value);
				end
				$fclose(fd);
				`uvm_do_with(req, {req.last == 1'b1; req.data == value;})
			end

			$fclose(fd);
		end
    endtask : body
    
endclass : canny_din_simple_seq

`endif
