#include "memory.hpp"

using namespace sc_core;
using namespace tlm;
using namespace sc_dt;

memory::memory(sc_module_name name) :
	sc_module(name),
	tsoc("tsoc")
{
	tsoc(*this);
	for (int i = 0; i != RAM_SIZE; ++i)
		ram[i] = 0;
}

void memory::b_transport(pl_t& pl, sc_time& offset)
{
	tlm_command cmd    = pl.get_command();
	uint64 adr         = pl.get_address();
	unsigned char *buf = pl.get_data_ptr();
	unsigned int len   = pl.get_data_length();

	switch(cmd)
	{
	case TLM_WRITE_COMMAND:
		for (unsigned int i = 0; i != len; ++i)
			ram[adr++] = buf[i];
		pl.set_response_status( TLM_OK_RESPONSE );
		break;
	case TLM_READ_COMMAND:
		for (unsigned int i = 0; i != len; ++i)
			buf[i] = ram[adr++];
		pl.set_response_status( TLM_OK_RESPONSE );
		break;
	default:
		pl.set_response_status( TLM_COMMAND_ERROR_RESPONSE );
	}

	offset += sc_time(3, SC_NS);
}

tlm_sync_enum memory::nb_transport_fw(pl_t& pl, phase_t& phase, sc_time& offset)
{
	return TLM_ACCEPTED;
}

bool memory::get_direct_mem_ptr(pl_t& pl, tlm_dmi& dmi)
{
	dmi.allow_read_write();

	dmi.set_dmi_ptr       ( ram );
	dmi.set_start_address ( 0 );
	dmi.set_end_address   ( RAM_SIZE - 1 );

	return true;
}

unsigned int memory::transport_dbg(pl_t& pl)
{
	tlm_command cmd = pl.get_command();
	unsigned char* ptr = pl.get_data_ptr();

	if ( cmd == TLM_READ_COMMAND )
		memcpy(ptr, ram, RAM_SIZE);
	else if ( cmd == TLM_WRITE_COMMAND )
		memcpy(ram, ptr, RAM_SIZE);

	return RAM_SIZE;
}
