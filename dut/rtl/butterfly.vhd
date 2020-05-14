library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.utils_pkg.all;

entity butterfly is
    Generic (
           FFT_SIZE : positive := 16;
           FIXED_POINT_WIDTH : positive := 16;
           WIDTH : positive := 32
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;

           topRE_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           topIM_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           bottomRE_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           bottomIM_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);

           topRE_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           topIM_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           bottomRE_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           bottomIM_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);

           k : in STD_LOGIC_VECTOR (log2c(FFT_SIZE/2)-1 downto 0);        -- added log2c
           size : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);-- added log2c

           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end butterfly;

architecture Behavioral of butterfly is

    subtype rom_word_t is std_logic_vector (WIDTH-1 downto 0);
    type rom_t is array (0 to FFT_SIZE/2-1, 0 to log2c(FFT_SIZE)-1) of rom_word_t;

    function init_twiddle_real return rom_t is
        variable rom : rom_t;
        variable theta : real;
    begin
        for i in 0 to log2c(FFT_SIZE) - 1 loop
            for j in 0 to FFT_SIZE/2 - 1 loop
                theta := MATH_2_PI * real(j) / real(2**(i+1));
                rom(j, i) := std_logic_vector(to_signed(integer(cos(theta)*real(2**FIXED_POINT_WIDTH)),WIDTH));
            end loop;
        end loop;
        return rom;
    end function;

    function init_twiddle_imag return rom_t is
        variable rom : rom_t;
        variable theta : real;
    begin
        for i in 0 to log2c(FFT_SIZE) - 1 loop
            for j in 0 to FFT_SIZE/2 - 1 loop
                theta := MATH_2_PI * real(j) / real(2**(i+1));
                rom(j, i) := std_logic_vector(to_signed(integer(-sin(theta)*real(2**FIXED_POINT_WIDTH)),WIDTH));
            end loop;
        end loop;
        return rom;
    end function;

    signal wCOS : rom_t := init_twiddle_real;
    signal wSIN : rom_t := init_twiddle_imag;

    signal sumRE_r, sumRE_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => '0');
    signal sumIM_r, sumIM_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => '0');

    signal mult1_r, mult2_r, mult3_r, mult4_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal mult1_n, mult2_n, mult3_n, mult4_n : STD_LOGIC_VECTOR (2*WIDTH-1 downto 0);

    signal topRE_o_n, topIM_o_n, bottomRE_o_n, bottomIM_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => '0');
    signal topRE_o_r, topIM_o_r, bottomRE_o_r, bottomIM_o_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => '0');

    signal topRE_i_n, topIM_i_n, bottomRE_i_n, bottomIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => '0');
    signal topRE_i_r, topIM_i_r, bottomRE_i_r, bottomIM_i_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0) := (others => '0');

--    signal k_r, k_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE/2)-1 downto 0) := (others => '0');
--    signal size_r, size_n : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0) := (others => '0');

    type state_t is (idle, state1, state2, state3);
    signal state_r, state_n : state_t;

begin
    -- State and Data Registers
    process (rst, clk) begin
        if (clk'event and clk = '1') then
            if rst = '1' then
                state_r <= idle;
                mult1_r <= (others => '0');
                mult2_r <= (others => '0');
                mult3_r <= (others => '0');
                mult4_r <= (others => '0');
                sumRE_r <= (others => '0');
                sumIM_r <= (others => '0');

                topRE_i_r <= (others => '0');
                topIM_i_r <= (others => '0');
                bottomRE_i_r <= (others => '0');
                bottomIM_i_r <= (others => '0');

                topRE_o_r <= (others => '0');
                topIM_o_r <= (others => '0');
                bottomRE_o_r <= (others => '0');
                bottomIM_o_r <= (others => '0');

--                k_r <= (others => '0');
--                size_r <= (others => '0');
            else
                state_r <= state_n;
                mult1_r <= mult1_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
                mult2_r <= mult2_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
                mult3_r <= mult3_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
                mult4_r <= mult4_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
                sumRE_r <= sumRE_n;
                sumIM_r <= sumIM_n;

                topRE_i_r <= topRE_i_n;
                topIM_i_r <= topIM_i_n;
                bottomRE_i_r <= bottomRE_i_n;
                bottomIM_i_r <= bottomIM_i_n;

                topRE_o_r <= topRE_o_n;
                topIM_o_r <= topIM_o_n;
                bottomRE_o_r <= bottomRE_o_n;
                bottomIM_o_r <= bottomIM_o_n;

--                k_r <= k_n;
--                size_r <= size_n;
            end if;
        end if;
     end process;

   -- Combinatorial Circuits
   process (
    state_r, start,
    topRE_i, topIM_i, bottomRE_i, bottomIM_i, k, size,
    topRE_o_r, topIM_o_r, bottomRE_o_r, bottomIM_o_r,
    topRE_i_r, topIM_i_r, bottomRE_i_r, bottomIM_i_r,
--    k_r, size_r,
    mult1_r, mult2_r, mult3_r, mult4_r,
    sumRE_r, sumIM_r,
    wCOS, wSIN
    ) begin
       -- Default Assignments
       state_n <= idle;
       mult1_n <= (others => '0');
       mult2_n <= (others => '0');
       mult3_n <= (others => '0');
       mult4_n <= (others => '0');
       ready <= '0';

       sumRE_n <= sumRE_r;
       sumIM_n <= sumIM_r;

       topRE_i_n <= topRE_i_r;
       topIM_i_n <= topIM_i_r;
       bottomRE_i_n <= bottomRE_i_r;
       bottomIM_i_n <= bottomIM_i_r;

       topRE_o_n <= topRE_o_r;
       topIM_o_n <= topIM_o_r;
       bottomRE_o_n <= bottomRE_o_r;
       bottomIM_o_n <= bottomIM_o_r;

--       k_n <= k_r;
--       size_n <= size_r;

       case state_r is
           when idle =>
               ready <= '1';

               topRE_i_n <= topRE_i;
               topIM_i_n <= topIM_i;
               bottomRE_i_n <= bottomRE_i;
               bottomIM_i_n <= bottomIM_i;
--               k_n <= k;
--               size_n <= size;

               if (start = '1') then
                   state_n <= state1;
               end if;
           when state1 =>
               ready <= '0';
               if (start = '0') then
                   mult1_n <= std_logic_vector(signed(bottomRE_i_r)
                                             * signed(wCOS(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   mult2_n <= std_logic_vector(signed(bottomIM_i_r)
                                             * signed(wSIN(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   mult3_n <= std_logic_vector(signed(bottomRE_i_r)
                                             * signed(wSIN(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   mult4_n <= std_logic_vector(signed(bottomIM_i_r)
                                             * signed(wCOS(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   state_n <= state2;
               else
                   state_n <= state1;
               end if;
           when state2 =>
               sumRE_n <= std_logic_vector(signed(mult1_r) - signed(mult2_r));
               sumIM_n <= std_logic_vector(signed(mult3_r) + signed(mult4_r));
               state_n <= state3;
           when state3 =>
               topRE_o_n <= std_logic_vector(signed(topRE_i_r) + signed(sumRE_r));
               topIM_o_n <= std_logic_vector(signed(topIM_i_r) + signed(sumIM_r));
               bottomRE_o_n <= std_logic_vector(signed(topRE_i_r) - signed(sumRE_r));
               bottomIM_o_n <= std_logic_vector(signed(topIM_i_r) - signed(sumIM_r));
               state_n <= idle;
         end case;
   end process;

   topRE_o <= topRE_o_r;
   topIM_o <= topIM_o_r;
   bottomRE_o <= bottomRE_o_r;
   bottomIM_o <= bottomIM_o_r;

end Behavioral;
