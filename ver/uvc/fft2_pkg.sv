/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_pkg.sv

    DESCRIPTION     package containing all parameters and includes

 ****************************************************************************/

`ifndef FFT2_PKG_SV
`define FFT2_PKG_SV

/**
 * Package: fft2_pkg
 */
package fft2_pkg;
    
    parameter DATA_WIDTH   = 32;    // up to 32 bits
    parameter FFT_SIZE  = 16;    // up to 32 bits
    parameter FIXED_POINT_WIDTH  = 16;    // up to 32 bits
    
    // ==================== OBJECTS ==============================
    typedef class fft2_transaction;
    typedef class fft2_dout_config;
    typedef class fft2_din_config;
    typedef class fft2_init_config;
    typedef class fft2_config;
    // ==========================================================

    // ==================== SLAVE ===============================
    typedef class fft2_slave_driver;
    typedef class fft2_slave_sequencer;
    typedef class fft2_slave_monitor;
    typedef class fft2_slave_agent;
    // ==========================================================

    // ==================== MASTER ==============================
    typedef class fft2_master_driver;
    typedef class fft2_master_sequencer;
    typedef class fft2_master_monitor;
    typedef class fft2_master_agent;
    // ==========================================================

    // ==================== TOP ==================================
    typedef class fft2_env;
    // ==========================================================

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "fft2_types.sv"
    `include "fft2_config.sv"

    // ==================== MASTER ==============================
    `include "master/sequences/fft2_master_seq_lib.sv"
    `include "master/fft2_master_config.sv"
    `include "master/fft2_master_driver.sv"
    `include "master/fft2_master_monitor.sv"
    `include "master/fft2_master_sequencer.sv"
    `include "master/fft2_master_agent.sv"
    // ==========================================================

    // ==================== SLAVE ===============================
    `include "slave/sequences/fft2_slave_seq_lib.sv"
    `include "slave/fft2_slave_config.sv"
    `include "slave/fft2_slave_driver.sv"
    `include "slave/fft2_slave_monitor.sv"
    `include "slave/fft2_slave_sequencer.sv"
    `include "slave/fft2_slave_agent.sv"
    // ==========================================================

    // ==================== TOP =================================
    `include "fft2_env.sv"
    `include "fft2_transaction.sv"
    // ==========================================================

endpackage : fft2_pkg

`include "fft2_if.sv"

`endif
