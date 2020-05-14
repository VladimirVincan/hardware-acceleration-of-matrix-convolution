library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.utils_pkg.all;

entity bram_if is
    generic
      (
         FFT_SIZE : natural := 8;
         DATA_WIDTH : natural := 32
       );
    port (
        clk : in std_logic;
        -- bram connector
        bram_en_o	    : out std_logic;
        bramif_addr_o	: out std_logic_vector(log2c(FFT_SIZE*FFT_SIZE) - 1 downto 0);
        bramif_dataRE_i	: in std_logic_vector(DATA_WIDTH-1 downto 0);
        bramif_dataRE_o	: out std_logic_vector(DATA_WIDTH-1 downto 0);
        bramif_dataIM_i	: in std_logic_vector(DATA_WIDTH-1 downto 0);
        bramif_dataIM_o	: out std_logic_vector(DATA_WIDTH-1 downto 0);
        bramif_we_o	    : out std_logic_vector(3 downto 0);
        
        -- fft2 connector
        fft2_addr_i   : in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE) - 1 downto 0);
        fft2_dataRE_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
        fft2_dataRE_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        fft2_dataIM_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
        fft2_dataIM_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
        fft2_we_i     : in std_logic;
        fft2_we_o     : out std_logic;
        fft2_re_i     : in std_logic;
        fft2_re_o     : out std_logic
    );
end bram_if;

architecture Behavioral of bram_if is
    signal we_n, we_r, re_n, re_r : std_logic := '0';
begin

    process (clk) is begin
        if clk'event and clk = '1' then
            we_r <= we_n;
            re_r <= re_n;
        end if;
    end process;
    
    process (fft2_we_i, fft2_re_i) is begin
        we_n <= fft2_we_i;
        re_n <= fft2_re_i;
    end process;
    
    bram_en_o <= '1';
    bramif_addr_o <= fft2_addr_i;
    bramif_dataRE_o <= fft2_dataRE_i;
    fft2_dataRE_o <= bramif_dataRE_i;
    bramif_dataIM_o <= fft2_dataIM_i;
    fft2_dataIM_o <= bramif_dataIM_i;
    bramif_we_o <= "1111"  when fft2_we_i = '1' else
                     "0000";
    fft2_we_o <= we_r;
    fft2_re_o <= re_r;

end Behavioral;
