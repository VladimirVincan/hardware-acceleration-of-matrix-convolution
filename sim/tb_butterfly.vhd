library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.utils_pkg.all;

entity tb_butterfly is
    Generic ( 
           FFT_SIZE : positive := 8;
           FIXED_POINT_WIDTH : positive := 16;
           WIDTH : positive := 32
    );
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
           
--           topRE_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           topIM_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           bottomRE_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           bottomIM_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           
--           topRE_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           topIM_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           bottomRE_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           bottomIM_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           
--           k : in STD_LOGIC_VECTOR (log2c(FFT_SIZE/2)-1 downto 0);
--           size : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
--           start : in STD_LOGIC;
--           ready : out STD_LOGIC);
end tb_butterfly;

architecture Behavioral of tb_butterfly is
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
           
    signal topRE_i : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_i : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal bottomRE_i : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal bottomIM_i : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           
    signal topRE_o : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal topIM_o : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal bottomRE_o : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal bottomIM_o : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
           
    signal k : STD_LOGIC_VECTOR (FFT_SIZE/2-1 downto 0);
    signal size : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
    signal start : STD_LOGIC;
    signal ready : STD_LOGIC;
begin
    uut : entity work.butterfly
        generic map(
            FFT_SIZE => FFT_SIZE,
            FIXED_POINT_WIDTH => FIXED_POINT_WIDTH,
            WIDTH => WIDTH)
        port map(
            clk => clk, 
            rst => rst,
            
            topRE_i => topRE_i,
            topIM_i => topIM_i,
            bottomRE_i => bottomRE_i,
            bottomIM_i => bottomIM_i,
            
            topRE_o => topRE_o,
            topIM_o => topIM_o,
            bottomRE_o => bottomRE_o,
            bottomIM_o => bottomIM_o,
            
            k => k,
            size => size,
            
            start => start,
            ready => ready);
        
    clk_process: process begin
        clk <= '1';
        wait for 50ns;
        clk <= '0';
        wait for 50ns;
    end process;    
    
    stim_proc: process begin
        rst <= '1';
        wait for 100ns;
        rst <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 1 0 0 0 x x => 1 0 1 0
        topRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(0), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 200ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 1 0 0 0 x x => 1 0 1 0
        topRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(2), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 200ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 1 0 0 0 x x => 1 0 1 0
        topRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(3), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 200ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 1 0 1 0 0 8 => 2 0 0 0
        topRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(0), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 100ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 1 0 1 0 1 8 => 1.707 0.707 0.292 -0.707
        topRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(1), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 100ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 0 1 0 1 1 8 => -0.707 1.707 0.707 0.292
        topRE_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(1), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 100ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 1 1 0 0 x x => 1 1 1 1
        topRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(0) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(0), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 100ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        
        -- 1 1 1 1 0 8 => 1 1 1 1
        topRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        topIM_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomRE_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        bottomIM_i <= std_logic_vector(to_signed(integer( real(1) * real(2**FIXED_POINT_WIDTH)),WIDTH));
        k <= std_logic_vector(to_unsigned(natural(0), FFT_SIZE/2));
        size <= std_logic_vector(to_unsigned(natural(2), log2c(FFT_SIZE)));
        start <= '1';
        if ready /= '0' then
            wait until ready = '0';
        end if;
        wait for 100ns;
        start <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;
        wait;
        
    end process;

end Behavioral;
