#include "interconnect.hpp"

Interconnect::Interconnect(sc_module_name name) : sc_module(name)
{
  soft_socket.register_b_transport(this, &Interconnect::b_transport);
}

void Interconnect::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
  uint64 addr = pl.get_address();

  switch(addr)
    {
    case ADDR_LOG2W:
      hard_socket.b_transport(pl, offset);
      break;
    case ADDR_WIDTH:
      hard_socket.b_transport(pl, offset);
      break;
    case ADDR_LOG2H:
      hard_socket.b_transport(pl, offset);
      break;
    case ADDR_HEIGHT:
      hard_socket.b_transport(pl, offset);
      break;
    default:
      pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
    }
}
