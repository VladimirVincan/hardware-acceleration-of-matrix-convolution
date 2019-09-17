#ifndef _GENERATOR_HPP_
#define _GENERATOR_HPP_

#define SC_INCLUDE_FX
#include <systemc>
#include <tlm>
#include "utils.hpp"

using namespace std;
using namespace sc_dt;


/*
  Description: generator class is used to initialize the memory values
               of the A, B and C matrices, via DMA.

               generator::gen() write part - sets all values as zero,
                                             converts sc_fixed_fast to char array
                                             sends char array to desired location

               generator::gen() read part - only used to check if values are correctly
                                            initialized


  [TODO] I tried to create utility functions:

               sc_fixed_fast<DATA_WIDTH, FIXED_POINT_WIDTH> to_fixed (unsigned char *buf)
               void to_char (unsigned char *buf, sc_fixed_fast<DATA_WIDTH, FIXED_POINT_WIDTH> val)

         in order to make the generator::gen() code more readable, but it did not want to compile.
 */

class generator :
	public sc_core::sc_module,
	public tlm::tlm_bw_transport_if<>
{
public:
	generator(sc_core::sc_module_name);

	tlm::tlm_initiator_socket<> isoc;

	typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
	typedef tlm::tlm_base_protocol_types::tlm_phase_type phase_t;

	tlm::tlm_sync_enum nb_transport_bw(pl_t&, phase_t&, sc_core::sc_time&);
	void invalidate_direct_mem_ptr(sc_dt::uint64, sc_dt::uint64);

protected:
	void gen();
	bool dmi_valid;
	unsigned char* dmi_mem;

  // typedef sc_fixed_fast<DATA_WIDTH, FIXED_POINT_WIDTH> fixed_float_t;
};

#endif
