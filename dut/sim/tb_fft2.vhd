library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
use work.utils_pkg.all;

entity tb_fft2 is
    Generic ( 
           FFT_SIZE : positive := 4; -- max matrix size
           FIXED_POINT_WIDTH : positive := 16;
           DATA_WIDTH : positive := 32 -- the same as matrix width, so it was renamed
    );
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
           
--           data_i_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
--           dataRE_i : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
--           dataIM_i : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
--           data_rd_o : out STD_LOGIC;
--           data_rd_i : in STD_LOGIC;

--           data_o_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
--           dataRE_o : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
--           dataIM_o : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
--           data_wr_o : out STD_LOGIC;
--           data_wr_i : in STD_LOGIC;
           
--           log2w : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
--           width : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
--           log2h : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
--           height : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
--           start : in STD_LOGIC;
--           ready : out STD_LOGIC);
end tb_fft2;

architecture Behavioral of tb_fft2 is
-- FFT2 INTERFACE
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    
    signal data_i_addr_o : STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
    signal dataRE_i : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    signal dataIM_i : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    signal data_rd_o : STD_LOGIC;
    signal data_rd_i : STD_LOGIC;
    
    signal data_o_addr_o : STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
    signal dataRE_o : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    signal dataIM_o : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    signal data_wr_o : STD_LOGIC;
    signal data_wr_i : STD_LOGIC;
    
    signal log2w : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0) := (others => '0');
    signal width : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0) := (others => '0');
    
    signal log2h : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0) := (others => '0');
    signal height : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0) := (others => '0');
    
    signal start : STD_LOGIC := '0';
    signal ready : STD_LOGIC;

 -- INIT DP_MEMORY_2D INTERFACE
    signal init_addr_i: std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0) := (others => '0');
    signal init_data_i: std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal init_wr_i: std_logic := '0';
    
    -- TEST FFT ARRAYS
    constant width_c: integer := 4;
    constant height_c: integer := 4;
    type mem_t is array (0 to width_c*height_c - 1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    constant arr1_c : mem_t := 
    -- 1 0 0 0  
    -- 0 0 0 0
    -- 0 0 0 0 
    -- 0 0 0 0
    
--> -- 1 1 1 1
    -- 1 1 1 1
    -- 1 1 1 1
    -- 1 1 1 1
    
--> -- 0 0 0 0
    -- 0 0 0 0
    -- 0 0 0 0 
    -- 0 0 0 0
--       (conv_std_logic_vector(1, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(2, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(3, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(4, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        
--        conv_std_logic_vector(5, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(6, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(7, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(8, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        
--        conv_std_logic_vector(9, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(10, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(11, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(12, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        
--        conv_std_logic_vector(13, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(14, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(15, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
--        conv_std_logic_vector(16, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH));
        
        (conv_std_logic_vector(1, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(1, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, DATA_WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH));
begin
    
    uut: entity work.fft2
    generic map ( 
        FFT_SIZE => FFT_SIZE,
        FIXED_POINT_WIDTH => FIXED_POINT_WIDTH,
        DATA_WIDTH => DATA_WIDTH)
    port map ( 
        clk => clk, 
        rst => rst,
        
        data_i_addr_o => data_i_addr_o,
        dataRE_i => dataRE_i,
        dataIM_i => dataIM_i,
        data_rd_o => data_rd_o,
        data_rd_i => data_rd_i,
        
        data_o_addr_o => data_o_addr_o,
        dataRE_o => dataRE_o,
        dataIM_o => dataIM_o,
        data_wr_o => data_wr_o,
        data_wr_i => data_wr_i,
        
        log2w => log2w,
        width => width,
        
        log2h => log2h,
        height => height,
        
        start => start,
        ready => ready);
        
    clk_process: process begin
        clk <= '1';
        wait for 50ns;
        clk <= '0';
        wait for 50ns;
    end process; 
    
    stim_proc: process begin
    -- TEST 1
        rst <= '1';
        wait for 200ns;
        rst <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;

        wait until falling_edge(clk);
        init_wr_i <= '1';  
        log2w <= conv_std_logic_vector(1,log2w'length);
        width <= conv_std_logic_vector(3,width'length);
        log2h <= conv_std_logic_vector(1,log2h'length);
        height <= conv_std_logic_vector(3,height'length);
        for i in 0 to height_c * width_c - 1 loop
            init_addr_i <= conv_std_logic_vector(i,init_addr_i'length);
            init_data_i <= arr1_c(i);
            wait until falling_edge(clk);
        end loop;
        init_wr_i <= '0';  
        
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
        
        wait;
        
    -- TEST 2
  
  end process;
    
    memoryRE : entity work.dp_memory_2d(beh)
    generic map (
        WIDTH => DATA_WIDTH,
        SIZE => FFT_SIZE)
    port map (
        clk => clk,
        reset => rst,
        
        init_addr_i => init_addr_i,
        init_data_i => init_data_i,
        init_wr_i => init_wr_i,
        
        p1_addr_i => data_i_addr_o,
        p1_data_o => dataRE_i,
        p1_rd_i => data_rd_o,
        p1_rd_o => data_rd_i,
        
        p2_addr_i => data_o_addr_o,
        p2_data_i => dataRE_o,
        p2_wr_i => data_wr_o,
        p2_wr_o => data_wr_i);
        
    memoryIM : entity work.dp_memory_2d(beh)
    generic map (
        WIDTH => DATA_WIDTH,
        SIZE => FFT_SIZE)
    port map (
        clk => clk,
        reset => rst,
         
        init_addr_i => (others => '0'),
        init_data_i => (others => '0'),
        init_wr_i => '0',
               
        p1_addr_i => data_i_addr_o,
        p1_data_o => dataIM_i,
        p1_rd_i => data_rd_o,
        p1_rd_o => data_rd_i,
        
        p2_addr_i => data_o_addr_o,
        p2_data_i => dataIM_o,
        p2_wr_i => data_wr_o,
        p2_wr_o => data_wr_i);
            
end Behavioral;
