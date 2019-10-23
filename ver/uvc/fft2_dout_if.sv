/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_dout_if.sv

    DESCRIPTION     fft2 interface

 ****************************************************************************/

`ifndef FFT2_DOUT_IF_SV
`define FFT2_DOUT_IF_SV

/**
 * Interface: fft2_dout_if
 */
interface fft2_dout_if (input logic clk, input logic rst);

    parameter DATA_WIDTH   = 32;    // up to 32 bits
    parameter FFT_SIZE  = 16;    // up to 32 bits

    logic [$clog2(FFT_SIZE*FFT_SIZE) - 1 : 0] data_o_addr_o;
    logic [DATA_WIDTH - 1 : 0] dataRE_o;
    logic [DATA_WIDTH - 1 : 0] dataIM_o;
    logic data_wr_o;
    logic data_wr_i;
    
    // control
    bit has_checks = 1;
    bit has_coverage = 1;
    
    // TODO : coverage and assertions go here...

endinterface : fft2_dout_if

`endif
