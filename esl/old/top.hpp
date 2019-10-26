#ifndef _TOP_HPP_
#define _TOP_HPP_

#include <systemc>
#include <tlm>
// #include "fft2.hpp"
// #include "soft.hpp"
#include "memory.hpp"
#include "generator.hpp"
#include "conv.hpp"

using namespace sc_core;
using namespace tlm;
using namespace std;

SC_MODULE(top)
{
 public:
  SC_HAS_PROCESS(top);
  top(sc_module_name n);
 protected:
  // hard_ip::fft2 fft2;
  // soft_ip::conv conv;
  memory mem_a, mem_b, mem_c;
  generator gen;
  convolution conv1;

  sc_signal<int> s_gen_height, s_gen_width; //s_log2h, s_log2w;
  sc_signal<bool> s_gen_start;
};

#endif // _TOP_HPP_
