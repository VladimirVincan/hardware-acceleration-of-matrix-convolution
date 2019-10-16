#ifndef HARD_HPP_
#define HARD_HPP_

#include <systemc>
#include <math.h>
#include <tlm_utils/simple_initiator_socket.h>
#include <tlm_utils/simple_target_socket.h>
#include "typedefs.hpp"
#include "utils.hpp"

class Hard : public sc_core::sc_module
{
public:
  // SC_HAS_PROCESS(Hard);
  Hard(sc_core::sc_module_name name);
  ~Hard();
  tlm_utils::simple_initiator_socket<Hard> bram_re_socket;
  tlm_utils::simple_initiator_socket<Hard> bram_im_socket;
  tlm_utils::simple_target_socket<Hard> soft_socket;

protected:
  pl_t pl;
  sc_core::sc_time offset;
  int width, height, log2w, log2h, start, ready;
  num_t dataRE[MAX_SIZE], dataIM[MAX_SIZE];
  num_t wCOS[MAX_SIZE], wSIN[MAX_SIZE];
  void fft2(sc_core::sc_time &);
  void fft(int, int, num_t*, num_t*);
  void butterfly(num_t, num_t, num_t, num_t, num_t*, num_t*, num_t*, num_t*, int);
  void initTwiddle(int);
  void b_transport(pl_t &pl, sc_core::sc_time &offset);
  void debug_read();
  num_t read_bram(int addr, char c);
  void write_bram(int addr, num_t val, char c);
};

#endif // HARD_HPP_
