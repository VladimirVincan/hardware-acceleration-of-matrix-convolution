#include <systemc>
#include "vp.hpp"

using namespace sc_core;
using namespace tlm;

int sc_main(int argc, char* argv[])
{
  Vp vp("VP");
	sc_start(500, SC_NS);
  return 0;
}
