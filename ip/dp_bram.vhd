library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.utils_pkg.all;

entity dp_bram is
    generic (
        DATA_WIDTH: integer := 32;
        FFT_SIZE : integer := 8
    );
    port (
        ckla : in std_logic;
        clkb : in std_logic;
        
        ena : in std_logic;
        enb : in std_logic;
        
        wra_i : in std_logic;
        wrb_i : in std_logic;
        
        wra_o : out std_logic;
        wrb_o : out std_logic;
        
        rda_i : in std_logic;
        rdb_i : in std_logic;
        
        rda_o : out std_logic;
        rdb_o : out std_logic;
        
        addra : in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
        addrb_rd : in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
        addrb_wr : in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
        
        dia : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dib : in std_logic_vector(DATA_WIDTH-1 downto 0);
        
        doa : out std_logic_vector(DATA_WIDTH-1 downto 0);
        dob : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end dp_bram;

architecture beh of dp_bram is

    type ram_type is array ((FFT_SIZE*FFT_SIZE)-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal RAM: ram_type := (others => (others => '0'));
    
begin

    process(ckla, clkb)
    begin
        if ckla'event and ckla = '1' then
            rda_o <= '0';
            wra_o <= '0';
            if ena = '1' then
                doa <= RAM(conv_integer(addra));
                if rda_i = '1' then
                    rda_o <= '1';
                elsif wra_i = '1' then
                    RAM(conv_integer(addra)) <= dia;
                    wra_o <= '1';
--                else
--                    doa <= (others => '0');
                end if;
            end if;
        --end if;

        --if clkb'event and clkb = '1' then
--            rdb_o <= '0';
--            wrb_o <= '0';
            if enb = '1' then
                if rdb_i = '1' then
                    dob <= RAM(conv_integer(addrb_rd));
                    rdb_o <= '1';
                    wrb_o <= '0';
                elsif wrb_i = '1' then
                    RAM(conv_integer(addrb_wr)) <= dib;
                    wrb_o <= '1';
                    rdb_o <= '0';
--                else
--                    dob <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
end beh;