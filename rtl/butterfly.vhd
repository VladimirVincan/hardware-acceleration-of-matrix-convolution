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
    
    signal botRE_r, botRE_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal botIM_r, botIM_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    
    signal mult1_r, mult2_r, mult3_r, mult4_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal mult1_n, mult2_n, mult3_n, mult4_n : STD_LOGIC_VECTOR (2*WIDTH-1 downto 0);
    
    type state_t is (init, idle, state1, state2, state3);
    signal state_r, state_n : state_t;
    
begin
    -- State and Data Registers
    process (rst, clk) begin
        if rst = '1' then 
            state_r <= init;
            mult1_r <= (others => '0');
            mult2_r <= (others => '0');
            mult3_r <= (others => '0');
            mult4_r <= (others => '0');
            botRE_r <= (others => '0');
            botIM_r <= (others => '0');
            
        elsif (clk'event and clk = '1') then
            state_r <= state_n;
            mult1_r <= mult1_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
            mult2_r <= mult2_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
            mult3_r <= mult3_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
            mult4_r <= mult4_n (WIDTH + FIXED_POINT_WIDTH - 1 downto WIDTH - FIXED_POINT_WIDTH);
            botRE_r <= botRE_n;
            botIM_r <= botIM_n;
        end if;
     end process;
        
   -- Combinatorial Circuits
   process (state_r, start) begin
       -- Default Assignments
       state_n <= state_r;
       botRE_n <= botRE_r;
       botIM_n <= botIM_r;
       
       state_n <= idle;
       mult1_n <= (others => '0');
       mult2_n <= (others => '0');
       mult3_n <= (others => '0');
       mult4_n <= (others => '0');
        
       topRE_o <= (others => '0');
       topIM_o <= (others => '0');
       bottomRE_o <= (others => '0');
       bottomIM_o <= (others => '0');
       ready <= '0';  

       case state_r is 
           when init => 
                state_n <= idle;
                mult1_n <= (others => '0');
                mult2_n <= (others => '0');
                mult3_n <= (others => '0');
                mult4_n <= (others => '0');
       
                topRE_o <= (others => '0');
                topIM_o <= (others => '0');
                bottomRE_o <= (others => '0');
                bottomIM_o <= (others => '0');
                ready <= '0';   
           when idle => 
               ready <= '1';
               if (start = '1') then
                   state_n <= state1;
               end if;
           when state1 => 
               ready <= '0';
               if (start = '0') then
                   mult1_n <= std_logic_vector(signed(bottomRE_i) 
                                             * signed(wCOS(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   mult2_n <= std_logic_vector(signed(bottomIM_i) 
                                             * signed(wSIN(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   mult3_n <= std_logic_vector(signed(bottomRE_i) 
                                             * signed(wSIN(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   mult4_n <= std_logic_vector(signed(bottomIM_i) 
                                             * signed(wCOS(to_integer(unsigned(k)),to_integer(unsigned(size)))));
                   state_n <= state2;
               end if;
           when state2 =>
               botRE_n <= std_logic_vector(signed(mult1_r) - signed(mult2_r));
               botIM_n <= std_logic_vector(signed(mult3_r) + signed(mult4_r));
               state_n <= state3;
           when state3 =>
               topRE_o <= std_logic_vector(signed(topRE_i) + signed(botRE_r));
               topIM_o <= std_logic_vector(signed(topIM_i) + signed(botIM_r));
               bottomRE_o <= std_logic_vector(signed(topRE_i) - signed(botRE_r));
               bottomIM_o <= std_logic_vector(signed(topIM_i) - signed(botIM_r));
               state_n <= idle;
         end case;
   end process;
end Behavioral;