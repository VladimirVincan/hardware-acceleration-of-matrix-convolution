`ifndef FFT2_INIT_DRIVER_SV
`define FFT2_INIT_DRIVER_SV

class fft2_init_driver extends uvm_driver #(fft2_init_transaction, fft2_init_transaction);
    
    virtual fft2_init_if#(.FFT_SIZE(FFT_SIZE)) init_vif;
    fft2_config cfg;
    
    `uvm_component_utils_begin(fft2_init_driver)
        `uvm_field_object(cfg, UVM_DEFAULT | UVM_REFERENCE)
    `uvm_component_utils_end       

	function new(string name = "fft2_init_driver", uvm_component parent = null);
		super.new(name, parent);
	endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fft2_config)::get(this, "*", "fft2_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})
    endfunction: build_phase
 
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(!uvm_config_db#(virtual fft2_init_if#(.FFT_SIZE(FFT_SIZE)))::get(this, "", "fft2_init_if", init_vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".init_vif"})    
    endfunction : connect_phase

    extern virtual task run_phase(uvm_phase phase);
    extern virtual task get_and_drive();
    extern virtual task reset();
    extern virtual task drive_tr (fft2_init_transaction tr);
    
endclass : fft2_init_driver

task fft2_init_driver::run_phase(uvm_phase phase);
    reset();
    forever begin
        fork
            get_and_drive();
            @(negedge init_vif.rst);
        join_any
        disable fork;
        reset();
    end
endtask : run_phase

task fft2_init_driver::reset();
    `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
	
    init_vif.log2w    <= {$clog2($clog2(FFT_SIZE)){1'b0}};
    init_vif.width    <= {$clog2(FFT_SIZE) {1'b0}};
    init_vif.log2h   <= {$clog2($clog2(FFT_SIZE)){1'b0}};
    init_vif.height    <= {$clog2(FFT_SIZE) {1'b0}};
	init_vif.start <= 1'b0;

    @(negedge init_vif.rst);
endtask : reset

task fft2_init_driver::get_and_drive();
    forever begin
        seq_item_port.get_next_item(req);
        drive_tr(req);
		$display("INIT_DRIVER: ovde");
        seq_item_port.item_done();
        $display("INIT_DRIVER: izasao");
    end
endtask : get_and_drive

task fft2_init_driver::drive_tr (fft2_init_transaction tr);
    $display("INIT_DRIVER: break1");
	init_vif.log2h    <= tr.log2h;
	init_vif.log2w    <= tr.log2w;
	init_vif.width    <= tr.width;
	init_vif.height    <= tr.height;
	
    $display("INIT_DRIVER: break2");
    init_vif.start <= 1'b0;
	@(posedge init_vif.clk iff init_vif.ready);
	init_vif.start <= 1'b1;
    $display("INIT_DRIVER: break3");
	@(posedge init_vif.clk iff init_vif.ready == 1'b0);
	init_vif.start <= 1'b0;
    `uvm_info(get_type_name(), $sformatf("FFT2 Finished Driving tr \n%s", tr.sprint()), UVM_HIGH)
    $display("INIT_DRIVER: break4");
endtask : drive_tr

`endif

