library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.utils_pkg.all;

entity tb_axi_fft2 is
end entity;

architecture beh of tb_axi_fft2 is
    
    constant DATA_WIDTH_c : integer := 32;
    constant FIXED_POINT_WIDTH_c : integer := 16;
    constant FFT_SIZE_c : integer := 4;
    constant HEIGHT_c : integer := 3;
    constant WIDTH_c : integer := 3;
    constant LOG2W_c : integer := 1;
    constant LOG2H_c : integer := 1;
    
    type mem_t is array (0 to FFT_SIZE_c*FFT_SIZE_c-1) of integer;
    
--    constant MEM_RE_CONTENT_c: mem_t := (
--        1 * 2**FIXED_POINT_WIDTH_c, 
--        2 * 2**FIXED_POINT_WIDTH_c, 
--        3 * 2**FIXED_POINT_WIDTH_c, 
--        4 * 2**FIXED_POINT_WIDTH_c, 
--        5 * 2**FIXED_POINT_WIDTH_c, 
--        6 * 2**FIXED_POINT_WIDTH_c, 
--        7 * 2**FIXED_POINT_WIDTH_c, 
--        8 * 2**FIXED_POINT_WIDTH_c, 
--        9 * 2**FIXED_POINT_WIDTH_c, 
--        10 * 2**FIXED_POINT_WIDTH_c, 
--        11 * 2**FIXED_POINT_WIDTH_c, 
--        12 * 2**FIXED_POINT_WIDTH_c, 
--        13 * 2**FIXED_POINT_WIDTH_c, 
--        14 * 2**FIXED_POINT_WIDTH_c, 
--        15 * 2**FIXED_POINT_WIDTH_c, 
--        16 * 2**FIXED_POINT_WIDTH_c);

    constant MEM_RE_CONTENT_c: mem_t := (
        1 * 2**FIXED_POINT_WIDTH_c, 
        --4 * 2**FIXED_POINT_WIDTH_c, 
        others => 0);
        
    constant MEM_IM_CONTENT_c: mem_t := (
        --3 * 2**FIXED_POINT_WIDTH_c,
        --2 * 2**FIXED_POINT_WIDTH_c,
        others => 0); 
        
--    constant MEM_IM_CONTENT_c: mem_t := ( 
--        21 * 2**FIXED_POINT_WIDTH_c, 
--        22 * 2**FIXED_POINT_WIDTH_c, 
--        23 * 2**FIXED_POINT_WIDTH_c, 
--        24 * 2**FIXED_POINT_WIDTH_c, 
--        25 * 2**FIXED_POINT_WIDTH_c, 
--        26 * 2**FIXED_POINT_WIDTH_c, 
--        27 * 2**FIXED_POINT_WIDTH_c, 
--        28 * 2**FIXED_POINT_WIDTH_c, 
--        29 * 2**FIXED_POINT_WIDTH_c, 
--        30 * 2**FIXED_POINT_WIDTH_c, 
--        31 * 2**FIXED_POINT_WIDTH_c, 
--        32 * 2**FIXED_POINT_WIDTH_c, 
--        33 * 2**FIXED_POINT_WIDTH_c, 
--        34 * 2**FIXED_POINT_WIDTH_c, 
--        35 * 2**FIXED_POINT_WIDTH_c, 
--        36 * 2**FIXED_POINT_WIDTH_c);
    
    signal clk_s: std_logic;
    signal reset_s: std_logic;
    
    -- Matrix multiplier core's address map
    constant LOG2W_REG_ADDR_C : integer := 0;
    constant WIDTH_REG_ADDR_C : integer := 4;
    constant LOG2H_REG_ADDR_C : integer := 8;
    constant HEIGHT_REG_ADDR_C : integer := 12;
    constant CMD_REG_ADDR_C : integer := 16;
    constant STATUS_REG_ADDR_C : integer := 20;
    constant ADDR_REG_ADDR_C : integer := 24;
    constant DATARE_REG_ADDR_C : integer := 28;
    constant DATAIM_REG_ADDR_C : integer := 32;

    -- Matrix multiplier internal memory map
--    constant MEMORY_RE_OFFSET_C : integer := 0;
--    constant MEMORY_IM_OFFSET_C : integer := 512*4;--256*4;

    ------------------- AXI Interfaces signals -------------------
    -- Parameters of Axi-Lite Slave Bus Interface S00_AXI
    constant C_S00_AXI_DATA_WIDTH_c : integer := 32;
    constant C_S00_AXI_ADDR_WIDTH_c : integer := 6;
    
    -- Ports of Axi-Lite Slave Bus Interface S00_AXI
    signal s00_axi_aclk_s : std_logic := '0';
    signal s00_axi_aresetn_s : std_logic := '1';
    signal s00_axi_awaddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_awprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_awvalid_s : std_logic := '0';
    signal s00_axi_awready_s : std_logic := '0';
    signal s00_axi_wdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_wstrb_s : std_logic_vector((C_S00_AXI_DATA_WIDTH_c/8)-1 downto 0) := (others => '0');
    signal s00_axi_wvalid_s : std_logic := '0';
    signal s00_axi_wready_s : std_logic := '0';
    signal s00_axi_bresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_bvalid_s : std_logic := '0';
    signal s00_axi_bready_s : std_logic := '0';
    signal s00_axi_araddr_s : std_logic_vector(C_S00_AXI_ADDR_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_arprot_s : std_logic_vector(2 downto 0) := (others => '0');
    signal s00_axi_arvalid_s : std_logic := '0';
    signal s00_axi_arready_s : std_logic := '0';
    signal s00_axi_rdata_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0) := (others => '0');
    signal s00_axi_rresp_s : std_logic_vector(1 downto 0) := (others => '0');
    signal s00_axi_rvalid_s : std_logic := '0';
    signal s00_axi_rready_s : std_logic := '0';
    
    signal dataRE_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0);
    signal dataIM_s : std_logic_vector(C_S00_AXI_DATA_WIDTH_c-1 downto 0);
begin

clk_gen: process
    begin
        clk_s <= '0', '1' after 100 ns;
        wait for 200 ns;
    end process;

stimulus_generator: process
    variable axi_read_data_v : std_logic_vector(31 downto 0);
    variable transfer_size_v : integer;
begin
    -- reset AXI-lite interface. Reset will be 10 clock cycles wide
    s00_axi_aresetn_s <= '0';
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    -- release reset
    s00_axi_aresetn_s <= '1';
    wait until falling_edge(clk_s);

    ----------------------------------------------------------------------
    -- Initialize the Matrix Multiplier core --
    ----------------------------------------------------------------------
    report "Loading the matrix dimensions information into the Matrix Multiplier core!";
 
    -- Set the value for LOG2W
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(LOG2W_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(LOG2W_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
    -- Set the value for WIDTH
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(WIDTH_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(WIDTH_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
    -- Set the value for LOG2H
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(LOG2H_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(LOG2H_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s); 
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;
    
    -- Set the value for HEIGHT
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(HEIGHT_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(HEIGHT_c, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;

    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;

    -------------------------------------------------------------------------------------------
    -- Load the element values for matrix RE into the Matrix Multiplier core --
    -------------------------------------------------------------------------------------------
    report "Loading matrix RE&IM element values into the core!";
    
    for data_counter in 0 to (HEIGHT_c+1)*(WIDTH_c+1)-1 loop
        -- Set the value for ADDR
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(ADDR_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '1';
        s00_axi_wdata_s <= conv_std_logic_vector(data_counter, C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '1';
        s00_axi_wstrb_s <= "1111";
        s00_axi_bready_s <= '1';
        wait until s00_axi_awready_s = '1';
        wait until s00_axi_awready_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '0';
        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '0';
        s00_axi_wstrb_s <= "0000";
        wait until s00_axi_bvalid_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_bready_s <= '0';
        wait until falling_edge(clk_s);
        
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
    
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
        
        -- Set the value for dataRE
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(DATARE_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '1';
        s00_axi_wdata_s <= conv_std_logic_vector(MEM_RE_CONTENT_c(data_counter), C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '1';
        s00_axi_wstrb_s <= "1111";
        s00_axi_bready_s <= '1';
        wait until s00_axi_awready_s = '1';
        wait until s00_axi_awready_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '0';
        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '0';
        s00_axi_wstrb_s <= "0000";
        wait until s00_axi_bvalid_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_bready_s <= '0';
        wait until falling_edge(clk_s);
        
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
    
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
        
        -- Set the value for dataIM
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(DATAIM_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '1';
        s00_axi_wdata_s <= conv_std_logic_vector(MEM_IM_CONTENT_c(data_counter), C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '1';
        s00_axi_wstrb_s <= "1111";
        s00_axi_bready_s <= '1';
        wait until s00_axi_awready_s = '1';
        wait until s00_axi_awready_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '0';
        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '0';
        s00_axi_wstrb_s <= "0000";
        wait until s00_axi_bvalid_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_bready_s <= '0';
        wait until falling_edge(clk_s);
        
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
    
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
    end loop;
    
    -------------------------------------------------------------------------------------------
    -- Start the Matrix Multiplier core --
    -------------------------------------------------------------------------------------------
    report "Starting the matrix multiplication process!";
    -- Set the value start bit (bit 0 in the CMD register) to 1
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(CMD_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(1, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -- wait for 5 falling edges of AXI-lite clock signal
    for i in 1 to 5 loop
        wait until falling_edge(clk_s);
    end loop;

    report "Clearing the start bit!";
    -- Set the value start bit (bit 0 in the CMD register) to 1
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(CMD_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '1';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '1';
    s00_axi_wstrb_s <= "1111";
    s00_axi_bready_s <= '1';
    wait until s00_axi_awready_s = '1';
    wait until s00_axi_awready_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
    s00_axi_awvalid_s <= '0';
    s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
    s00_axi_wvalid_s <= '0';
    s00_axi_wstrb_s <= "0000";
    wait until s00_axi_bvalid_s = '0';
    wait until falling_edge(clk_s);
    s00_axi_bready_s <= '0';
    wait until falling_edge(clk_s);
    
    -------------------------------------------------------------------------------------------
    -- Wait until Matrix Multiplier core finishes matrix multiplication --
    -------------------------------------------------------------------------------------------
    report "Waiting for the matric multiplication process to complete!";
    loop
        -- Read the content of the Status register
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(STATUS_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '1';
        s00_axi_rready_s <= '1';
        wait until s00_axi_arready_s = '1';
        --axi_read_data_v := s00_axi_rdata_s;
        wait until s00_axi_arready_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '0';
        s00_axi_rready_s <= '0';
        
        -- Check is the 1st bit of the Status register set to one
        if (s00_axi_rdata_s(0) = '1') then
            -- Matrix multiplication process completed
            exit;
        else
            wait for 1000 ns;
        end if;
    end loop;

    -------------------------------------------------------------------------------------------
    -- Read the elements of matrix RE --
    -------------------------------------------------------------------------------------------
    report "Reading the results of the RE&IM matrix!";

    report "Writing addr!";
    for data_counter in 0 to (HEIGHT_c+1)*(WIDTH_c+1)-1 loop
        -- Set the value for ADDR
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(ADDR_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '1';
        s00_axi_wdata_s <= conv_std_logic_vector(data_counter, C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '1';
        s00_axi_wstrb_s <= "1111";
        s00_axi_bready_s <= '1';
        wait until s00_axi_awready_s = '1';
        wait until s00_axi_awready_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_awaddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_awvalid_s <= '0';
        s00_axi_wdata_s <= conv_std_logic_vector(0, C_S00_AXI_DATA_WIDTH_c);
        s00_axi_wvalid_s <= '0';
        s00_axi_wstrb_s <= "0000";
        wait until s00_axi_bvalid_s = '0';
        wait until falling_edge(clk_s);
        s00_axi_bready_s <= '0';
        wait until falling_edge(clk_s);
        
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
    
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
        
        report "Reading RE!";
        -- Set the value for dataRE
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(DATARE_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '1';
        s00_axi_rready_s <= '1';
        wait until s00_axi_arready_s = '1';
        wait until s00_axi_arready_s = '0';
        --s00_axi_arvalid_s <= '0';
        --s00_axi_rready_s <= '0';
        
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '0';
        s00_axi_rready_s <= '0';
        --wait until s00_axi_rvalid_s = '1';
        dataRE_s <= s00_axi_rdata_s;
        --wait until s00_axi_rvalid_s = '0';
        wait until falling_edge(clk_s);
        
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
    
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 1 loop
            wait until falling_edge(clk_s);
        end loop;
        
        report "Reading IM!";
        -- Set the value for dataIM
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(DATAIM_REG_ADDR_C, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '1';
        s00_axi_rready_s <= '1';
        wait until s00_axi_arready_s = '1';
        wait until s00_axi_arready_s = '0';
        --s00_axi_arvalid_s <= '0';
        --s00_axi_rready_s <= '0';
        
        wait until falling_edge(clk_s);
        s00_axi_araddr_s <= conv_std_logic_vector(0, C_S00_AXI_ADDR_WIDTH_c);
        s00_axi_arvalid_s <= '0';
        s00_axi_rready_s <= '0';
        --wait until s00_axi_rvalid_s = '1';
        dataIM_s <= s00_axi_rdata_s;
        --wait until s00_axi_rvalid_s = '0';
        wait until falling_edge(clk_s);
        
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
    
        -- wait for 5 falling edges of AXI-lite clock signal
        for i in 1 to 3 loop
            wait until falling_edge(clk_s);
        end loop;
    end loop;
    
    report "Finished!";
    wait;
end process;

-------------------------------------------------------------------------
-- DUT --
-------------------------------------------------------------------------
axi_matrix_multiplier: entity work.axi_fft2_v1_0(arch_imp)
    generic map(
        FIXED_POINT_WIDTH => FIXED_POINT_WIDTH_c,
        DATA_WIDTH => DATA_WIDTH_c,
        FFT_SIZE => FFT_SIZE_c)
    port map (
        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk => clk_s,
        s00_axi_aresetn => s00_axi_aresetn_s,
        s00_axi_awaddr => s00_axi_awaddr_s,
        s00_axi_awprot => s00_axi_awprot_s, 
        s00_axi_awvalid => s00_axi_awvalid_s,
        s00_axi_awready => s00_axi_awready_s,
        s00_axi_wdata => s00_axi_wdata_s,
        s00_axi_wstrb => s00_axi_wstrb_s,
        s00_axi_wvalid => s00_axi_wvalid_s,
        s00_axi_wready => s00_axi_wready_s,
        s00_axi_bresp => s00_axi_bresp_s,
        s00_axi_bvalid => s00_axi_bvalid_s,
        s00_axi_bready => s00_axi_bready_s,
        s00_axi_araddr => s00_axi_araddr_s,
        s00_axi_arprot => s00_axi_arprot_s,
        s00_axi_arvalid => s00_axi_arvalid_s,
        s00_axi_arready => s00_axi_arready_s,
        s00_axi_rdata => s00_axi_rdata_s,
        s00_axi_rresp => s00_axi_rresp_s,
        s00_axi_rvalid => s00_axi_rvalid_s,
        s00_axi_rready => s00_axi_rready_s);
    
end architecture beh;