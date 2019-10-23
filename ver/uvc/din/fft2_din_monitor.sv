`ifndef FFT2_DIN_MONITOR_SV
`define FFT2_DIN_MONITOR_SV

class fft2_din_monitor extends uvm_monitor;

    virtual fft2_din_if#(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)) din_vif;

    fft2_config cfg;

    uvm_analysis_port #(fft2_dout_din_transaction) item_collected_port;

    int unsigned num_transactions = 0;

    fft2_dout_din_transaction tr_collected;

    `uvm_component_utils_begin(fft2_din_monitor)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end
	/*
    covergroup cg_fft2_din;
		option.per_instance = 1;
        cp_data : coverpoint tr_collected.data{
			bins zero = {0};
			bins other = default;
		}
        cp_delay : coverpoint tr_collected.delay {
            bins lt_10 = {[0:10]};
            bins other = default;
        }
    endgroup : cg_fft2_din;
	*/
	function new(string name = "fft2_din_monitor", uvm_component parent = null);
		super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
        //cg_fft2_din = new();
	endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual fft2_din_if #(.FFT_SIZE(FFT_SIZE), .DATA_WIDTH(DATA_WIDTH)))::get(this, "", "fft2_din_if", din_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".din_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task collect_transactions();
    extern virtual function void report_phase(uvm_phase phase);

endclass : fft2_din_monitor

task fft2_din_monitor::run_phase(uvm_phase phase);
    forever begin
        @(negedge din_vif.rst);
        `uvm_info(get_type_name(), "Reset dropped", UVM_HIGH)
        fork
            collect_transactions();
            @(posedge din_vif.rst);
        join_any
        disable fork;
    end
endtask : run_phase

task fft2_din_monitor::collect_transactions();
    forever begin
        tr_collected = fft2_dout_din_transaction::type_id::create("tr_collected");
		while(!((din_vif.data_rd_o == 1'b1) && (din_vif.data_rd_i == 1'b1))) begin
			@(posedge din_vif.clk);
		end
		tr_collected.data_i_addr_o = din_vif.data_i_addr_o;
		tr_collected.dataRE_i = din_vif.dataRE_i;
		tr_collected.dataIM_i = din_vif.dataIM_i;
        item_collected_port.write(tr_collected);
        if(cfg.has_coverage == 1) begin
            //cg_fft2_din.sample();
        end
        `uvm_info(get_type_name(), $sformatf("Tr collected :\n%s", tr_collected.sprint()), UVM_HIGH)
        num_transactions++;
		@(posedge din_vif.clk);
    end
endtask : collect_transactions

function void fft2_din_monitor::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: FFT2 monitor collected %0d transfers", num_transactions), UVM_LOW);
endfunction : report_phase


`endif

