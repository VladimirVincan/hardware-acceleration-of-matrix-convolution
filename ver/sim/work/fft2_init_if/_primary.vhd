library verilog;
use verilog.vl_types.all;
entity fft2_init_if is
    generic(
        FFT_SIZE        : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FFT_SIZE : constant is 1;
end fft2_init_if;
