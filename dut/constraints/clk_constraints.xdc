create_clock -period 20 -name clk -waveform {0.000 10.000} [get_pins -hierarchical *AXI_FFT2_0/s00_axi_aclk]
