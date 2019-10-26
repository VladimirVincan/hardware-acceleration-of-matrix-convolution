#include "soft.hpp"

SC_HAS_PROCESS(Soft);

Soft::Soft(sc_core::sc_module_name name)
  : sc_module(name)
  , offset(sc_core::SC_ZERO_TIME)
{
  matrix_a_re_file.open("matrix_a_re.txt");
  matrix_b_re_file.open("matrix_b_re.txt");
  if(!matrix_a_re_file.is_open() || !matrix_b_re_file.is_open())
    SC_REPORT_ERROR("Soft", "Cannot open file.");

  SC_THREAD(convolve);
  SC_REPORT_INFO("Soft", "Constructed.");
}

Soft::~Soft()
{
  matrix_a_re_file.close();
  matrix_b_re_file.close();
  SC_REPORT_INFO("Soft", "Destroyed.");
}

void Soft::convolve()
{
  num_t write_val, read_val;
  unsigned char buf[8];

  /*
    ---------------------------------------------
    WRITE PART - read from files, write into BRAMs
    ---------------------------------------------
  */
  matrix_a_re_file >> a_h >> a_w;
  matrix_b_re_file >> b_h >> b_w;
  width = setBitNumber(a_w+b_w-1);
  height = setBitNumber(a_h+b_h-1);
  // width = a_w;
  // height = a_h;

  for (int i = 0; i<height; ++i) // add A
    for (int j = 0; j < width; ++j)
      {
        if (i<a_h && j<a_w)
          {
            matrix_a_re_file >> write_val;
            write_bram(i*width+j,write_val,0);
          }
        else
            write_bram(i*width+j,0,0);
      }

  for (int i = 0; i<height; ++i) // add B
    for (int j = 0; j < width; ++j)
      {
        if (i<b_h && j<b_w)
          {
            matrix_b_re_file >> write_val;
            write_bram(i*width+j + width*height,write_val,0);
          }
        else
          write_bram(i*width+j + width*height,0,0);
      }

  /*
    --------------------------------------------
    WRITE PART - write dimensions of A into HARD IP
    --------------------------------------------
  */

  write_hard(ADDR_WIDTH, width-1); // -1 because thats how the IP was implemented
  write_hard(ADDR_LOG2W, log(width)-1);
  write_hard(ADDR_HEIGHT, height-1);
  write_hard(ADDR_LOG2H, log(height)-1);

  /*
    --------------------------------------------
    FFT2 PART - start the HARD IP, wait until it finishes (fft2 over A)
    --------------------------------------------
  */
  // std::cout << std::endl << "A matrix begun" << std::endl << std::endl;
  // debug_read(0);

  write_hard(ADDR_CMD, 1);
  int ready = 1;
  while (ready)
    {
      ready = read_hard(ADDR_STATUS);
    }
  write_hard(ADDR_CMD, 0);
  while (!ready)
    {
      ready = read_hard(ADDR_STATUS);
    }

  std::cout << std::endl << "A matrix finished" << std::endl << std::endl;
  debug_read(0);
  /*
    --------------------------------------------
    SWAP PART - change A and B matrix positions
    --------------------------------------------
  */

  num_t a_re, a_im, b_re, b_im;
  for (int i = 0; i<height; ++i)
    for (int j = 0; j < width; ++j)
      {
        read_bram(i*width+j, a_re, a_im);
        read_bram(i*width+j + width*height, b_re, b_im);
        write_bram(i*width+j, b_re, b_im);
        write_bram(i*width+j + width*height, a_re, a_im);
      }

  /*
    --------------------------------------------
    FFT2 PART - start the HARD IP, wait until it finishes (fft2 over B)
    --------------------------------------------
  */
  // std::cout << std::endl << "B matrix begun" << std::endl << std::endl;
  // debug_read(0);

  write_hard(ADDR_CMD, 1);
  while (ready)
    {
      ready = read_hard(ADDR_STATUS);
    }
  write_hard(ADDR_CMD, 0);
  while (!ready)
    {
      ready = read_hard(ADDR_STATUS);
    }

  std::cout << std::endl << "B matrix finished" << std::endl << std::endl;
  debug_read(0);

  /*
    --------------------------------------------
    MULTIPLICATION PART - create C_inv (A*B element-wise)
    --------------------------------------------
  */

  num_t c_re, c_im;
  for (int i = 0; i<height; ++i)
    for (int j = 0; j < width; ++j)
      {
        read_bram(i*width+j, b_re, b_im);
        read_bram(i*width+j + width*height, a_re, a_im);
        c_re = a_re*b_re - a_im*b_im;
        c_im = -(a_re*b_im + a_im*b_re);
        write_bram(i*width+j, c_re, c_im);
      }

  /*
    --------------------------------------------
    INVERSE FFT2 PART - start the HARD IP, wait until it finishes (fft2 over A*B element-wise)
    --------------------------------------------
  */
  // std::cout << std::endl << "C matrix begun" << std::endl << std::endl;
  // debug_read(0);

  write_hard(ADDR_CMD, 1);
  while (ready)
    {
      ready = read_hard(ADDR_STATUS);
    }
  write_hard(ADDR_CMD, 0);
  while (!ready)
    {
      ready = read_hard(ADDR_STATUS);
    }

  /*
    --------------------------------------------
    DIVISION PART - C/(width*height) element-wise
    --------------------------------------------
  */

  // std::cout << std::endl << "C matrix intermediary" << std::endl << std::endl;
  // debug_read(0);

  for (int i = 0; i<height; ++i)
    for (int j = 0; j < width; ++j)
      {
        read_bram(i*width+j, c_re, c_im);
        c_re /= width*height;
        c_im /= width*height;
        write_bram(i*width+j, c_re, c_im);
      }

  /*
    ---------------------------------------------
    READ PART - read from BRAMs
    ---------------------------------------------
  */
  std::cout << std::endl << "C matrix finished" << std::endl << std::endl;
  debug_read(0);
}

void Soft::read_bram(sc_dt::uint64 addr, num_t &valRE, num_t &valIM)
{
  pl_t pl;
  unsigned char buf[8];
  pl.set_address((addr*4) | VP_ADDR_BRAM_BASE);
  pl.set_data_length(8);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_READ_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  interconnect_socket->b_transport(pl,offset);

  valRE = to_fixed(buf);
  valIM = to_fixed(buf+4);
}

void Soft::write_bram(sc_dt::uint64 addr, num_t valRE, num_t valIM)
{
  pl_t pl;
  unsigned char buf[8];
  to_uchar(buf,valRE);
  to_uchar(buf+4, valIM);
  pl.set_address((addr*4) | VP_ADDR_BRAM_BASE);
  pl.set_data_length(8);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_WRITE_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  interconnect_socket->b_transport(pl,offset);
}

int Soft::read_hard(sc_dt::uint64 addr)
{
  pl_t pl;
  unsigned char buf[4];
  pl.set_address(addr | VP_ADDR_HARD_BASE);
  pl.set_data_length(4);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_READ_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  sc_core::sc_time offset = sc_core::SC_ZERO_TIME;
  interconnect_socket->b_transport(pl,offset);
  return to_int(buf);
}

void Soft::write_hard(sc_dt::uint64 addr, int val)
{
  pl_t pl;
  unsigned char buf[4];
  to_uchar (buf, val);
  pl.set_address(addr | VP_ADDR_HARD_BASE);
  pl.set_data_length(4);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_WRITE_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  interconnect_socket->b_transport(pl,offset);
}

void Soft::debug_read(int offset)
{
  num_t readRE, readIM;

  for (int i = 0; i<height; ++i)
    {
      for (int j = 0; j < width; ++j)
        {
          read_bram(i*width+j + offset, readRE, readIM);
          std::cout << readRE << " ";
        }
      std::cout << std::endl;
    }

  std::cout << std::endl;

  for (int i = 0; i<height; ++i)
    {
      for (int j = 0; j < width; ++j)
        {
          read_bram(i*width+j + offset, readRE, readIM);
          std::cout << readIM << " ";
        }
      std::cout << std::endl;
    }
}
