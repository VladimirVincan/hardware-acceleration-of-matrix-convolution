/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_init_if.sv

    DESCRIPTION     fft2 interface

 ****************************************************************************/

`ifndef FFT2_INIT_IF_SV
`define FFT2_INIT_IF_SV

/**
 * Interface: fft2_init_if
 */
interface fft2_init_if (input logic clk, input logic rst);

    parameter FFT_SIZE  = 16;    // up to 32 bits
    
    logic [$clog2($clog2(FFT_SIZE)) - 1 : 0] log2w;
    logic [$clog2(FFT_SIZE) - 1 : 0] width;
    
    logic [$clog2($clog2(FFT_SIZE)) - 1 : 0] log2h;
    logic [$clog2(FFT_SIZE) - 1 : 0] height;
    
    logic start;
    logic ready;
    
    // control
    bit has_checks = 1;
    bit has_coverage = 1;
    
    // TODO : coverage and assertions go here...

endinterface : fft2_init_if

`endif
