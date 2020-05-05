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
    parameter FFT_SIZE  = 64;    // up to 32 bits
    parameter FIXED_POINT_WIDTH  = 16;    // up to 32 bits
    
    // ==================== OBJECTS ==============================
    typedef class fft2_dout_din_transaction;
	typedef class fft2_init_transaction;
    typedef class fft2_dout_config;
    typedef class fft2_din_config;
    typedef class fft2_init_config;
    typedef class fft2_config;
    // ==========================================================

    // ==================== DIN ===============================
    typedef class fft2_din_driver;
    typedef class fft2_din_sequencer;
    typedef class fft2_din_monitor;
    typedef class fft2_din_agent;
    // ==========================================================
	
    // ==================== DOUT ==============================
    typedef class fft2_dout_driver;
    typedef class fft2_dout_sequencer;
    typedef class fft2_dout_monitor;
    typedef class fft2_dout_agent;
    // ==========================================================

	// ==================== INIT ==============================
    typedef class fft2_init_driver;
    typedef class fft2_init_sequencer;
    typedef class fft2_init_monitor;
    typedef class fft2_init_agent;
    // ==========================================================

    // ==================== TOP ==================================
	typedef class fft2_scoreboard;
	typedef class fft2_ref_model;
    typedef class fft2_env;
    // ==========================================================

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "fft2_config.sv"

    // ==================== DIN ==============================
    `include "din/sequences/fft2_din_seq_lib.sv"
    `include "din/fft2_din_config.sv"
    `include "din/fft2_din_driver.sv"
    `include "din/fft2_din_monitor.sv"
    `include "din/fft2_din_sequencer.sv"
    `include "din/fft2_din_agent.sv"
    // ==========================================================

    // ==================== DOUT ===============================
    `include "dout/sequences/fft2_dout_seq_lib.sv"
    `include "dout/fft2_dout_config.sv"
    `include "dout/fft2_dout_driver.sv"
    `include "dout/fft2_dout_monitor.sv"
    `include "dout/fft2_dout_sequencer.sv"
    `include "dout/fft2_dout_agent.sv"
    // ==========================================================

	// ==================== INIT ===============================
    `include "init/sequences/fft2_init_seq_lib.sv"
    `include "init/fft2_init_config.sv"
    `include "init/fft2_init_driver.sv"
    `include "init/fft2_init_monitor.sv"
    `include "init/fft2_init_sequencer.sv"
    `include "init/fft2_init_agent.sv"
    // ==========================================================
	
    // ==================== TOP =================================
    `include "fft2_env.sv"
	`include "fft2_scoreboard.sv"
	`include "fft2_ref_model.sv"
    `include "fft2_dout_din_transaction.sv"
	`include "fft2_init_transaction.sv"
    // ==========================================================

endpackage : fft2_pkg

`include "fft2_din_if.sv"
`include "fft2_dout_if.sv"
`include "fft2_init_if.sv"

`endif
