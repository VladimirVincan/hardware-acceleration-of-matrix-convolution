#include "generator.hpp"

using namespace sc_core;
using namespace sc_dt;
using namespace tlm;

SC_HAS_PROCESS(generator);

generator::generator(sc_module_name name) :
	sc_module(name),
	isoc_a("isoc_a"),
	isoc_b("isoc_b"),
	isoc_c("isoc_c"),
	dmi_valid_a(false),
	dmi_valid_b(false),
	dmi_valid_c(false)
{
	SC_THREAD(gen);
	isoc_a(*this);
	isoc_b(*this);
	isoc_c(*this);
}


void generator::gen()
{
  sc_fix_fast write_val(DATA_WIDTH, FIXED_POINT_WIDTH) ;
  /*
    ----------------------------------------
                WRITE PART
    ----------------------------------------
  */
  tlm_generic_payload pl;
	tlm_dmi dmi_a, dmi_b, dmi_c;
  unsigned int dmi_addr;
	dmi_valid_a = isoc_a->get_direct_mem_ptr(pl, dmi_a);
	dmi_valid_b = isoc_b->get_direct_mem_ptr(pl, dmi_b);
	dmi_valid_c = isoc_c->get_direct_mem_ptr(pl, dmi_c);

	if (dmi_valid_a && dmi_valid_b && dmi_valid_c)
	{
		dmi_mem_a = dmi_a.get_dmi_ptr();
		dmi_mem_b = dmi_b.get_dmi_ptr();
		dmi_mem_c = dmi_c.get_dmi_ptr();

    // initialize all matrices to zero
		for (int i = 0; i != MATRIX_SIZE; ++i)
      for (int j = 0; j != MATRIX_SIZE; ++j)
        for (int k = 0; k != CHARS_AMOUNT; ++k)
          {
            dmi_mem_a[i*MATRIX_SIZE*CHARS_AMOUNT + j*CHARS_AMOUNT + k] = 0x00;
            dmi_mem_b[i*MATRIX_SIZE*CHARS_AMOUNT + j*CHARS_AMOUNT + k] = 0x00;
            dmi_mem_c[i*MATRIX_SIZE*CHARS_AMOUNT + j*CHARS_AMOUNT + k] = 0x00;
          }

    // set matrix A
    write_val = 1.0;
    dmi_addr = 0;
    to_char(&dmi_mem_a[dmi_addr*CHARS_AMOUNT],write_val.to_bin());

    // set matrix B
    write_val = 1.0;
    dmi_addr = 1;
    to_char(&dmi_mem_b[dmi_addr*CHARS_AMOUNT],write_val.to_bin());
	}
  else SC_REPORT_INFO("generator", "DMI valid error.");

  /*
    ----------------------------------------
                 READ PART
    ----------------------------------------
  */

  unsigned int addr;
	sc_time offset = SC_ZERO_TIME;
  unsigned char buf[CHARS_AMOUNT];
	tlm_command cmd = TLM_READ_COMMAND;
  string msg;

  // read matrix A
  addr = 0;

	pl.set_command         ( cmd                     );
	pl.set_address         ( addr                    );
	pl.set_data_ptr        ( buf                     );
	pl.set_data_length     ( CHARS_AMOUNT            );
	pl.set_response_status ( TLM_INCOMPLETE_RESPONSE );
  isoc_a->b_transport(pl, offset);

  write_val = 0;
  write_val = to_fixed(buf);
	msg = "Read matrix A - address: " + std::to_string(addr) + " data: " + std::to_string(write_val);
  SC_REPORT_INFO("generator", msg.c_str()) ;

  // read matrix B
  addr = 4;

	pl.set_command         ( cmd                     );
	pl.set_address         ( addr                    );
	pl.set_data_ptr        ( buf                     );
	pl.set_data_length     ( CHARS_AMOUNT            );
	pl.set_response_status ( TLM_INCOMPLETE_RESPONSE );
  isoc_b->b_transport(pl, offset);

  write_val = 0;
  write_val = to_fixed(buf);
	msg = "Read matrix B - address: " + std::to_string(addr) + " data: " + std::to_string(write_val);
  SC_REPORT_INFO("generator", msg.c_str()) ;

  /*
    ----------------------------------------
    READ PART
    ----------------------------------------
  */

  height->write(8);
  width->write(8);
  start->write(true);

  wait(sc_time(3,SC_NS));
  start->write(false);
}

tlm_sync_enum generator::nb_transport_bw(pl_t& pl, phase_t& phase, sc_time& offset)
{
	return TLM_ACCEPTED;
}

void generator::invalidate_direct_mem_ptr(uint64 start, uint64 end)
{
	dmi_valid_a = false;
	dmi_valid_b = false;
	dmi_valid_c = false;
}
