/****************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            fft2_dout_din_transaction.sv

    DESCRIPTION     sequence item

 ****************************************************************************/

`ifndef FFT2_DOUT_DIN_TRANSACTION_SV
`define FFT2_DOUT_DIN_TRANSACTION_SV

/**
 * Class: fft2_dout_din_transaction
 */
class fft2_dout_din_transaction extends uvm_sequence_item;
    
    // fields
	rand logic [$clog2(FFT_SIZE*FFT_SIZE) - 1 : 0] data_i_addr_o;
	rand logic [$clog2(FFT_SIZE*FFT_SIZE) - 1 : 0] data_o_addr_o;
    rand logic [DATA_WIDTH - 1 : 0] dataRE_i;
	rand logic [DATA_WIDTH - 1 : 0] dataRE_o;
    rand logic [DATA_WIDTH - 1 : 0] dataIM_i;
	rand logic [DATA_WIDTH - 1 : 0] dataIM_o;
    rand logic data_rd_i;
    rand logic data_wr_i; 
	rand bit last;
    
    // constraints
    // constraint c_delay {soft delay <= 10 ; } -- can add soft constraint
    //constraint c_dataRE { dataRE_i [DATA_WIDTH-1 : DATA_WIDTH-13] == 12'h0; }
    //constraint c_dataIM { dataIM_i [DATA_WIDTH-1 : DATA_WIDTH-13] == 12'h0; }
    
    // UVM factory registration
    `uvm_object_utils_begin(fft2_dout_din_transaction)
        `uvm_field_int(dataRE_i, UVM_DEFAULT)
        `uvm_field_int(dataIM_i, UVM_DEFAULT)
		`uvm_field_int(dataRE_o, UVM_DEFAULT)
        `uvm_field_int(dataIM_o, UVM_DEFAULT)
        `uvm_field_int(data_rd_i, UVM_DEFAULT)
        `uvm_field_int(data_wr_i, UVM_DEFAULT)
		`uvm_field_int(data_i_addr_o, UVM_DEFAULT)
        `uvm_field_int(data_o_addr_o, UVM_DEFAULT)
    `uvm_object_utils_end
    
    // new - constructor
    function new(string name = "fft2_dout_din_transaction");
        super.new(name);
    endfunction : new
    
endclass : fft2_dout_din_transaction

`endif
