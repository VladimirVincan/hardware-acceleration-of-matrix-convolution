#include "conv.hpp"

SC_HAS_PROCESS(convolution);

convolution::convolution(sc_module_name name)
  :	sc_module(name)
  , start(false)
{
  SC_THREAD(convolve);
}

void convolution::convolve()
{
  while(1)
    {
      wait(sc_time(1,SC_NS));

      start = start_in->read();
      width = width_in->read();
      height = height_in->read();

      cout << "start = " << start << endl;
      start = false;
      // cout << "width = " << width << endl;
      // cout << "height = " << height << endl;
    }
}
