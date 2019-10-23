/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_if.sv

    DESCRIPTION     fft2 interface

 ****************************************************************************/

`ifndef FFT2_IF_SV
`define FFT2_IF_SV

/**
 * Interface: fft2_if
 */
interface fft2_if (input logic pclk, input logic presetn);

    parameter DATA_WIDTH   = 32;    // up to 32 bits
    parameter FFT_SIZE  = 16;    // up to 32 bits
    parameter FIXED_POINT_WIDTH  = 16;    // up to 32 bits

    logic [$clog2(FFT_SIZE*FFT_SIZE) - 1 : 0] data_i_addr_o;
    logic [DATA_WIDTH - 1 : 0] dataRE_i;
    logic [DATA_WIDTH - 1 : 0] dataIM_i;
    logic data_rd_o;
    logic data_rd_i;

    logic [$clog2(FFT_SIZE*FFT_SIZE) - 1 : 0] data_o_addr_o;
    logic [DATA_WIDTH - 1 : 0] dataRE_o;
    logic [DATA_WIDTH - 1 : 0] dataIM_o;
    logic data_wr_o;
    logic data_wr_i;
    
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

endinterface : fft2_if

`endif
