`ifndef FFT2_DOUT_MONITOR_SV
`define FFT2_DOUT_MONITOR_SV

class fft2_dout_monitor extends uvm_monitor;

    virtual fft2_dout_if#(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)) dout_vif;

    fft2_config cfg;
	int last_addr;
    real dataRE, dataIM;
    int intRE, intIM;

    uvm_analysis_port #(fft2_dout_din_transaction) item_collected_port;

    int unsigned num_transactions = 0;
	
    fft2_dout_din_transaction tr_collected;

    `uvm_component_utils_begin(fft2_dout_monitor)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end

    covergroup cg_fft2_dout;
		option.per_instance = 1;

        // cp_outaddr  : coverpoint tr_collected.data_o_addr_o;
        cp_dataRE_o : coverpoint tr_collected.dataRE_o;
        cp_dataIM_o : coverpoint tr_collected.dataIM_o;

    endgroup : cg_fft2_dout;

	function new(string name = "fft2_dout_monitor", uvm_component parent = null);
		super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
        cg_fft2_dout = new();
	endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual fft2_dout_if  #(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)))::get(this, "", "fft2_dout_if", dout_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".dout_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task collect_transactions();
    extern virtual function void report_phase(uvm_phase phase);

endclass : fft2_dout_monitor

task fft2_dout_monitor::run_phase(uvm_phase phase);
    forever begin
        @(negedge dout_vif.rst);
        `uvm_info(get_type_name(), "Reset dropped", UVM_HIGH)
        fork
            collect_transactions();
            @(posedge dout_vif.rst);
        join_any
        disable fork;
    end
endtask : run_phase

string dm_file, dmo_file;
int dm, dmo;

task fft2_dout_monitor::collect_transactions();
	dm_file = "dout-monitor.txt";
    dmo_file = "dout-monitor-orig.txt";
	dm = $fopen(dm_file, "w");
    dmo = $fopen(dmo_file, "w");
	$fclose(dm);  
    $fclose(dmo);
	last_addr = -1;
	forever begin

        tr_collected = fft2_dout_din_transaction::type_id::create("tr_collected");
		while(!((dout_vif.data_wr_o == 1'b1) && (dout_vif.data_wr_i == 1'b1))) begin
			@(posedge dout_vif.clk);
		end
		tr_collected.data_o_addr_o = dout_vif.data_o_addr_o;
		tr_collected.dataRE_o = dout_vif.dataRE_o;
		tr_collected.dataIM_o = dout_vif.dataIM_o;

        dm = $fopen(dm_file, "a");  
        dmo = $fopen(dmo_file, "a");  
		if(dmo) begin
			//$display("File dout was opened successfully");
		end	else begin
			$display("File dout was not opened successfully");
		end

        intRE = tr_collected.dataRE_o;
        intIM = tr_collected.dataIM_o;
        $cast(dataRE, intRE);
        $cast(dataIM, intIM);

		if(last_addr != tr_collected.data_o_addr_o) begin
            $fwrite(dm, "%d, %0f, %0f \n", tr_collected.data_o_addr_o, dataRE/real'(65536), dataIM/real'(65536));
			$fwrite(dmo, "%d, %0h, %0h \n", tr_collected.data_o_addr_o, tr_collected.dataRE_o, tr_collected.dataIM_o);
			item_collected_port.write(tr_collected);
		end
		last_addr = tr_collected.data_o_addr_o;
		$fclose(dm);
        $fclose(dmo);
		
		
        if(cfg.has_coverage == 1) begin
            cg_fft2_dout.sample();
        end
        `uvm_info(get_type_name(), $sformatf("Tr collected :\n%s", tr_collected.sprint()), UVM_HIGH)
        num_transactions++;
		@(posedge dout_vif.clk);
    end
endtask : collect_transactions

function void fft2_dout_monitor::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: FFT2 monitor collected %0d transfers", num_transactions), UVM_LOW);
endfunction : report_phase


`endif

