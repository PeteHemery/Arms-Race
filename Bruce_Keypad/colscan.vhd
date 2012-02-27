library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration
entity colscan is
   port(
      clk,reset,enable : in std_logic;
      Q : out std_logic_vector(3 downto 0));
end colscan;

architecture behaviour of colscan is
	signal Q_sig : std_logic_vector(3 downto 0);
begin
   scan : process(clk,reset)
   begin
      if reset = '1' then
         Q_sig <= "0111";
      elsif falling_edge(clk) and (enable = '1') then
         if Q_sig = "0111" then
            Q_sig <= "1011";
         elsif Q_sig = "1011" then
            Q_sig <= "1101";
         elsif Q_sig = "1101" then
            Q_sig <= "1110";
         elsif Q_sig = "1110" then
            Q_sig <= "0111";
         end if;
      end if;
   end process scan;
	Q <= Q_sig;
end behaviour;
