#include "soft.hpp"

SC_HAS_PROCESS(Soft);

Soft::Soft(sc_core::sc_module_name name) : sc_module(name)
{
  matrix_a_re_file.open("matrix_a_re.txt");
  if(!matrix_a_re_file.is_open())
    SC_REPORT_ERROR("Soft", "Cannot open file.");

  SC_THREAD(convolve);
  SC_REPORT_INFO("Soft", "Constructed.");
}

Soft::~Soft()
{
  matrix_a_re_file.close();
}

void Soft::convolve()
{
  num_t write_val, read_val;
  unsigned char buf[8];

  /*
    ---------------------------------------------
    WRITE PART - read from file, write into BRAMs
    ---------------------------------------------
  */
  matrix_a_re_file >> a_h >> a_w;
  for (int i = 0; i<a_h; ++i)
    for (int j = 0; j < a_w; ++j)
      {
        matrix_a_re_file >> write_val;
        to_uchar(buf, write_val);
        buf[4] = buf[5] = buf[6] = buf[7] = 0;

        pl.set_address((i*a_w + j)*4);
        pl.set_data_length(8);
        pl.set_data_ptr(buf);
        pl.set_command( tlm::TLM_WRITE_COMMAND );
        pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
        sc_core::sc_time offset = sc_core::SC_ZERO_TIME;

        bram_socket->b_transport(pl,offset);
      }

  /*
    ---------------------------------------------
    READ PART - read from BRAMs
    ---------------------------------------------
  */
   for (int i = 0; i<a_h; ++i)
     {
       for (int j = 0; j < a_w; ++j)
         {
           pl.set_address((i*a_w + j)*4);
           pl.set_data_length(8);
           pl.set_data_ptr(buf);
           pl.set_command( tlm::TLM_READ_COMMAND );
           pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
           sc_core::sc_time offset = sc_core::SC_ZERO_TIME;

           bram_socket->b_transport(pl,offset);

           read_val = to_fixed(buf);
           std::cout << read_val << " ";
         }
       std::cout << std::endl;
     }

   std::cout << std::endl;

   for (int i = 0; i<a_h; ++i)
     {
       for (int j = 0; j < a_w; ++j)
         {
           pl.set_address((i*a_w + j)*4);
           pl.set_data_length(8);
           pl.set_data_ptr(buf);
           pl.set_command( tlm::TLM_READ_COMMAND );
           pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
           sc_core::sc_time offset = sc_core::SC_ZERO_TIME;

           bram_socket->b_transport(pl,offset);

           read_val = to_fixed(buf+4);
           std::cout << read_val << " ";
         }
       std::cout << std::endl;
     }
}
