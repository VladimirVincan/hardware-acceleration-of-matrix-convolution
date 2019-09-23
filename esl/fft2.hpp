#define SC_INCLUDE_FX
#include <systemc>
#include <math.h>
// #include "utils.hpp"

using namespace std;
using namespace sc_dt;
// using namespace tlm;
using namespace sc_core;

class convolution :
	public sc_core::sc_module
	// public tlm::tlm_bw_transport_if<>
{
public:
  convolution(sc_core::sc_module_name);

  // convolution interface
  sc_core::sc_out<int> data_o_addr_o;
  sc_core::sc_in<double> dataRE_i;
  sc_core::sc_in<double> dataIM_i;
  sc_core::sc_out<bool> data_rd_o;
  sc_core::sc_in<bool> data_rd_i;

  sc_core::sc_out<int> data_i_addr_o;
  sc_core::sc_out<double> dataRE_o;
  sc_core::sc_out<double> dataIM_o;
  sc_core::sc_in<bool> data_wr_i;
  sc_core::sc_out<bool> data_wr_o;

  sc_core::sc_in<int> width_i, height_i, log2w_i, log2h_i;

  sc_core::sc_out<bool> start_fft2;
  sc_core::sc_in<bool> ready_fft2;

protected:
  void transform();

  bool start;
  int width, height, log2w, log2h;

  int addr;
  string msg;

  enum fsm {
    idle,
    begin_conv,
    calc_log,
    fft2_a_start,
    fft2_a_received,
    fft2_a_memory,
    fft2_a_finished,
    fft2_b_start,
    fft2_b_received,
    fft2_b_memory,
    fft2_b_finished,
    mult,
    fft2_c_start,
    fft2_c_received,
    fft2_c_memory,
    fft2_c_finished,
    write_to_file
  };
  fsm state;
};
