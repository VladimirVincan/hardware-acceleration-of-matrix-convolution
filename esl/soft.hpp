#ifndef SOFT_HPP_
#define SOFT_HPP_

#include <iostream>
#include <fstream>
#include <systemc>
#include <tlm_utils/simple_initiator_socket.h>
#include "typedefs.hpp"
#include "utils.hpp"

class Soft : public sc_core::sc_module
{
public:
  Soft(sc_core::sc_module_name name);
  ~Soft();
  tlm_utils::simple_initiator_socket<Soft> interconnect_socket;

protected:
  void convolve();
  pl_t pl;
  sc_core::sc_time offset;
  std::ifstream matrix_a_re_file, matrix_b_re_file;
  int a_w, a_h, b_w, b_h, width, height, log2w, log2h;
  void read_bram(sc_dt::uint64 addr, num_t &valRE, num_t &valIM);
  void write_bram(sc_dt::uint64 addr, num_t valRE, num_t valIM);
  int read_hard(sc_dt::uint64 addr);
  void write_hard(sc_dt::uint64 addr, int val);
  void debug_read(int offset);
};

#endif // SOFT_HPP_
