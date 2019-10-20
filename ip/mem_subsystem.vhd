library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use work.utils_pkg.all;

entity mem_subsystem is
    generic (
        DATA_WIDTH : integer := 32;
        FFT_SIZE : integer := 8
    );
    port(
        clk : in std_logic;
        reset : in std_logic;
        
        -- Interface to the AXI controllers
        reg_data_i : in std_logic_vector(maxc(log2c(FFT_SIZE*FFT_SIZE),DATA_WIDTH)-1 downto 0);
        log2w_wr_i : in std_logic;
        width_wr_i : in std_logic;
        log2h_wr_i : in std_logic;
        height_wr_i : in std_logic;
        cmd_wr_i : in std_logic;
        
--        addr_wr_i : in std_logic;
--        dataRE_wr_i : in std_logic;
--        dataIM_wr_i : in std_logic;
        
        log2w_axi_o : out std_logic_vector(log2c(log2c(FFT_SIZE))-1 downto 0);
        width_axi_o : out std_logic_vector(log2c(FFT_SIZE)-1 downto 0);
        log2h_axi_o : out std_logic_vector(log2c(log2c(FFT_SIZE))-1 downto 0);
        height_axi_o : out std_logic_vector(log2c(FFT_SIZE)-1 downto 0);
        cmd_axi_o : out std_logic;
        status_axi_o : out std_logic;
        
--        addr_axi_o : out std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
--        dataRE_axi_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
--        dataIM_axi_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        
--        mem_addr_i : in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE) downto 0); -- +1 for RE and IM
--        mem_data_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
--        mem_wr_i : in std_logic;
        
--        mem_re_axi_data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
--        mem_im_axi_data_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        
        -- Interface to the fft2 module
        log2w_o : out std_logic_vector(log2c(log2c(FFT_SIZE))-1 downto 0);
        width_o : out std_logic_vector(log2c(FFT_SIZE)-1 downto 0);
        log2h_o : out std_logic_vector(log2c(log2c(FFT_SIZE))-1 downto 0);
        height_o : out std_logic_vector(log2c(FFT_SIZE)-1 downto 0);
        start_o : out std_logic;
        ready_i : in std_logic
        
--        mem_data_wr_addr_i : in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
--        mem_data_wr_i : in std_logic;
--        mem_data_wr_o : out std_logic;
--        mem_dataRE_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
--        mem_dataIM_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
        
--        mem_data_rd_addr_i : in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
--        mem_data_rd_i : in std_logic;
--        mem_data_rd_o : out std_logic;
--        mem_dataRE_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
--        mem_dataIM_o : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end mem_subsystem;

architecture struct of mem_subsystem is

    signal log2w_s, log2h_s : std_logic_vector(log2c(log2c(FFT_SIZE)) -1 downto 0);
    signal width_s, height_s: std_logic_vector(log2c(FFT_SIZE) -1 downto 0);
    signal cmd_s, status_s: std_logic;
    
    --signal rd_i_s, rd_o_s, wr_i_s, wr_o_s: std_logic;
--    signal en_re_s, en_im_s : std_logic;
--    signal rd_re_s, rd_im_s, wr_re_s, wr_im_s : std_logic;
--    signal rd_and_s, wr_and_s : std_logic;
    
    signal mem_data_wr_re_o, mem_data_wr_im_o : std_logic;
    signal mem_data_rd_re_o, mem_data_rd_im_o : std_logic;

    signal addr_s : std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
    
begin

    log2w_o <= log2w_s;
    width_o <= width_s;
    log2h_o <= log2h_s;
    height_o <= height_s;
    start_o <= cmd_s;
    ---------------------- REGISTERS ----------------------
    log2w_axi_o <= log2w_s;
    width_axi_o <= width_s;
    log2h_axi_o <= log2h_s;
    height_axi_o <= height_s;
    cmd_axi_o <= cmd_s;
    status_axi_o <= status_s;
--    addr_axi_o <= addr_s;
    
    -- log2w register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                log2w_s <= (others => '0');
            elsif log2w_wr_i = '1' then
                log2w_s <= reg_data_i (log2c(log2c(FFT_SIZE))-1 downto 0);
            end if;
        end if;
    end process;
    
    -- width register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                width_s <= (others => '0');
            elsif width_wr_i = '1' then
                width_s <= reg_data_i(log2c(FFT_SIZE)-1 downto 0);
            end if;
        end if;
    end process;
    
    -- log2h register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                log2h_s <= (others => '0');
            elsif log2h_wr_i = '1' then
                log2h_s <= reg_data_i (log2c(log2c(FFT_SIZE))-1 downto 0);
            end if;
        end if;
    end process;
    
    -- height register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                height_s <= (others => '0');
            elsif height_wr_i = '1' then
                height_s <= reg_data_i(log2c(FFT_SIZE)-1 downto 0);
            end if;
        end if;
    end process;
    
    -- CMD register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                cmd_s <= '0';
            elsif cmd_wr_i = '1' then
                cmd_s <= reg_data_i(0);
            end if;
        end if;
    end process;
    
    -- STATUS register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                status_s <= '0';
            else
                status_s <= ready_i;
            end if;
        end if;
    end process;
    
    -- ADDR register
--    process(clk)
--    begin
--        if clk'event and clk = '1' then
--            if reset = '1' then
--                addr_s <= (others => '0');
--            elsif addr_wr_i = '1' then
--                addr_s <= reg_data_i (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
--            end if;
--        end if;
--    end process;
    
    ---------------------- MEMORIES ----------------------
--     Address decoder
--    addr_dec: process (mem_addr_i)
--    begin
--        mem_data_wr_o <= mem_data_wr_re_o and mem_data_wr_im_o;
--        mem_data_rd_o <= mem_data_rd_re_o and mem_data_rd_im_o;
--        -- Default assignments
--        en_re_s <= '0';
--        en_im_s <= '0';
--        case mem_addr_i(log2c(FFT_SIZE*FFT_SIZE)) is
--            when '0' =>
--                en_re_s <= '1';
--            when others =>
--                en_im_s <= '1';
--        end case;
--    end process;
    
--    mem_data_wr_o <= mem_data_wr_re_o and mem_data_wr_im_o;
--    mem_data_rd_o <= mem_data_rd_re_o and mem_data_rd_im_o;
    
--    -- Memory for storing the elements of RE values
--    re_memory: entity work.dp_bram(beh)
--        generic map
--        (
--            DATA_WIDTH => DATA_WIDTH,
--            FFT_SIZE => FFT_SIZE
--        )
--        port map
--        (
--            clk => clk,
            
--            ena => dataRE_wr_i,
--            wra_i => dataRE_wr_i,
--            wra_o => open,
--            rda_i => '0',
--            rda_o => open,
--            addra => addr_s,
--            dia => reg_data_i(DATA_WIDTH-1 downto 0),
--            doa => dataRE_axi_o, --open, --mem_re_axi_data_o,
            
--            enb => '1',
--            wrb_i => mem_data_wr_i,
--            wrb_o => mem_data_wr_re_o,
--            rdb_i => mem_data_rd_i,
--            rdb_o => mem_data_rd_re_o,
--            addrb_rd => mem_data_rd_addr_i,
--            addrb_wr => mem_data_wr_addr_i,
--            dib => mem_dataRE_i,
--            dob => mem_dataRE_o
--        );
        
--    -- Memory for storing the elements of IM values
--    im_memory: entity work.dp_bram(beh)
--        generic map (
--            DATA_WIDTH => DATA_WIDTH,
--            FFT_SIZE => FFT_SIZE
--        )
--        port map (
--            clk => clk,
            
--            ena => dataIM_wr_i,
--            wra_i => dataIM_wr_i,
--            wra_o => open,
--            rda_i => '0',
--            rda_o => open,
--            addra => addr_s,
--            dia => reg_data_i(DATA_WIDTH-1 downto 0),
--            doa => dataIM_axi_o, --open, --mem_im_axi_data_o,
            
--            enb => '1',
--            wrb_i => mem_data_wr_i,
--            wrb_o => mem_data_wr_im_o,
--            rdb_i => mem_data_rd_i,
--            rdb_o => mem_data_rd_im_o,
--            addrb_rd => mem_data_rd_addr_i,
--            addrb_wr => mem_data_wr_addr_i,
--            dib => mem_dataIM_i,
--            dob => mem_dataIM_o
--        );
end struct;