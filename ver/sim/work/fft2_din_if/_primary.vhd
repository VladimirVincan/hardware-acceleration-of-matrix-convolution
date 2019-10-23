library verilog;
use verilog.vl_types.all;
entity fft2_din_if is
    generic(
        DATA_WIDTH      : integer := 32;
        FFT_SIZE        : integer := 16
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FFT_SIZE : constant is 1;
end fft2_din_if;
