/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_init_transaction.sv

    DESCRIPTION     sequence item

 ****************************************************************************/

`ifndef FFT2_INIT_TRANSACTION_SV
`define FFT2_INIT_TRANSACTION_SV

/**
 * Class: fft2_init_transaction
 */
class fft2_init_transaction extends uvm_sequence_item;
    
    // fields
    rand logic [$clog2($clog2(FFT_SIZE)) - 1 : 0] log2w;
    rand logic [$clog2(FFT_SIZE) - 1 : 0] width;
    
    rand logic [$clog2($clog2(FFT_SIZE)) - 1 : 0] log2h;
    rand logic [$clog2(FFT_SIZE) - 1 : 0] height;
    
    rand logic start;  
    
    // constraints
    // constraint c_delay { delay <= 10 ; }
    //constraint c_height { height == 2**(log2h+1)-1; }
    //constraint c_width { width == 2**(log2h+1)-1; }
    
    // UVM factory registration
    `uvm_object_utils_begin(fft2_init_transaction)
        `uvm_field_int(log2w, UVM_DEFAULT)
        `uvm_field_int(width, UVM_DEFAULT)
        `uvm_field_int(log2h, UVM_DEFAULT)
        `uvm_field_int(height, UVM_DEFAULT)
        `uvm_field_int(start, UVM_DEFAULT)
    `uvm_object_utils_end
    
    // new - constructor
    function new(string name = "fft2_init_transaction");
        super.new(name);
    endfunction : new
    
endclass : fft2_init_transaction

`endif
