library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.utils_pkg.all;

entity dp_memory_1d is
    generic (
        WIDTH: integer := 8;
        SIZE: integer := 3);
    port (
        clk: in std_logic;
        reset: in std_logic;
        
        -- Port 0 write interface
        init_addr_i: in std_logic_vector(log2c(SIZE)-1 downto 0);
        init_data_i: in std_logic_vector(WIDTH-1 downto 0);
        init_wr_i: in std_logic;
        
        -- Port 1 read interface0
        p1_addr_i: in std_logic_vector(log2c(SIZE)-1 downto 0);
        p1_data_o: out std_logic_vector(WIDTH-1 downto 0) := (others => '0');
        p1_rd_i: in std_logic;
        p1_rd_o: out std_logic;
        
        -- Port 2 write interface
        p2_addr_i: in std_logic_vector(log2c(SIZE)-1 downto 0);
        p2_data_i: in std_logic_vector(WIDTH-1 downto 0);
        p2_wr_i: in std_logic;
        p2_wr_o: out std_logic);
end entity;

architecture beh of dp_memory_1d is
    type mem_t is array (0 to 2**log2c(SIZE)-1) of std_logic_vector(WIDTH-1 downto 0);
    signal mem_s: mem_t := (others => (others => '0'));
begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            p1_rd_o <= '0';
            p2_wr_o <= '0';
            if (reset = '1') then
                mem_s <= (others => (others => '0'));
            else
                if init_wr_i = '1' then
                    mem_s(conv_integer(init_addr_i)) <= init_data_i;
                    p1_data_o <= init_data_i;
                end if;
                if p1_rd_i = '1' and p2_wr_i = '0' then
                    p1_data_o <= mem_s(conv_integer(p1_addr_i));
                    p1_rd_o <= '1';
                elsif p1_rd_i = '0' and p2_wr_i = '1' then
                    mem_s(conv_integer(p2_addr_i)) <= p2_data_i;
                    p2_wr_o <= '1';
                else
                    p1_data_o <= (others => '0');
                end if;                  
            end if;
        end if;
    end process;
end architecture beh;