#include "hard.hpp"

Hard::Hard(sc_core::sc_module_name name)
  : sc_module(name)
  , width(0)
  , log2w(0)
  , height(0)
  , log2h(0)
  , start(0)
  , ready(1)
  , offset(sc_core::SC_ZERO_TIME)
{
  soft_socket.register_b_transport(this, &Hard::b_transport);
  initTwiddle(MAX_SIZE);
  // SC_THREAD(fft2);
  SC_REPORT_INFO("Hard", "Constructed.");
}

Hard::~Hard()
{
  SC_REPORT_INFO("Hard", "Destroyed.");
}

void Hard::b_transport(pl_t &pl, sc_core::sc_time &offset)
{
  tlm::tlm_command cmd = pl.get_command();
  sc_dt::uint64 addr = pl.get_address();
  unsigned int len = pl.get_data_length();
  unsigned char *buf = pl.get_data_ptr();
  pl.set_response_status( tlm::TLM_OK_RESPONSE );

	switch(cmd)
    {
    case tlm::TLM_WRITE_COMMAND:
      switch(addr)
        {
        case ADDR_WIDTH:
          width = to_int(buf)+1;
          break;
        case ADDR_LOG2W:
          log2w = to_int(buf)+1;
          break;
        case ADDR_HEIGHT:
          height = to_int(buf)+1;
          break;
        case ADDR_LOG2H:
          log2h = to_int(buf)+1;
          break;
        case ADDR_CMD:
          start = to_int(buf);
          fft2(offset);
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != 4) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
    case tlm::TLM_READ_COMMAND:
      switch(addr)
        {
        case ADDR_STATUS:
          to_uchar(buf, ready);
          break;
        default:
          pl.set_response_status( tlm::TLM_ADDRESS_ERROR_RESPONSE );
        }
      if (len != 4) pl.set_response_status( tlm::TLM_BURST_ERROR_RESPONSE );
      break;
    default:
      pl.set_response_status( tlm::TLM_COMMAND_ERROR_RESPONSE );
    }
  offset += sc_core::sc_time(10, sc_core::SC_NS);
}

void Hard::fft2(sc_core::sc_time &system_offset)
{
  // std::cout << "Entered fft2 module." << endl;

  pl_t pl;
  unsigned char buf[8];

  if (start == 1 && ready == 1)
    {
      ready = 0;
      offset += sc_core::sc_time(10, sc_core::SC_NS);
      // std::cout << "start = 1 && ready == 1" << endl;
    }
  else if (start == 1 && ready == 0)
    {
      offset += sc_core::sc_time(10, sc_core::SC_NS);
      // std::cout << "start = 1 && ready == 0" << endl;
    }
  else if (start == 0 && ready == 0)
    {
      // std::cout << "start = 0" << endl;
  /*
    ---------------------------------------------
    DEBUG PART - read initial values of BRAMs
    ---------------------------------------------
  */
  // std::cout << std::endl << "Initial results:" << std::endl << std::endl;
  // debug_read();
      /*
        ---------------------------------------------
        // bit reverasal & horizontal FFT
        ---------------------------------------------
      */

      for (int i = 0; i< height; ++i){
        for (int j = 0; j < width; ++j){
          int reversed = 0;
          int temp = j;
          for (int k = 0; k < log2w; ++k){
            reversed = reversed << 1;
            reversed = reversed | (temp&1);
            temp = temp >> 1;
          }
          dataRE[j] = read_bram(i*width+reversed, 'r');
          dataIM[j] = read_bram(i*width+reversed, 'i');
        }
        fft(width, log2w, dataRE, dataIM);

        for (int j=0; j < width; ++j){
          write_bram(i*width+j, dataRE[j], 'r');
          write_bram(i*width+j, dataIM[j], 'i');
        }
      }

  /*
    ---------------------------------------------
    DEBUG PART - read intermediary results BRAMs
    ---------------------------------------------
  */

      // std::cout << std::endl << "Intermediary results:" << std::endl << std::endl;
      // debug_read();

   /*
     ---------------------------------------------
     bit reversal & vertical FFT
     ---------------------------------------------
   */

      for (int j =0;j<width; ++j){
        for (int i=0;i<height; ++i){
          int reversed = 0;
          int temp = i;
          for (int k = 0; k < log2h; ++k){
            reversed = reversed << 1;
            reversed = reversed | (temp&1);
            temp = temp >> 1;
          }
          dataRE[i] = read_bram(reversed*width+j,'r');
          dataIM[i] = read_bram(reversed*width+j,'i');
        }
        fft(height, log2h, dataRE, dataIM);

        for (int i=0;i<height; ++i){
          write_bram(i*width+j,dataRE[i],'r');
          write_bram(i*width+j,dataIM[i],'i');
        }
      }
      offset += sc_core::sc_time(200, sc_core::SC_NS);
      ready = 1;
      // std::cout << "Finished fft2" << std::endl;
    }
}

void Hard::butterfly(
  num_t topRE_i,
  num_t topIM_i,
  num_t bottomRE_i,
  num_t bottomIM_i,
  num_t *topRE_o,
  num_t *topIM_o,
  num_t *bottomRE_o,
  num_t *bottomIM_o,
  int k)
{
  // std::cout << "Entered butterfly module." << endl;

  num_t botRE = bottomRE_i * wCOS[k] - bottomIM_i * wSIN[k];
  num_t botIM = bottomRE_i * wSIN[k] + bottomIM_i * wCOS[k];

  *topRE_o = topRE_i + botRE;
  *topIM_o = topIM_i + botIM;
  *bottomRE_o = topRE_i - botRE;
  *bottomIM_o = topIM_i - botIM;

  // std::cout << k << " " << wCOS[k] << " " << wSIN[k] << " " << topRE_i << " " << topIM_i << " " << bottomRE_i << " " << bottomIM_i << " " << *topRE_o << " " << *topIM_o << " " << *bottomRE_o << " " << *bottomIM_o << std::endl;
}

void Hard::fft(
  int size,
  int log2size,
  num_t *dataRE,
  num_t *dataIM
)
{
  // std::cout << "Entered fft module." << endl;

  // std::cout << "dataRE = ";
  // for (int i = 0; i<size; ++i)
  //   std::cout << dataRE[i] << " ";
  // std::cout << std::endl;

  for (int i=0; i < log2size; ++i){
    int m = 1 << (i+1);
    int m2 = 1 << i; // "half of m"
    for (int j=0; j < m2; ++j){
      for (int k=j; k < size; k+=m){
        num_t topRE = dataRE[k];
        num_t topIM = dataIM[k];
        num_t bottomRE = dataRE[k+m2];
        num_t bottomIM = dataIM[k+m2];
        butterfly(
          topRE,
          topIM,
          bottomRE,
          bottomIM,
          dataRE+k,
          dataIM+k,
          dataRE+k+m2,
          dataIM+k+m2,
          j*MAX_SIZE/(2<<i));
      }
    }
  }
}

void Hard::initTwiddle(int size)
{
  for (int k = 0; k < size/2; ++k){
    wCOS[k] = std::cos(-2.0*M_PI*k / size);
    wSIN[k] = std::sin(-2.0*M_PI*k / size);
  }
}

void Hard::debug_read()
{
   for (int i = 0; i<height; ++i)
     {
       for (int j = 0; j < width; ++j)
         {
           std::cout << read_bram(i*width+j,'r') << " ";
         }
       std::cout << std::endl;
     }

   std::cout << std::endl;

   for (int i = 0; i<height; ++i)
     {
       for (int j = 0; j < width; ++j)
         {
           std::cout << read_bram(i*width+j,'i') << " ";
         }
       std::cout << std::endl;
     }
   std::cout << std::endl;
}

num_t Hard::read_bram(int addr, char c)
{
  pl_t pl;
  unsigned char buf[4];
  pl.set_address(addr*4);
  pl.set_data_length(4);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_READ_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  sc_core::sc_time offset = sc_core::SC_ZERO_TIME;

  if (c == 'r')
    bram_re_socket->b_transport(pl, offset);
  else if (c == 'i')
    bram_im_socket->b_transport(pl, offset);
  // else if (c == 'd') // dbg
  //   {
  //     bram_re_socket->b_transport(pl, offset);
  //     std::cout << "debug re: " << (int)buf[0] << " " << (int)buf[1] << " " << (int)buf[2] << " " << (int) buf[3] << std::endl;
  //   }
  else
    SC_REPORT_ERROR("Hard Read Bram", "Wrong command.");

  return to_fixed(buf);
}

void Hard::write_bram(int addr, num_t val, char c)
{
  pl_t pl;
  unsigned char buf[4];
  to_uchar(buf,val);
  pl.set_address(addr*4);
  pl.set_data_length(4);
  pl.set_data_ptr(buf);
  pl.set_command( tlm::TLM_WRITE_COMMAND );
  pl.set_response_status ( tlm::TLM_INCOMPLETE_RESPONSE );
  if (c == 'r')
    bram_re_socket->b_transport(pl, offset);
  else if (c == 'i')
    bram_im_socket->b_transport(pl, offset);
  else
    SC_REPORT_ERROR("Hard Write Bram", "Wrong command.");
}
