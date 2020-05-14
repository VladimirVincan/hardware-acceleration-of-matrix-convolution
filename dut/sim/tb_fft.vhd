library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_arith.all;
use work.utils_pkg.all;

entity tb_fft is
    Generic ( 
           FFT_SIZE : positive := 8;
           FIXED_POINT_WIDTH : positive := 16;
           WIDTH : positive := 32
    );
--    Port ( clk : in STD_LOGIC;
--           rst : in STD_LOGIC;
           
--           data_i_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
--           dataRE_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           dataIM_i : in STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           data_rd_o : out STD_LOGIC;

--           data_o_addr_o : out STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
--           dataRE_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           dataIM_o : out STD_LOGIC_VECTOR (WIDTH-1 downto 0);
--           data_wr_o : out STD_LOGIC;
           
--           log2s : in STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
--           size : in STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
           
--           start : in STD_LOGIC;
--           ready : out STD_LOGIC);
end tb_fft;

architecture Behavioral of tb_fft is
-- FFT INTERFACE
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    
    signal data_i_addr_o : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal dataRE_i : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal dataIM_i : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal data_rd_o : STD_LOGIC;
    signal data_rd_i : STD_LOGIC;
    
    signal data_o_addr_o : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
    signal dataRE_o : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal dataIM_o : STD_LOGIC_VECTOR (WIDTH-1 downto 0);
    signal data_wr_o : STD_LOGIC;
    signal data_wr_i : STD_LOGIC;
    
    signal log2s : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0) := (others => '0');
    signal size : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0) := (others => '0');
    
    signal start : STD_LOGIC := '0';
    signal ready : STD_LOGIC;
    
 -- INIT DP_MEMORY_1D INTERFACE
    signal init_addr_i: std_logic_vector(log2c(FFT_SIZE)-1 downto 0) := (others => '0');
    signal init_data_i: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal init_wr_i: std_logic := '0';
       
-- TEST FFT ARRAYS
    type mem_t is array (0 to FFT_SIZE-1) of std_logic_vector(WIDTH-1 downto 0);
    constant arr1_c : mem_t := 
    -- 1 1 1 1 1 1 1 1
    -- 0 0 0 0 0 0 0 0
       (conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH));
    constant arr2_c : mem_t := 
    -- 36 -4          -4 -4          -4 -4          -4 -4
    -- 0   9.65685425  4  1.65685425  0 -1.65685425 -4 -9.65685425 
       (conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(2, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(3, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(4, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(5, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(6, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(7, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(8, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH));
    constant arr3_c : mem_t :=
    -- 2  1.70710678  1  0.29289322 0 0.29289322 1 1.70710678
    -- 0 -0.70710678 -1 -0.70710678 0 0.70710678 1 0.70710678
       (conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH));
    constant arr4_c : mem_t :=
    -- 2 0 2 0 2 0 2 0
    -- 0 0 0 0 0 0 0 0
       (conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH));
    constant arr5_c : mem_t :=
    -- 3 -0.70710678 2  0.70710678 1 0.70710678  2 -0.70710678
    -- 0 -0.70710678 1 -0.70710678 0 0.70710678 -1  0.70710678 
       (conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(1, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH),
        conv_std_logic_vector(0, WIDTH - FIXED_POINT_WIDTH) & conv_std_logic_vector(0, FIXED_POINT_WIDTH));
                
begin
    uut: entity work.fft
    generic map ( 
        FFT_SIZE => FFT_SIZE,
        FIXED_POINT_WIDTH => FIXED_POINT_WIDTH,
        WIDTH => WIDTH)
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
        
        log2s => log2s,
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
    -- TEST 1
        rst <= '1';
        wait for 100ns;
        rst <= '0';
        if ready /= '1' then
            wait until ready = '1';
        end if;
        wait for 100ns;

        wait until falling_edge(clk);
        init_wr_i <= '1';
        log2s <= conv_std_logic_vector(2,log2s'length); -- check this part
        size <= conv_std_logic_vector(7,size'length);
        for i in 0 to FFT_SIZE-1 loop
            init_addr_i <= conv_std_logic_vector(i,init_addr_i'length);
            init_data_i <= arr2_c(i);
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
    
    memoryRE : entity work.dp_memory_1d(beh)
    generic map (
        WIDTH => WIDTH,
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
        
    memoryIM : entity work.dp_memory_1d(beh)
    generic map (
        WIDTH => WIDTH,
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
