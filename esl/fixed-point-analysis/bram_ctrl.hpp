#ifndef BRAM_CTRL_HPP_
#define BRAM_CTRL_HPP_

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include "typedefs.hpp"

class BramCtrl: public sc_core::sc_module
{
public:
  BramCtrl (sc_core::sc_module_name name);
  ~BramCtrl ();
  tlm_utils::simple_target_socket<BramCtrl> soft_socket;
  tlm_utils::simple_initiator_socket<BramCtrl> bram_re_socket, bram_im_socket;

protected:
  void b_transport (pl_t &, sc_core::sc_time &);
  pl_t pl_re, pl_im;
};

#endif // BRAM_CTRL_HPP_
