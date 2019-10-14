#ifndef TYPEDEFS_HPP
#define TYPEDEFS_HPP

#define SC_INCLUDE_FX
#include <systemc>
#include <tlm>

#define W 32 // DATA_WIDTH
#define I 16 // FIXED_POINT_WIDTH
#define Q sc_dt::SC_RND // quantization methods: SC_RND_ZERO, SC_RND_MIN_INF, SC_RND_INF, SC_RND_CONV, SC_TRN, SC_TRN_ZERO
#define O sc_dt::SC_SAT // overflow methods: SC_SAT_ZERO, SC_SAT_SYM, SC_WRAP, SC_WRAP_SYM
typedef sc_dt::sc_fixed_fast <W, I, Q, O> num_t;

typedef tlm::tlm_base_protocol_types::tlm_payload_type pl_t;
typedef tlm::tlm_base_protocol_types::tlm_phase_type ph_t;

#endif // TYPEDEFS_HPP
