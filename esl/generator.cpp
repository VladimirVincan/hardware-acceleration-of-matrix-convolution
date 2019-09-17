#include "generator.hpp"
#include <tlm_utils/tlm_quantumkeeper.h>

using namespace sc_core;
using namespace sc_dt;
using namespace tlm;

SC_HAS_PROCESS(generator);

generator::generator(sc_module_name name) :
	sc_module(name),
	isoc("isoc"),
	dmi_valid(false)
{
	SC_THREAD(gen);
	isoc(*this);
}


void generator::gen()
{
  /*
    ----------------------------------------
                WRITE PART
    ----------------------------------------
  */
  tlm_generic_payload pl;
  double val_d;
  int val_i;
  sc_fix_fast numb(DATA_WIDTH, FIXED_POINT_WIDTH) ;

	// Init first 20 locations to FF with DMI access
	tlm_dmi dmi;
  unsigned int dmi_addr;
	dmi_valid = isoc->get_direct_mem_ptr(pl, dmi);
	if (dmi_valid)
	{
		dmi_mem = dmi.get_dmi_ptr();
		for (int i = 0; i != MATRIX_SIZE; ++i)
      for (int j = 0; j != MATRIX_SIZE; ++j)
        for (int k = 0; k != CHARS_AMOUNT; ++k)
          dmi_mem[i*MATRIX_SIZE*CHARS_AMOUNT + j*CHARS_AMOUNT + k] = 0x00;

    numb = -1.5;
    dmi_addr = 0;
    to_char(&dmi_mem[dmi_addr*CHARS_AMOUNT],numb.to_bin());
	}

  /*
    ----------------------------------------
                 READ PART
    ----------------------------------------
  */

  unsigned int addr = 0;
	sc_time offset = SC_ZERO_TIME;
  unsigned char buf[CHARS_AMOUNT];
	tlm_command cmd = TLM_READ_COMMAND;
	std::string msg = cmd == TLM_WRITE_COMMAND ? "Write " : "Read  ";
	msg += "- address: ";
	msg += std::to_string(addr);
	msg += " data: ";

	pl.set_command         ( cmd                     );
	pl.set_address         ( addr                    );
	pl.set_data_ptr        ( buf                     );
	pl.set_data_length     ( CHARS_AMOUNT            );
	pl.set_response_status ( TLM_INCOMPLETE_RESPONSE );
  isoc->b_transport(pl, offset);

  numb = 0;
  numb = to_fixed(buf);
  msg += std::to_string(numb);
  msg += " ";
  SC_REPORT_INFO("generator", msg.c_str()) ;
}

tlm_sync_enum generator::nb_transport_bw(pl_t& pl, phase_t& phase, sc_time& offset)
{
	return TLM_ACCEPTED;
}

void generator::invalidate_direct_mem_ptr(uint64 start, uint64 end)
{
	dmi_valid = false;
}
