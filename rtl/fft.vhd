library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.utils_pkg.all;

entity fft is
    Generic ( 
           FFT_SIZE : positive := 16;
           FIXED_POINT_WIDTH : positive := 16;
           WIDTH : positive := 32
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           data_i_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           dataRE_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           dataIM_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           data_rd_o : out STD_LOGIC;
           
           data_o_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           dataRE_o : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           dataIM_o : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           data_wr_o : out STD_LOGIC;
           
           log2s : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
           size : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end fft;

architecture Behavioral of fft is

    signal i_r, i_n : unsigned(log2c(log2c(FFT_SIZE))-1 downto 0);
    signal j_r, j_n : unsigned(log2c(FFT_SIZE)-1 downto 0);
    signal k_r, k_n : unsigned(log2c(FFT_SIZE)-1 downto 0);
    signal m2_r, m2_n : unsigned(log2c(FFT_SIZE)-1 downto 0);
    signal m_r, m_n : unsigned(log2c(FFT_SIZE) downto 0);

    signal topRE_i_r, topRE_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_i_r, topIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);  
    signal botRE_i_r, botRE_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal botIM_i_r, botIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
 
    signal topRE_o_r, topRE_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_o_r, topIM_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);      
    signal botRE_o_r, botRE_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal botIM_o_r, botIM_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    
    type state_t is (init, idle, bit_reversal, l1, l2, l3, l4, l5);
    signal state_r, state_n : state_t;
    
    signal butterfly_start_r, butterfly_start_n : STD_LOGIC := '0';
    signal butterfly_ready : STD_LOGIC;
begin

    butterfly : entity work.butterfly
        generic map(
            FFT_SIZE => FFT_SIZE,
            FIXED_POINT_WIDTH => FIXED_POINT_WIDTH,
            WIDTH => WIDTH)
        port map(
            clk => clk, 
            rst => rst,
            
            topRE_i => topRE_i_r,
            topIM_i => topIM_i_r,
            bottomRE_i => botRE_i_r,
            bottomIM_i => botIM_i_r,
            
            topRE_o => topRE_o_n,
            topIM_o => topIM_o_n,
            bottomRE_o => botRE_o_n,
            bottomIM_o => botIM_o_n,
            
            k => k_r,
            size => size,
            
            start => butterfly_start_r,
            ready => butterfly_ready);

    -- State and Data Registers
    process (rst, clk) begin
        if rst = '1' then 
            state_r <= init;
            butterfly_start_r <= '0';
            
            i_r <= (others => '0');
            j_r <= (others => '0');
            k_r <= (others => '0');
            m2_r <= (others => '0');
            m_r <= (others => '0');
            
            topRE_i_r <= (others => '0');
            topIM_i_r <= (others => '0');
            botRE_i_r <= (others => '0');
            botIM_i_r <= (others => '0');
            
            topRE_o_r <= (others => '0');
            topIM_o_r <= (others => '0');
            botRE_o_r <= (others => '0');
            botIM_o_r <= (others => '0');
                        
        elsif (clk'event and clk = '1') then
            state_r <= state_n;
            butterfly_start_r <= butterfly_start_n;
            
            i_r <= i_n;
            j_r <= i_n;
            k_r <= i_n;
            m2_r <= i_n;
            m_r <= i_n;
            
            topRE_i_r <= topRE_i_n;
            topIM_i_r <= topIM_i_n;
            botRE_i_r <= botRE_i_n;
            botIM_i_r <= botIM_i_n;
            
            topRE_o_r <= topRE_o_n;
            topIM_o_r <= topIM_o_n;
            botRE_o_r <= botRE_o_n;
            botIM_o_r <= botIM_o_n;
        end if;
     end process;
        
   -- Combinatorial Circuits
   process (state_r, start) begin
       -- Default Assignments
       state_n <= state_r;
       i_n <= i_r;
       j_n <= j_r;
       k_n <= k_r;
       m2_n <= m2_r;
       m_n <= m_r;

       case state_r is 
           when init => 
                state_n <= idle;
                
                topRE_i_r <= (others => '0');
                topIM_i_r <= (others => '0');
                botRE_i_r <= (others => '0');
                botIM_i_r <= (others => '0');
            
                topRE_o_r <= (others => '0');
                topIM_o_r <= (others => '0');
                botRE_o_r <= (others => '0');
                botIM_o_r <= (others => '0');
           
                ready <= '0';   
                butterfly_start <= '0';
           when idle => 
               ready <= '1';
               if (start = '1') then
                   state_n <= bit_reversal;
               end if;
           when bit_reversal =>
               
          end case;
   end process;
end Behavioral;