#define SC_INCLUDE_FX
#include <systemc>
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

  sc_core::sc_in<int> width_in;
  sc_core::sc_in<int> height_in;
	sc_core::sc_in<bool> start_in;

protected:
  void convolve();

  bool start;
  int width, height;
};
