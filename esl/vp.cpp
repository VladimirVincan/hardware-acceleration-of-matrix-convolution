#include "vp.hpp"

Vp::Vp (sc_core::sc_module_name name)
  : sc_module (name)
  , soft("Soft")
  , hard("Hard")
  , bram_re("Bram_RE")
  , bram_im("Bram_IM")
  , bram_ctrl("BramCtrl")
{
  soft.bram_socket.bind(bram_ctrl.soft_socket);
  bram_ctrl.bram_re_socket.bind(bram_re.bram_port_a);
  bram_ctrl.bram_im_socket.bind(bram_im.bram_port_a);
  soft.hard_socket.bind(hard.soft_socket);
  hard.bram_re_socket.bind(bram_re.bram_port_b);
  hard.bram_im_socket.bind(bram_im.bram_port_b);

  SC_REPORT_INFO("Virtual Platform", "Constructed.");
}
