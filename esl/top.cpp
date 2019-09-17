#include "top.hpp"

top::top(sc_module_name n)
  : sc_module(n)
  // , fft2("fft2")
  // , conv("conv")
  // , mem_a("mem_a")
  // , mem_b("mem_b")
  // , mem_c("mem_c")
  , mem("mem")
  , gen("gen")
{
  cout << name() << " constructed." << endl;

  // fft2.width.bind(s_width);
  // fft2.log2w.bind(s_log2w);
  // fft2.height.bind(s_height);
  // fft2.log2h.bind(s_log2h);
  // fft2.isoc(conv.tsoc);

  // conv.width.bind(s_width);
  // conv.log2w.bind(s_log2w);
  // conv.height.bind(s_height);
  // conv.log2h.bind(s_log2h);
  // conv.mem_a.bind(mem_a.tsoc);
  // conv.mem_b.bind(mem_b.tsoc);
  // conv.mem_c.bind(mem_c.tsoc);

  gen.isoc(mem.tsoc);
}

