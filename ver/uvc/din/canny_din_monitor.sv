`ifndef CANNY_DIN_MONITOR_SV
`define CANNY_DIN_MONITOR_SV

class canny_din_monitor extends uvm_monitor;

    virtual canny_stream_if#(.DATA_WIDTH(4*W_DATA)) din_vif;

    canny_config cfg;

    uvm_analysis_port #(canny_stream_data_seq_item) item_collected_port;

    int unsigned num_transactions = 0;

    canny_stream_data_seq_item tr_collected;

    `uvm_component_utils_begin(canny_din_monitor)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end

    covergroup cg_canny_din;
		option.per_instance = 1;
        cp_data : coverpoint tr_collected.data{
			bins zero = {0};
			bins other = default;
		}
        cp_delay : coverpoint tr_collected.delay {
            bins lt_10 = {[0:10]};
            bins other = default;
        }
    endgroup : cg_canny_din;

	function new(string name = "canny_din_monitor", uvm_component parent = null);
		super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
        cg_canny_din = new();
	endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(canny_config)::get(this, "", "canny_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual canny_stream_if #(.DATA_WIDTH(4*W_DATA)))::get(this, "", "canny_din_if", din_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".din_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task collect_transactions();
    extern virtual function void report_phase(uvm_phase phase);

endclass : canny_din_monitor

task canny_din_monitor::run_phase(uvm_phase phase);
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

task canny_din_monitor::collect_transactions();
    forever begin
        tr_collected = canny_stream_data_seq_item::type_id::create("tr_collected");
		tr_collected.delay = 0;
		while(!((din_vif.tvalid == 1) && (din_vif.tready == 1))) begin
			@(posedge din_vif.clk);
			tr_collected.delay++;
		end
		tr_collected.data = din_vif.tdata;
        item_collected_port.write(tr_collected);
        if(cfg.has_coverage == 1) begin
            cg_canny_din.sample();
        end
        `uvm_info(get_type_name(), $sformatf("Tr collected :\n%s", tr_collected.sprint()), UVM_HIGH)
        num_transactions++;
		@(posedge din_vif.clk);
    end
endtask : collect_transactions

function void canny_din_monitor::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: CANNY monitor collected %0d transfers", num_transactions), UVM_LOW);
endfunction : report_phase


`endif

