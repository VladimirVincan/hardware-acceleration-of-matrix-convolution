library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

-- needs to be rewritten for different data_width values

entity BRAM is
   generic
      (
         FFT_SIZE : natural := 8;
         DATA_WIDTH : natural := 32;
         CHAR_WIDTH : natural := 8
      );
   port
      (
         clk		: in std_logic;
         -- Interface A
         en_a_i	    : in std_logic;
         reset_a_i  : in std_logic;
         addr_a_i	: in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE*DATA_WIDTH/CHAR_WIDTH) - 1 downto 0);
         data_a_i	: in std_logic_vector(DATA_WIDTH-1 downto 0);
         data_a_o	: out std_logic_vector(DATA_WIDTH-1 downto 0);
         we_a_i	    : in std_logic_vector(3 downto 0);
         -- Interface B
         en_b_i	    : in std_logic;
         reset_b_i  : in std_logic;
         addr_b_i	: in std_logic_vector(log2c(FFT_SIZE*FFT_SIZE*DATA_WIDTH/CHAR_WIDTH) - 1 downto 0);
         data_b_i	: in std_logic_vector(DATA_WIDTH-1 downto 0);
         data_b_o	: out std_logic_vector(DATA_WIDTH-1 downto 0);
         we_b_i	    : in std_logic_vector(3 downto 0)
      );

end BRAM;

architecture behavioral of BRAM is type ram_type is array(0 to FFT_SIZE*FFT_SIZE*DATA_WIDTH/CHAR_WIDTH - 1) 
   of std_logic_vector(7 downto 0); signal ram_s :
   ram_type := (others => (others => '0'));
   
begin

   -- synchronous writing
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(en_a_i='1') then            
            if(we_a_i(3) = '1') then
               ram_s(to_integer(unsigned(addr_a_i)+3)) <= data_a_i(31 downto 24);
            end if;
            if(we_a_i(2) = '1') then
               ram_s(to_integer(unsigned(addr_a_i)+2)) <= data_a_i(23 downto 16);
            end if;
            if(we_a_i(1) = '1') then
               ram_s(to_integer(unsigned(addr_a_i)+1)) <= data_a_i(15 downto 8);
            end if;
            if(we_a_i(0) = '1') then
               ram_s(to_integer(unsigned(addr_a_i))) <= data_a_i(7 downto 0);               
            end if;                        
         end if;
         if(en_b_i='1') then
            if(we_b_i(3) = '1') then
               ram_s(to_integer(unsigned(addr_b_i)+3)) <= data_b_i(31 downto 24);
            end if;
            if(we_b_i(2) = '1') then
               ram_s(to_integer(unsigned(addr_b_i)+2)) <= data_b_i(23 downto 16);
            end if;
            if(we_b_i(1) = '1') then
               ram_s(to_integer(unsigned(addr_b_i)+1)) <= data_b_i(15 downto 8);
            end if;
            if(we_b_i(0) = '1') then
               ram_s(to_integer(unsigned(addr_b_i))) <= data_b_i(7 downto 0);   
            end if;
         end if;
      end if;
   end process;
   
   -- synchronous reading
   process(clk)
   begin
      if(rising_edge(clk)) then
         if(en_a_i='1') then
            if (reset_a_i = '0') then
               data_a_o(31 downto 24) <= ram_s(to_integer(unsigned(addr_a_i)+3));
               data_a_o(23 downto 16) <= ram_s(to_integer(unsigned(addr_a_i)+2));
               data_a_o(15 downto 8) <= ram_s(to_integer(unsigned(addr_a_i)+1));
               data_a_o(7 downto 0) <= ram_s(to_integer(unsigned(addr_a_i)));
            else
               data_a_o <= (others =>'0');
            end if;
         end if;
         if(en_b_i='1') then
            if (reset_b_i = '0') then
               data_b_o(31 downto 24) <= ram_s(to_integer(unsigned(addr_b_i)+3));
               data_b_o(23 downto 16) <= ram_s(to_integer(unsigned(addr_b_i)+2));
               data_b_o(15 downto 8) <= ram_s(to_integer(unsigned(addr_b_i)+1));
               data_b_o(7 downto 0) <= ram_s(to_integer(unsigned(addr_b_i)));
            else
               data_b_o <= (others =>'0');
            end if;
         end if;       
      end if;
   end process;

end behavioral;