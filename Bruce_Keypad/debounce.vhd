library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
   port
	(clk,reset 	: in std_logic;
      complete 	: out std_logic);
		
end debounce;

architecture behavioural of debounce is
begin
   counter : process(reset,clk)
      variable count : unsigned(6 downto 0);
   begin
      if(reset = '1') then
         count := to_unsigned(100,7);   -- initial value 100
--         count := "0001010";   -- value 10 for testing
         complete <= '0';
      elsif(rising_edge(clk)) then
         if (count /= "0000000") then
            count := count - 1;
            complete <= '0';
         else                                                                                 
            complete <= '1';
         end if;
      end if;
   end process counter;
end behavioural;
