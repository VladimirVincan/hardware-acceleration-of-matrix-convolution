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
           data_rd_i : in STD_LOGIC;

           data_o_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           dataRE_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           dataIM_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           data_wr_o : out STD_LOGIC;
           data_wr_i : in STD_LOGIC;
           
           log2s : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
           size : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end fft;

architecture Behavioral of fft is
-- INNER SIGNALS & STATES
    type state_t is (idle,
                     bit_reversal, l1, l2, reverse, wait_data_rd_i_1, rd, 
                     main, l3, l4, set_rd_addr, l5, wait_butterfly_ready_0, wait_butterfly_ready_1, do_butterfly, -- set_wr_addr, 
                     wait_data_wr_i_0, wait_data_wr_i_1 );
    signal state_r, state_n : state_t;

    signal i_r, i_n : STD_LOGIC_VECTOR(log2c(log2c(FFT_SIZE))-1 downto 0);
    signal j_r, j_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    signal k_r, k_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    signal k_max_n, k_max_r : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    
    signal reversed_r, reversed_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal temp_r, temp_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal m2_r, m2_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    signal m_r, m_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0);
    
--    signal addr_r, addr_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
--    signal dataRE_r, dataRE_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--    signal dataIM_r, dataIM_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--    signal wr_r, wr_n : STD_LOGIC;
--    signal rd_r, rd_n : STD_LOGIC;

    signal addr_top, addr_bot : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal dataRE_top_i, dataRE_bot_i, dataIM_top_i, dataIM_bot_i : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal dataRE_top_o, dataRE_bot_o, dataIM_top_o, dataIM_bot_o : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal wr_top_s, wr_bot_s, rd_s : STD_LOGIC;
   
-- FFT MEMORY
    subtype rom_word_t is std_logic_vector (WIDTH-1 downto 0);
    type rom_t is array (0 to FFT_SIZE-1) of rom_word_t;
    signal dataRE : rom_t := (others => (others => '0'));
    signal dataIM : rom_t := (others => (others => '0'));

-- BUTTERFLY INTERFACE
    signal butterfly_start_r, butterfly_start_n : STD_LOGIC := '0';
    signal butterfly_ready_r, butterfly_ready_n : STD_LOGIC;
    
    signal topRE_i_r, topRE_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_i_r, topIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);  
    signal botRE_i_r, botRE_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal botIM_i_r, botIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
 
    signal topRE_o_r, topRE_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_o_r, topIM_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);      
    signal botRE_o_r, botRE_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal botIM_o_r, botIM_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    
-- FFT INTERFACE
    signal data_i_addr_o_r, data_i_addr_o_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal dataRE_i_r, dataRE_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal dataIM_i_r, dataIM_i_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal data_rd_o_r, data_rd_o_n : STD_LOGIC;
    signal data_rd_i_r, data_rd_i_n : STD_LOGIC;
    
    signal data_o_addr_o_r, data_o_addr_o_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal dataRE_o_r, dataRE_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal dataIM_o_r, dataIM_o_n : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal data_wr_o_r, data_wr_o_n : STD_LOGIC;
    signal data_wr_i_r, data_wr_i_n : STD_LOGIC;
    
    signal log2s_r, log2s_n : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
    signal size_r, size_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    
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
            
            k => j_r (log2c(FFT_SIZE/2)-1 downto 0),
            size => i_r,
            
            start => butterfly_start_r,
            ready => butterfly_ready_n);

    -- State and Data Registers
    process (rst, clk) begin
        if rst = '1' then 
        -- INNER SIGNALS & STATES
            state_r <= idle;
            
            i_r <= (others => '0');
            j_r <= (others => '0');
            k_r <= (others => '0');
            k_max_r <= (others => '0');
            
            reversed_r <= (others => '0');
            temp_r <= (others => '0');
            m_r <= (others => '0');
            m2_r <= (others => '0');
            
--            addr_r <= (others => '0');
--            dataRE_r <= (others => '0');
--            dataIM_r <= (others => '0');
--            wr_r <= '0';
--            rd_r <= '0';

        -- FFT MEMORY
            dataRE <= (others => (others => '0'));
            dataIM <= (others => (others => '0'));
            
        -- BUTTERFLY INTERFACE
            butterfly_start_r <= '0';
            butterfly_ready_r <= '0';
            
            topRE_i_r <= (others => '0');
            topIM_i_r <= (others => '0');
            botRE_i_r <= (others => '0');
            botIM_i_r <= (others => '0');
            
            topRE_o_r <= (others => '0');
            topIM_o_r <= (others => '0');
            botRE_o_r <= (others => '0');
            botIM_o_r <= (others => '0');
            
        -- FFT INTERFACE
            data_i_addr_o_r <= (others => '0');
            dataRE_i_r <= (others => '0');
            dataIM_i_r <= (others => '0');
            data_rd_o_r <= '0';
            data_rd_i_r <= '0';
            
            data_o_addr_o_r <= (others => '0');
            dataRE_o_r <= (others => '0');
            dataIM_o_r <= (others => '0');
            data_wr_o_r <= '0';
            data_wr_i_r <= '0';
            
            log2s_r <= (others => '0');
            size_r <= (others => '0');
                        
        elsif (clk'event and clk = '1') then
        -- INNER SIGNALS
            state_r <= state_n;
                        
            i_r <= i_n;
            j_r <= j_n;
            k_r <= k_n;
            k_max_r <= k_max_n;
            
            reversed_r <= reversed_n;
            temp_r <= temp_n;
            m2_r <= m2_n;
            m_r <= m_n;
            
--            addr_r <= addr_n;
--            dataRE_r <= dataRE_n;
--            dataIM_r <= dataIM_n;
--            wr_r <= wr_n;
--            rd_r <= rd_n;
            
        -- FFT MEMORY
--            dataRE <= dataRE_n;
--            dataIM <= dataIM_n;
            dataRE_top_o <= dataRE(to_integer(unsigned(addr_top)));
            dataIM_top_o <= dataIM(to_integer(unsigned(addr_top)));
            dataRE_bot_o <= dataRE(to_integer(unsigned(addr_bot)));
            dataIM_bot_o <= dataIM(to_integer(unsigned(addr_bot)));
            
            if wr_top_s = '1' then
                   dataRE(to_integer(unsigned(addr_top))) <= dataRE_top_i;
                   dataIM(to_integer(unsigned(addr_top))) <= dataIM_top_i;
            end if;
            if wr_bot_s = '1' then
                   dataRE(to_integer(unsigned(addr_bot))) <= dataRE_bot_i;
                   dataIM(to_integer(unsigned(addr_bot))) <= dataIM_bot_i;
            end if;
        -- BUTTERFLY INTERFACE
            butterfly_start_r <= butterfly_start_n;
            butterfly_ready_r <= butterfly_ready_n;
            
            topRE_i_r <= topRE_i_n;
            topIM_i_r <= topIM_i_n;
            botRE_i_r <= botRE_i_n;
            botIM_i_r <= botIM_i_n;
            
            topRE_o_r <= topRE_o_n;
            topIM_o_r <= topIM_o_n;
            botRE_o_r <= botRE_o_n;
            botIM_o_r <= botIM_o_n;
            
        -- FFT INTERFACE
            data_i_addr_o_r <= data_i_addr_o_n;
            dataRE_i_r <= dataRE_i_n;
            dataIM_i_r <= dataIM_i_n;
            data_rd_o_r <= data_rd_o_n;
            data_rd_i_r <= data_rd_i_n;
            
            data_o_addr_o_r <= data_o_addr_o_n;
            dataRE_o_r <= dataRE_o_n;
            dataIM_o_r <= dataIM_o_n;
            data_wr_o_r <= data_wr_o_n;
            data_wr_i_r <= data_wr_i_n;
            
            log2s_r <= log2s_n;
            size_r <= size_n;
        end if;
     end process;
        
    -- Combinatorial Circuits
    process (state_r, start, butterfly_ready_r, data_rd_i, data_rd_i_r, data_wr_i, data_wr_i_r) begin
    -- Default Assignments
        state_n <= state_r;     
        
    -- FFT OUTPUT INTERFACE (9 signals)     
        ready <= '0';

    -- INNER_SIGNALS
        i_n <= i_r;
        j_n <= j_r;
        k_n <= k_r;
        k_max_n <= k_max_r;
        m2_n <= m2_r;
        m_n <= m_r;
        reversed_n <= reversed_r;
        temp_n <= temp_r;
        
        rd_s <= '0';
        wr_top_s <= '0';
        wr_bot_s <= '0';
        addr_top <= (others => '0');
        addr_bot <= (others => '0');
        dataRE_top_i <= (others => '0');
        dataRE_bot_i <= (others => '0');
        dataIM_top_i <= (others => '0');
        dataIM_bot_i <= (others => '0');
        
--        addr_n <= addr_r;
--        dataRE_n <= dataRE_r;
--        dataIM_n <= dataIM_r;
--        wr_n <= '0';
--        rd_n <= '0';
                
    -- BUTTERFLY OUTPUT INTERFACE (5+2 signals)
        butterfly_start_n <= '0';
        
        topRE_i_n <= topRE_i_r;
        topIM_i_n <= topIM_i_r;
        botRE_i_n <= botRE_i_r;
        botIM_i_n <= botIM_i_r;

    -- FFT INTERFACE
        data_i_addr_o_n <= data_i_addr_o_r;
        dataRE_i_n <= dataRE_i_r;
        dataIM_i_n <= dataIM_i_r;
        data_rd_o_n <= data_rd_o_r;
        data_rd_i_n <= data_rd_i_r;
        
        data_o_addr_o_n <= data_o_addr_o_r;
        dataRE_o_n <= dataRE_o_r;
        dataIM_o_n <= dataIM_o_r;
        data_wr_o_n <= data_wr_o_r;
        data_wr_i_n <= data_wr_i_r;
        
        size_n <= size_r;
        log2s_n <= log2s_r;
        
        case state_r is 
            when idle => 
                ready <= '1';
                
                data_wr_o_n <= '0';
                data_rd_o_n <= '0';
                size_n <= size;
                log2s_n <= log2s;
                
                if (start = '1') then
                    state_n <= bit_reversal;
                else            -- should it be deleted?
                    state_n <= idle;
                end if; 
                
            when bit_reversal =>
                j_n <= (others => '0');
                if start = '0' then
                    state_n <= l1;
                else 
                    state_n <= bit_reversal;
                end if;
                
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
                data_rd_i_n <= data_rd_i;
                if data_rd_i_r = '0' then 
                    k_n <= STD_LOGIC_VECTOR(unsigned(k_r) + 1);
                    if unsigned(k_n) = unsigned(log2s_r) then
--                        data_i_addr_o_n <= reversed_r;
--                        data_rd_o_n <= '1';
                        state_n <= wait_data_rd_i_1;
                    else 
                        state_n <= l2;
                    end if;
                else
                    state_n <= reverse;
                end if;
                
            when wait_data_rd_i_1 =>
                data_rd_i_n <= data_rd_i;
                data_i_addr_o_n <= reversed_r;
                data_rd_o_n <= '1';
                if data_rd_i_r = '1' then
                    state_n <= rd;
                else
                    state_n <= wait_data_rd_i_1;
                end if;
                    
            when rd => 
                data_rd_o_n <= '0';
--                dataRE(to_integer(unsigned(j_r))) <= dataRE_i; 
--                dataIM(to_integer(unsigned(j_r))) <= dataIM_i;
                addr_top <= j_r;
                wr_top_s <= '1';
                dataRE_top_i <= dataRE_i;
                dataIM_top_i <= dataIM_i;
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
                k_max_n <= STD_LOGIC_VECTOR(unsigned(size_r) - unsigned(m2_r) - (unsigned(m2_r) - unsigned(j_r) - 1)); 
                state_n <= set_rd_addr;
                
            when set_rd_addr =>
                addr_top <= k_r;
                addr_bot <= std_logic_vector(unsigned(k_r) + unsigned(m2_r));
                rd_s <= '1';
                state_n <= l5; 
                            
            when l5 =>
--                topRE_i_n <= dataRE(to_integer(unsigned(k_r)));
--                topIM_i_n <= dataIM(to_integer(unsigned(k_r)));
--                botRE_i_n <= dataRE(to_integer(unsigned(k_r) + unsigned(m2_r)));
--                botIM_i_n <= dataIM(to_integer(unsigned(k_r) + unsigned(m2_r)));
                addr_top <= k_r;
                addr_bot <= std_logic_vector(unsigned(k_r) + unsigned(m2_r));
                topRE_i_n <= dataRE_top_o;
                topIM_i_n <= dataIM_top_o;
                botRE_i_n <= dataRE_bot_o;
                botIM_i_n <= dataIM_bot_o;
                if (butterfly_ready_r = '1') then
                    butterfly_start_n <= '1';
                    state_n <= wait_butterfly_ready_0;
                else
                    state_n <= l5;
                end if;  
                
--            when set_wr_addr =>       
--                addr_top <= k_r;
--                addr_bot <= std_logic_vector(unsigned(k_r) + unsigned(m2_r)); 
--                state_n <= wait_butterfly_ready_0;
            
            when wait_butterfly_ready_0 =>
                addr_top <= k_r;
                addr_bot <= std_logic_vector(unsigned(k_r) + unsigned(m2_r));
                if (butterfly_ready_r = '0') then
                    state_n <= wait_butterfly_ready_1;
                else
                    butterfly_start_n <= '1';
                    state_n <= wait_butterfly_ready_0;
                end if;
                
            when wait_butterfly_ready_1 =>
--                dataRE(to_integer(unsigned(k_r))) <= topRE_o_r;
--                dataIM(to_integer(unsigned(k_r))) <= topIM_o_r;
--                dataRE(to_integer(unsigned(k_r) + unsigned(m2_r))) <= botRE_o_r;
--                dataIM(to_integer(unsigned(k_r) + unsigned(m2_r))) <= botIM_o_r;
                addr_top <= k_r;
                addr_bot <= std_logic_vector(unsigned(k_r) + unsigned(m2_r));
                if butterfly_ready_r = '1' then 
                    dataRE_top_i <= topRE_o_r;
                    dataIM_top_i <= topIM_o_r;
                    dataRE_bot_i <= botRE_o_r;
                    dataIM_bot_i <= botIM_o_r;
                    wr_top_s <= '1';
                    wr_bot_s <= '1';
                    state_n <= do_butterfly;
                else
                    state_n <= wait_butterfly_ready_1;
                end if;
            
            when do_butterfly =>
                k_n <= STD_LOGIC_VECTOR(unsigned(k_r) + unsigned(m_r));
                if (k_n = k_max_n) then
                    j_n <= STD_LOGIC_VECTOR(unsigned(j_r) + 1);
                    if (j_n = STD_LOGIC_VECTOR(unsigned(m2_r) - 1)) then
                        i_n <= STD_LOGIC_VECTOR(unsigned(i_r) + 1);
                        if (i_n = log2s_r) then
                             j_n <= (others => '0');
                             state_n <= wait_data_wr_i_0;
                        else 
                            state_n <= l3;
                        end if;
                    else 
                        state_n <= l4;
                    end if;
                else
                    state_n <= set_rd_addr; --l5;
                end if;
                
            when wait_data_wr_i_0 =>
                data_wr_i_n <= data_wr_i;
                data_wr_o_n <= '0';
                addr_top <= j_r;
                rd_s <= '1';
                if data_wr_i_r = '0' then
                    state_n <= wait_data_wr_i_1;
                else
                    state_n <= wait_data_wr_i_0;
                end if;
                               
            when wait_data_wr_i_1 =>
                data_wr_i_n <= data_wr_i;
                data_o_addr_o_n <= j_r;
--                dataRE_o_n <= dataRE(to_integer(unsigned(j_r)));
--                dataIM_o_n <= dataIM(to_integer(unsigned(j_r)));
                addr_top <= j_r;
                rd_s <= '1';
                dataRE_o_n <= dataRE_top_o;
                dataIM_o_n <= dataIM_top_o;
                data_wr_o_n <= '1'; 
                if data_wr_i = '1' then
                    j_n <= STD_LOGIC_VECTOR(unsigned(j_r) + 1);
                    if j_n = size_r then
                        state_n <= idle;
                    else
                        state_n <= wait_data_wr_i_0;
                    end if;
                else
                    state_n <= wait_data_wr_i_1;
                end if;                                 
        end case;
    end process;
    
    -- FFT INTERFACE
    data_i_addr_o <= data_i_addr_o_r;
    -- dataRE_i_n <= dataRE_i;
    -- dataIM_i_n <= dataIM_i;
    data_rd_o <= data_rd_o_r;
    -- data_rd_i_n <= data_rd_i;
    
    data_o_addr_o <= data_o_addr_o_r;
    dataRE_o <= dataRE_o_r;
    dataIM_o <= dataIM_o_r;
    data_wr_o <= data_wr_o_r;
    -- data_wr_i_n <= data_wr_i;
    
    -- size_n <= size;
    -- log2s_n <= log2s;
    
end Behavioral;