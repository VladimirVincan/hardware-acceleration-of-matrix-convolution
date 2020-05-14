/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_test_base.sv

    DESCRIPTION     base test to be extended by other tests

 ****************************************************************************/

`ifndef FFT2_TEST_BASE_SV
`define FFT2_TEST_BASE_SV

/**
 * Class: fft2_test_base
 */
 `include "../uvc/fft2_pkg.sv"
 import fft2_pkg::*;
 import uvm_pkg::*;
 `include "uvm_macros.svh"

 
class fft2_test_base extends uvm_test;

    // UVM factory registration
    `uvm_component_utils (fft2_test_base)

    // main environment
    fft2_env env;

    // new - constructor
    function new(string name = "fft2_test_base", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    // UVM build_phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // build environment
        env = fft2_env::type_id::create("env", this);
    endfunction : build_phase

    // UVM end_of_elaboration_phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // display verification environment topology
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

endclass : fft2_test_base

`endif
