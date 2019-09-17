#ifndef _TOP_HPP_
#define _TOP_HPP_

#include <systemc>
#include <tlm>
// #include "fft2.hpp"
// #include "soft.hpp"
#include "memory.hpp"
#include "generator.hpp"

using namespace sc_core;
using namespace tlm;
using namespace std;

SC_MODULE(top)
{
 public:
  SC_HAS_PROCESS(top);
  top(sc_module_name n);
 private:
  // hard_ip::fft2 fft2;
  // soft_ip::conv conv;
  // memory::memory mem_a, mem_b, mem_c;
  memory mem;
  generator gen;

  // sc_signal<int> s_height, s_width, s_log2h, s_log2w;
};

#endif // _TOP_HPP_
