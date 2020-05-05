`ifndef FFT2_INIT_MONITOR_SV
`define FFT2_INIT_MONITOR_SV

class fft2_init_monitor extends uvm_monitor;

    virtual fft2_init_if#(.FFT_SIZE(FFT_SIZE)) init_vif;

    fft2_config cfg;

    uvm_analysis_port #(fft2_init_transaction) item_collected_port;

    int unsigned num_transactions = 0;

    fft2_init_transaction tr_collected;

    `uvm_component_utils_begin(fft2_init_monitor)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end
	
    covergroup cg_fft2_init;
		option.per_instance = 1;

        cp_log2w : coverpoint tr_collected.log2w {
            bins range[5] = {[1:5]};
            // bins ignored = default;
        }
        cp_log2h : coverpoint tr_collected.log2h{
            bins range[5] = {[1:5]};
            // bins ignored = default;
        }
        cx_log : cross cp_log2h, cp_log2w;

    endgroup : cg_fft2_init;
	
	function new(string name = "fft2_init_monitor", uvm_component parent = null);
		super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
        cg_fft2_init = new();
	endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fft2_config)::get(this, "", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual fft2_init_if #(.FFT_SIZE(FFT_SIZE)))::get(this, "", "fft2_init_if", init_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".init_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task collect_transactions();
    extern virtual function void report_phase(uvm_phase phase);

endclass : fft2_init_monitor

task fft2_init_monitor::run_phase(uvm_phase phase);
    forever begin
        @(negedge init_vif.rst);
        `uvm_info(get_type_name(), "Reset dropped", UVM_HIGH)
        fork
            collect_transactions();
            @(posedge init_vif.rst);
        join_any
        disable fork;
    end
endtask : run_phase

task fft2_init_monitor::collect_transactions();
    forever begin
        tr_collected = fft2_init_transaction::type_id::create("tr_collected");
		while(!((init_vif.start == 1'b1) && (init_vif.ready == 1'b1))) begin
			@(posedge init_vif.clk);
		end
		tr_collected.width = init_vif.width;
		tr_collected.height = init_vif.height;
		tr_collected.log2h = init_vif.log2h;
		tr_collected.log2w = init_vif.log2w;
        item_collected_port.write(tr_collected);
        if(cfg.has_coverage == 1) begin
            cg_fft2_init.sample();
        end
        `uvm_info(get_type_name(), $sformatf("Tr collected :\n%s", tr_collected.sprint()), UVM_HIGH)
        num_transactions++;
		@(posedge init_vif.clk);
    end
endtask : collect_transactions

function void fft2_init_monitor::report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Report: FFT2 monitor collected %0d transfers", num_transactions), UVM_LOW);
endfunction : report_phase


`endif

