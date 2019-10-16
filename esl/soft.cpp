#include "soft.hpp"

SC_HAS_PROCESS(Soft);

Soft::Soft(sc_core::sc_module_name name)
  : sc_module(name)
  , offset(sc_core::SC_ZERO_TIME)
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
        write_bram(i*a_w+j,write_val,0);
        // to_uchar(buf, write_val);
        // buf[4] = buf[5] = buf[6] = buf[7] = 0;

        // pl.set_address((i*a_w + j)*4);
        // pl.set_data_length(8);
        // pl.set_data_ptr(buf);
        // pl.set_command( tlm::TLM_WRITE_COMMAND );
        // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );

        // bram_socket->b_transport(pl,offset);
      }

  /*
    --------------------------------------------
    WRITE PART - write dimensions into HARD IP
    --------------------------------------------
  */

  write_hard(ADDR_WIDTH, a_w-1);
  // to_uchar (buf, a_w-1);
  // pl.set_address(ADDR_WIDTH);
  // pl.set_data_length(4);
  // pl.set_data_ptr(buf);
  // pl.set_command( tlm::TLM_WRITE_COMMAND );
  // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  // hard_socket->b_transport(pl,offset);

  write_hard(ADDR_LOG2W, log(a_w-1));
  // to_uchar (buf, log(a_w-1)); // log2w
  // pl.set_address(ADDR_LOG2W);
  // pl.set_data_length(4);
  // pl.set_data_ptr(buf);
  // pl.set_command( tlm::TLM_WRITE_COMMAND );
  // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  // hard_socket->b_transport(pl,offset);

  write_hard(ADDR_HEIGHT, a_h-1);
  // to_uchar (buf, a_h-1);
  // pl.set_address(ADDR_HEIGHT);
  // pl.set_data_length(4);
  // pl.set_data_ptr(buf);
  // pl.set_command( tlm::TLM_WRITE_COMMAND );
  // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  // hard_socket->b_transport(pl,offset);

  write_hard(ADDR_LOG2H, log(a_h-1));
  // to_uchar (buf, log(a_h-1)); // log210
  // pl.set_address(ADDR_LOG2H);
  // pl.set_data_length(4);
  // pl.set_data_ptr(buf);
  // pl.set_command( tlm::TLM_WRITE_COMMAND );
  // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  // hard_socket->b_transport(pl,offset);


  /*
    --------------------------------------------
    WRITE PART - start the HARD IP
    --------------------------------------------
  */

  write_hard(ADDR_CMD, 1);
  // to_uchar (buf, 1);
  // pl.set_address(ADDR_CMD);
  // pl.set_data_length(4);
  // pl.set_data_ptr(buf);
  // pl.set_command( tlm::TLM_WRITE_COMMAND );
  // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  // hard_socket->b_transport(pl,offset);

  int ready = 1;
  while (ready)
    {
      ready = read_hard(ADDR_STATUS);
      // pl.set_address(ADDR_STATUS);
      // pl.set_data_length(4);
      // pl.set_data_ptr(buf);
      // pl.set_command( tlm::TLM_READ_COMMAND );
      // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
      // sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
      // hard_socket->b_transport(pl,offset);

      // ready = to_fixed(buf);
      // std::cout << "ready = " << ready << std::endl;;
    }


  write_hard(ADDR_CMD, 0);
  // to_uchar (buf, 0);
  // pl.set_address(ADDR_CMD);
  // pl.set_data_length(4);
  // pl.set_data_ptr(buf);
  // pl.set_command( tlm::TLM_WRITE_COMMAND );
  // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  // hard_socket->b_transport(pl,offset);

  /*
    --------------------------------------------
    READ PART - wait for the HARD IP to finish
    --------------------------------------------
  */

  while (!ready)
    {
      ready = read_hard(ADDR_STATUS);
      // pl.set_address(ADDR_STATUS);
      // pl.set_data_length(4);
      // pl.set_data_ptr(buf);
      // pl.set_command( tlm::TLM_READ_COMMAND );
      // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
      // sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
      // hard_socket->b_transport(pl,offset);
      // ready = to_int(buf);
    }

  /*
    ---------------------------------------------
    READ PART - read from BRAMs
    ---------------------------------------------
  */
  num_t readRE, readIM;

  std::cout << std::endl << "Final results:" << std::endl << std::endl;
   for (int i = 0; i<a_h; ++i)
     {
       for (int j = 0; j < a_w; ++j)
         {
           // pl.set_address((i*a_w + j)*4);
           // pl.set_data_length(8);
           // pl.set_data_ptr(buf);
           // pl.set_command( tlm::TLM_READ_COMMAND );
           // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
           // sc_core::sc_time offset = sc_core::SC_ZERO_TIME;

           // bram_socket->b_transport(pl,offset);

           // read_val = to_fixed(buf);
           read_bram(i*a_w+j, readRE, readIM);
           std::cout << readRE << " ";
         }
       std::cout << std::endl;
     }

   std::cout << std::endl;

   for (int i = 0; i<a_h; ++i)
     {
       for (int j = 0; j < a_w; ++j)
         {
           // pl.set_address((i*a_w + j)*4);
           // pl.set_data_length(8);
           // pl.set_data_ptr(buf);
           // pl.set_command( tlm::TLM_READ_COMMAND );
           // pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
           // sc_core::sc_time offset = sc_core::SC_ZERO_TIME;

           // bram_socket->b_transport(pl,offset);

           // read_val = to_fixed(buf+4);
           // std::cout << read_val << " ";
           read_bram(i*a_w+j, readRE, readIM);
           std::cout << readIM << " ";
         }
       std::cout << std::endl;
     }
}

void Soft::read_bram(int addr, num_t &valRE, num_t &valIM)
{
  pl_t pl;
  unsigned char buf[8];
  pl.set_address(addr*4);
  pl.set_data_length(8);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_READ_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  bram_socket->b_transport(pl,offset);

  valRE = to_fixed(buf);
  valIM = to_fixed(buf+4);
}

void Soft::write_bram(int addr, num_t valRE, num_t valIM)
{
  pl_t pl;
  unsigned char buf[8];
  to_uchar(buf,valRE);
  to_uchar(buf+4, valIM);
  pl.set_address(addr*4);
  pl.set_data_length(8);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_WRITE_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  bram_socket->b_transport(pl,offset);
}

int Soft::read_hard(int addr)
{
  pl_t pl;
  unsigned char buf[4];
  pl.set_address(addr);
  pl.set_data_length(4);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_READ_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
  hard_socket->b_transport(pl,offset);
  return to_int(buf);
}

void Soft::write_hard(int addr, int val)
{
  pl_t pl;
  unsigned char buf[4];
  to_uchar (buf, val);
  pl.set_address(addr);
  pl.set_data_length(4);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_WRITE_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  hard_socket->b_transport(pl,offset);
}
