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

#define ADDR_WIDTH 0x08
#define ADDR_LOG2W 0x0c
#define ADDR_HEIGHT 0x10
#define ADDR_LOG2H 0x14
#define ADDR_CMD 0x18
#define ADDR_STATUS 0x1c

#define VP_ADDR_BRAM_BASE 0x01000000
#define VP_ADDR_BRAM_L 0x01000000
#define VP_ADDR_BRAM_H 0x01100000
#define VP_ADDR_HARD_BASE 0x02000000
#define VP_ADDR_HARD_L 0x02000008
#define VP_ADDR_HARD_H 0x0200001c

#define MAX_SIZE 64
#define MEM_RESERVED 100000

#endif // TYPEDEFS_HPP
