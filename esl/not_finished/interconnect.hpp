#ifndef INTERCONNECT_HPP
#define INTERCONNECT_HPP

#include <systemc>
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <tlm_utils/simple_initiator_socket.h>
#include "typedefs.hpp"

#define ADDR_LOG2W 0x01000000
#define ADDR_WIDTH 0x02000000
#define ADDR_LOG2H 0x03000000
#define ADDR_HEIGHT 0x04000000

class Interconnect: public sc_module
{
public:
  Interconnect (sc_module_name name);
  tlm_utils::simple_target_socket<Interconnect> soft_socket;
  tlm_utils::simple_initiator_socket<Interconnect> hard_socket;

protected:
  void b_transport (pl_t &, sc_core::sc_time &);
}

#endif // INTERCONNECT_HPP
