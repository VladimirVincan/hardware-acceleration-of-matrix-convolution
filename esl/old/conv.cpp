#include "conv.hpp"

SC_HAS_PROCESS(convolution);

convolution::convolution(sc_module_name name)
  :	sc_module(name)
  , start(false)
  , state(idle)
{
  SC_THREAD(convolve);
}

void convolution::convolve()
{
  while(1)
    {

      switch (state)
        {
        case idle:
          start = start_in->read();
          if (start)
            {
              state = begin_conv;
              width = width_in->read();
              height = height_in->read();
              cout << "width = " << width << endl;
              cout << "height = " << height << endl;
            }
          break;

        case begin_conv:
          start = start_in->read();
          if (!start) state = calc_log;
          break;

        case calc_log:
          state = fft2_a_start;
          log2w = (int) log2((double)width);
          log2h = (int) log2((double)height);
          // cout << "log2w = " << log2w << endl;
          // cout << "log2h = " << log2h << endl;
          break;

        case fft2_a_start:
          ready_fft2 = ready_fft2->read();
          if (ready_fft2)
            {
              state = fft2_a_ready0;
              start_fft2.write(true);
              width_fft2.write(width);
              height_fft2.write(height);
              log2w_fft2.write(log2w);
              log2h_fft2.write(log2h);
            }
          break;

        case fft2_a_ready0:
          if (!ready_fft2->read())
            {
              state = fft2_a_memory;
            }
          break;

        case fft2_a_memory:
          if (data_rd_i->read())
            {
              // offset = SC_ZERO_TIME;
              // cmd = TLM_READ_COMMAND;
              // addr = data_o_addr_i->read();

              // pl.set_command         ( cmd                     );
              // pl.set_address         ( addr                    );
              // pl.set_data_ptr        ( buf                     );
              // pl.set_data_length     ( CHARS_AMOUNT            );
              // pl.set_response_status ( TLM_INCOMPLETE_RESPONSE );
              // isoc_a->b_transport(pl, offset);

              dataRE_o->write(123.0);
              dataIM_o->write(456.0);
              data_rd_o->write(true);
            }
          else if (data_wr_i->read())
            {
              // offset = SC_ZERO_TIME;
              // cmd = TLM_WRITE_COMMAND;
              // addr = data_i_addr_i->read();

              // pl.set_command         ( cmd                     );
              // pl.set_address         ( addr                    );
              // pl.set_data_ptr        ( buf                     );
              // pl.set_data_length     ( CHARS_AMOUNT            );
              // pl.set_response_status ( TLM_INCOMPLETE_RESPONSE );
              // isoc_a->b_transport(pl, offset);

              dataRE_i->read(123.0);
              dataIM_i->read(456.0);
              data_wr_o->write(true);
            }
          break;
        }

      string msg = "state = " + to_string(state);
      SC_REPORT_INFO("convolution", msg.c_str()) ;
      wait(sc_time(1,SC_NS));
      // cout << "start = " << start << endl;
      // cout << "width = " << width << endl;
      // cout << "height = " << height << endl;
    }
}
