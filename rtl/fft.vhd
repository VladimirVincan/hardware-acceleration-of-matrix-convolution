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
           dataRE_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           dataIM_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           data_wr_o : out STD_LOGIC;
           
           log2s : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
           size : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end fft;

architecture Behavioral of fft is
-- INNER SIGNALS & STATES
    type state_t is (idle, wait_start_0, rd, wr, wr_delay, bit_reversal, reverse, main, butterfly_start_1, wait_butterfly_ready_0, wait_butterfly_ready_1, do_butterfly, l1, l2, l3, l4, l5);
    signal state_r, state_n : state_t;
   
    signal size_r : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal log2s_r : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);

    signal i_r, i_n : STD_LOGIC_VECTOR(log2c(log2c(FFT_SIZE))-1 downto 0);
    signal j_r, j_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    signal k_r, k_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    signal k_max : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    
    signal reversed_r, reversed_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal temp_r, temp_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal m2_r, m2_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    signal m_r, m_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    
-- FFT MEMORY
    subtype rom_word_t is std_logic_vector (WIDTH-1 downto 0);
    type rom_t is array (0 to FFT_SIZE-1) of rom_word_t;
    signal dataRE : rom_t := (others => (others => '0'));
    signal dataIM : rom_t := (others => (others => '0'));

-- BUTTERFLY INTERFACE
    signal butterfly_start_r, butterfly_start_n : STD_LOGIC := '0';
    signal butterfly_ready_r : STD_LOGIC;
    
    signal topRE_i_r, topRE_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_i_r, topIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);  
    signal botRE_i_r, botRE_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal botIM_i_r, botIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
 
    signal topRE_o_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_o_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0);      
    signal botRE_o_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal botIM_o_r : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    
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
            
            topRE_o => topRE_o_r,
            topIM_o => topIM_o_r,
            bottomRE_o => botRE_o_r,
            bottomIM_o => botIM_o_r,
            
            k => j_r (log2c(FFT_SIZE/2)-1 downto 0),
            size => i_r,
            
            start => butterfly_start_r,
            ready => butterfly_ready_r);

    -- State and Data Registers
    process (rst, clk) begin
        if rst = '1' then 
        -- INNER SIGNALS & STATES
            state_r <= idle;
            
            i_r <= (others => '0');
            j_r <= (others => '0');
            k_r <= (others => '0');
            
            reversed_r <= (others => '0');
            temp_r <= (others => '0');
            m_r <= (others => '0');
            m2_r <= (others => '0');

        -- FFT MEMORY
            --dataRE <= (others => (others => '0'));
            --dataIM <= (others => (others => '0'));
            
        -- BUTTERFLY INTERFACE
            butterfly_start_r <= '0';
            
            topRE_i_r <= (others => '0');
            topIM_i_r <= (others => '0');
            botRE_i_r <= (others => '0');
            botIM_i_r <= (others => '0');
                        
        elsif (clk'event and clk = '1') then
        -- INNER SIGNALS
            state_r <= state_n;
                        
            i_r <= i_n;
            j_r <= j_n;
            k_r <= k_n;
            
            reversed_r <= reversed_n;
            temp_r <= temp_n;
            m2_r <= m2_n;
            m_r <= m_n;
            
        -- BUTTERFLY INTERFACE
            butterfly_start_r <= butterfly_start_n;
            
            topRE_i_r <= topRE_i_n;
            topIM_i_r <= topIM_i_n;
            botRE_i_r <= botRE_i_n;
            botIM_i_r <= botIM_i_n;

        end if;
     end process;
        
    -- Combinatorial Circuits
    process (state_r, start, butterfly_ready_r) begin
    -- Default Assignments
        
    -- FFT OUTPUT INTERFACE (7 signals)
        data_i_addr_o <= (others => '0');
        data_rd_o <= '0';
        
        data_o_addr_o <= (others => '0');
        dataRE_o <= (others => '0');
        dataIM_o <= (others => '0');
        data_wr_o <= '0';
        
        ready <= '0';
        
    -- INNER_SIGNALS
        i_n <= i_r;
        j_n <= j_r;
        k_n <= k_r;
        m2_n <= m2_r;
        m_n <= m_r;
        reversed_n <= reversed_r;
        temp_n <= temp_r;
        
    -- BUTTERFLY OUTPUT INTERFACE (5+2 signals)
        butterfly_start_n <= '0';
        
        topRE_i_n <= (others => '0');
        topIM_i_n <= (others => '0');
        botRE_i_n <= (others => '0');
        botIM_i_n <= (others => '0');

        case state_r is 
            when idle => 
                ready <= '1';
                size_r <= size;
                log2s_r <= log2s;
                if (start = '1') then
                    state_n <= wait_start_0;
                end if; 
                
            when wait_start_0 => 
                ready <= '0';
                if start = '0' then
                    state_n <= bit_reversal;
                end if;
                
            when bit_reversal =>
                j_n <= (others => '0');
                state_n <= l1;
                
            when l1 =>
                reversed_n <= (others => '0');
                temp_n <= j_r;
                k_n <= (others => '0');
                state_n <= l2;
                
            when l2 => 
                reversed_n <= STD_LOGIC_VECTOR(shift_left(unsigned(reversed_r),1)) OR (temp_r AND STD_LOGIC_VECTOR(to_unsigned(1, temp_r'length)));
                temp_n <= STD_LOGIC_VECTOR(shift_right(unsigned(temp_r),1));
                state_n <= reverse;
                
            when reverse =>  
                k_n <= STD_LOGIC_VECTOR(unsigned(k_r) + 1);
                if unsigned(k_n) = unsigned(log2s_r) then
                    data_i_addr_o <= reversed_r;
                    data_rd_o <= '1';
                    state_n <= rd;
                else 
                    state_n <= l2;
                end if;
                
            when rd => 
                dataRE(to_integer(unsigned(j_r))) <= dataRE_i; 
                dataIM(to_integer(unsigned(j_r))) <= dataIM_i;
                j_n <= STD_LOGIC_VECTOR(unsigned(j_r) + 1);
                if unsigned(j_n) = unsigned(size_r) then
                    state_n <= main;
                else
                    state_n <= l1;
                end if;
                
            when main =>
                i_n <= (others => '0');
                state_n <= l3;
                
            when l3 =>
                m_n <= STD_LOGIC_VECTOR(shift_left(to_unsigned(1, m_n'length), to_integer(unsigned(i_r))+1)); 
                m2_n <= STD_LOGIC_VECTOR(shift_left(to_unsigned(1, m2_n'length), to_integer(unsigned(i_r))));
                j_n <= (others => '0');
                state_n <= l4;
                
            when l4 =>
                k_n <= j_r;
                k_max <= STD_LOGIC_VECTOR(unsigned(size_r) - unsigned(m2_r) - (unsigned(m2_r) - unsigned(j_r) - 1)); 
                state_n <= l5;
                
            when l5 =>
                topRE_i_n <= dataRE(to_integer(unsigned(k_r)));
                topIM_i_n <= dataIM(to_integer(unsigned(k_r)));
                botRE_i_n <= dataRE(to_integer(unsigned(k_r) + unsigned(m2_r)));
                botIM_i_n <= dataIM(to_integer(unsigned(k_r) + unsigned(m2_r)));
                state_n <= butterfly_start_1;
                
            when butterfly_start_1 =>
                topRE_i_n <= dataRE(to_integer(unsigned(k_r)));
                topIM_i_n <= dataIM(to_integer(unsigned(k_r)));
                botRE_i_n <= dataRE(to_integer(unsigned(k_r) + unsigned(m2_r)));
                botIM_i_n <= dataIM(to_integer(unsigned(k_r) + unsigned(m2_r)));
                if (butterfly_ready_r = '1') then
                    butterfly_start_n <= '1';
                    state_n <= wait_butterfly_ready_0;
                else
                    state_n <= l5;
                end if;               
            
            when wait_butterfly_ready_0 =>
                topRE_i_n <= dataRE(to_integer(unsigned(k_r)));
                topIM_i_n <= dataIM(to_integer(unsigned(k_r)));
                botRE_i_n <= dataRE(to_integer(unsigned(k_r) + unsigned(m2_r)));
                botIM_i_n <= dataIM(to_integer(unsigned(k_r) + unsigned(m2_r)));
                if (butterfly_ready_r = '0') then
                    state_n <= wait_butterfly_ready_1;
                else
                    butterfly_start_n <= '1';
                    state_n <= wait_butterfly_ready_0;
                end if;
                
            when wait_butterfly_ready_1 =>
                topRE_i_n <= dataRE(to_integer(unsigned(k_r)));
                topIM_i_n <= dataIM(to_integer(unsigned(k_r)));
                botRE_i_n <= dataRE(to_integer(unsigned(k_r) + unsigned(m2_r)));
                botIM_i_n <= dataIM(to_integer(unsigned(k_r) + unsigned(m2_r)));
                if butterfly_ready_r = '1' then 
                    state_n <= do_butterfly;
                else
                    state_n <= wait_butterfly_ready_1;
                end if;
            
            when do_butterfly =>
                dataRE(to_integer(unsigned(k_r))) <= topRE_o_r;
                dataIM(to_integer(unsigned(k_r))) <= topIM_o_r;
                dataRE(to_integer(unsigned(k_r) + unsigned(m2_r))) <= botRE_o_r;
                dataIM(to_integer(unsigned(k_r) + unsigned(m2_r))) <= botIM_o_r;
                k_n <= STD_LOGIC_VECTOR(unsigned(k_r) + unsigned(m_r));
                if (k_n = k_max) then
                    j_n <= STD_LOGIC_VECTOR(unsigned(j_r) + 1);
                    if (j_n = STD_LOGIC_VECTOR(unsigned(m2_r) - 1)) then
                        i_n <= STD_LOGIC_VECTOR(unsigned(i_r) + 1);
                        if (i_n = log2s_r) then
                             j_n <= (others => '0');
                             state_n <= wr;
                        else 
                            state_n <= l3;
                        end if;
                    else 
                        state_n <= l4;
                    end if;
                else
                    state_n <= l5;
                end if;
                               
            when wr =>
                j_n <= STD_LOGIC_VECTOR(unsigned(j_r) + 1);
                data_o_addr_o <= j_r;
                dataRE_o <= dataRE(to_integer(unsigned(j_r)));
                dataIM_o <= dataIM(to_integer(unsigned(j_r)));
                data_wr_o <= '1';    
                if j_n = size_r then
                    state_n <= idle;
                else
                    state_n <= wr_delay;
                end if;
                
            when wr_delay =>
                state_n <= wr;
                
        end case;
    end process;
end Behavioral;