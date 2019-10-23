#include <systemc>
// #include "vp.hpp"
#include "utils.hpp"
#include "typedefs.hpp"

using namespace sc_core;
using namespace tlm;

int sc_main(int argc, char* argv[])
{
  //Vp vp("VP");
	//sc_start(500, SC_NS);
  unsigned char c[4];
  to_uchar (c, 3.2);
  for (int i = 0; i<4; ++i)
    cout << (int)c[i] << endl;
  num_t numb = -0.5;
  cout << numb.to_bin() << endl;

  return 0;
}
