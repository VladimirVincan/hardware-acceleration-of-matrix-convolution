library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;
use work.utils_pkg.all;

entity fft2 is
    Generic ( 
           FFT_SIZE : positive := 16; -- max matrix size
           FIXED_POINT_WIDTH : positive := 16;
           DATA_WIDTH : positive := 32 -- the same as matrix width, so it was renamed
    );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           
           data_i_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
           dataRE_i : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           dataIM_i : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           data_rd_o : out STD_LOGIC;
           data_rd_i : in STD_LOGIC;

           data_o_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
           dataRE_o : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           dataIM_o : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
           data_wr_o : out STD_LOGIC;
           data_wr_i : in STD_LOGIC;
           
           log2w : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
           width : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
           log2h : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
           height : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
           start : in STD_LOGIC;
           ready : out STD_LOGIC);
end fft2;

architecture Behavioral of fft2 is
-- INNER SIGNALS & STATES
    type state_t is 
       (idle, l1, l2, wait_start_0,
        vertical_start, wait_vertical_ready, vertical_update,
        horizontal_start, wait_horizontal_ready, horizontal_update);
    signal state_r, state_n : state_t;

    signal i_r, i_n : STD_LOGIC := '0';
    signal j_r, j_n : STD_LOGIC_VECTOR(log2c(FFT_SIZE)-1 downto 0) := (others => '0');
    
    signal log2w_r, log2w_n : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
    signal width_r, width_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);    
    
    signal log2h_r, log2h_n : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
    signal height_r, height_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);

-- FFT INTERFACE
    signal fft_data_i_addr_o_r : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal fft_data_o_addr_o_r : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);

    signal log2s_r, log2s_n : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
    signal size_r, size_n : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    
    signal fft_data_rd_o_r : STD_LOGIC;
    signal fft_data_wr_o_r : STD_LOGIC;
    
    signal fft_start_r, fft_start_n : STD_LOGIC := '0';
    signal fft_ready_r : STD_LOGIC;
    
begin

    fft : entity work.fft
        generic map(
            FFT_SIZE => FFT_SIZE,
            FIXED_POINT_WIDTH => FIXED_POINT_WIDTH,
            WIDTH => DATA_WIDTH)
        port map(
            clk => clk, 
            rst => rst,
            
           data_i_addr_o => fft_data_i_addr_o_r,
           dataRE_i => dataRE_i,
           dataIM_i => dataIM_i,
           data_rd_o => fft_data_rd_o_r,
           data_rd_i => data_rd_i,
            
           data_o_addr_o => fft_data_o_addr_o_r,
           dataRE_o => dataRE_o,
           dataIM_o => dataIM_o,
           data_wr_o => fft_data_wr_o_r,
           data_wr_i => data_wr_i,
           
           log2s => log2s_r,
           size => size_r,
            
           start => fft_start_r,
           ready => fft_ready_r);
           
    -- State and Data Registers
    process (rst, clk) begin
        
        if rst = '1' then 
        -- INNER SIGNALS & STATES
            state_r <= idle;
            
            i_r <= '0';
            j_r <= (others => '0');
            
            log2w_r <= (others => '0');
            width_r <= (others => '0');
            
            log2h_r <= (others => '0');
            height_r <= (others => '0');
            
        -- FFT INTERFACE
            fft_start_r <= '0';
            
            log2s_r <= (others => '0');
            size_r <= (others => '0');
            
            -- fft_data_i_addr_o_r <= (others => '0');
            -- fft_data_o_addr_o_r <= (others => '0');
                           
        elsif (clk'event and clk = '1') then
        -- INNER SIGNALS
            state_r <= state_n;
                                    
            i_r <= i_n;
            j_r <= j_n;
            
            log2w_r <= log2w_n;
            width_r <= width_n;
            
            log2h_r <= log2h_n;
            height_r <= height_n;
            
        -- FFT INTERFACE
            fft_start_r <= fft_start_n;
            
            log2s_r <= log2s_n;
            size_r <= size_n;

        end if;
     end process;
     
     -- Combinatorial Circuits
    process (state_r, start, fft_ready_r, fft_data_rd_o_r, fft_data_wr_o_r) begin
    -- Default Assignments
        state_n <= state_r;

    -- FFT2 OUTPUT INTERFACE (3 + 4 signals)
        data_i_addr_o <= (others => '0');
        data_o_addr_o <= (others => '0'); 
        data_rd_o <= '0';
        data_wr_o <= '0';
        -- fft_data_wr_o_r <= '0';
        -- fft_data_rd_o_r <= '0';       
        ready <= '0';
        
    -- INNER_SIGNALS
        i_n <= i_r;
        j_n <= j_r;
        
        log2w_n <= log2w_r;
        width_n <= width_r;
        
        log2h_n<= log2h_r;
        height_n <= height_r;
        
    -- FFT OUTPUT INTERFACE (5+2 signals)
        fft_start_n <= '0';
        log2s_n <= (others => '0');
        size_n <= (others => '0');

        case state_r is 
            when idle => 
                ready <= '1';
                
                log2w_n <= log2w;
                width_n <= width;
                log2h_n <= log2h;
                height_n <= height;
                
                if (start = '1') then
                    state_n <= wait_start_0;
                end if; 
                
            when wait_start_0 => 
                i_n <= '0';
                if start = '0' then
                    state_n <= l1;
                else
                    state_n <= wait_start_0;
                end if;
                
            when l1 =>
                j_n <= (others => '0');
                state_n <= l2;
                
            when l2 =>
                if fft_ready_r = '1' then
                    if (i_r = '0') then
                        state_n <= horizontal_start;
                    else
                        state_n <= vertical_start;
                    end if;
                else
                    state_n <= l2;
                end if;
                
            when horizontal_start =>
                fft_start_n <= '1';
                log2s_n <= log2w_r;
                size_n <= width_r;
                if fft_ready_r = '0' then
                    state_n <= wait_horizontal_ready;
                else
                    state_n <= horizontal_start;
                end if;
            
            when wait_horizontal_ready =>
                data_rd_o <= fft_data_rd_o_r;
                data_wr_o <= fft_data_wr_o_r;
                data_i_addr_o <= std_logic_vector(unsigned(j_r) * unsigned(width_r) + unsigned(j_r) + unsigned(fft_data_i_addr_o_r));
                data_o_addr_o <= std_logic_vector(unsigned(j_r) * unsigned(width_r) + unsigned(j_r) + unsigned(fft_data_o_addr_o_r));
                
                if fft_ready_r = '1' then
                    state_n <= horizontal_update;
                else 
                    state_n <= wait_horizontal_ready;
                end if;
            
            when horizontal_update =>
                if j_n = width_r then
                    i_n <= '1';
                    j_n <= (others => '0');
                    state_n <= l1;
                else 
                    j_n <= std_logic_vector(unsigned(j_r) + 1);
                    state_n <= l2;
                end if;

            when vertical_start =>
                fft_start_n <= '1';
                log2s_n <= log2h_r;
                size_n <= height_r;
                if fft_ready_r = '0' then
                    state_n <= wait_vertical_ready;
                else
                    state_n <= vertical_start;
                end if;
            
            when wait_vertical_ready => 
                data_rd_o <= fft_data_rd_o_r;
                data_wr_o <= fft_data_wr_o_r;
                data_i_addr_o <= std_logic_vector(unsigned(fft_data_i_addr_o_r) * unsigned(width_r) + unsigned(fft_data_i_addr_o_r) + unsigned(j_r));
                data_o_addr_o <= std_logic_vector(unsigned(fft_data_o_addr_o_r) * unsigned(width_r) + unsigned(fft_data_o_addr_o_r) + unsigned(j_r));
                
                if fft_ready_r = '1' then
                    state_n <= vertical_update;
                else 
                    state_n <= wait_vertical_ready;
                end if;
            
            when vertical_update =>
                if j_n = height_r then
                    i_n <= '0';
                    j_n <= (others => '0');
                    state_n <= idle;
                else 
                    j_n <= std_logic_vector(unsigned(j_r) + 1);
                    state_n <= l2;
                end if;

        end case;

    end process;

end Behavioral;
