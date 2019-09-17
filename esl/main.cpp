#include <systemc>
#include "top.hpp"

using namespace sc_core;
using namespace tlm;

int sc_main(int argc, char* argv[])
{
  top top_i("top");
	sc_start(200, SC_NS);
  return 0;
}
