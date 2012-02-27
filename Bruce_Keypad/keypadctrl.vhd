library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration
entity keypadctrl is
   port
	(reset,new_data_ack,debounce_done,sys_clk			: in std_logic;
   new_data,col_scan,clk 									: out std_logic;
	debounce_reset												: inout std_logic;
   keypad_row 													: in std_logic_vector(3 downto 0);
   keypad_col													: in std_logic_vector(3 downto 0);
	output_register											: out std_logic_vector(7 downto 0));
		
end keypadctrl;

architecture mixed of keypadctrl is
   type state_type is
		(k_press,dbnce_press,w_ack,dataxfer);
   signal state,next_state 		: state_type;
	 signal divider 					: unsigned(15 downto 0);
	 signal clock						: std_logic;
	 
	subtype my_word is std_logic_vector(7 downto 0);
	type my_array is array (0 to 15) of my_word;
	-- For the following array addresses,
	-- First two bits represents column index, second two bits represents row index
	-- e.g. 0001 represents column 0 row 1, i.e. button 5 on the keypad
	constant s : my_array := ( "00000001","00000101","00001001","00001101", -- 1, 5, 9,  13
										"00000010","00000110","00001010","00001110", -- 2, 6, 10, 14
										"00000011","00000111","00001011","00001111", -- 3, 7, 11, 15
										"00000100","00001000","00001100","00010000");-- 4, 8, 12, 16

	 signal hi_addr					: std_logic_vector(1 downto 0);
	 signal low_addr					: std_logic_vector(1 downto 0);
	 signal prev_press				: std_logic;

begin
   combinational : process(state,keypad_row,new_data_ack,debounce_done)
   begin
      case state is
         when k_press =>
            new_data <= '0';
            debounce_reset <= '1';
            col_scan <= '1';
				
				if keypad_row = "0111" or keypad_row = "1011" or keypad_row = "1101" or keypad_row = "1110" then
					prev_press <= '1';
					if keypad_col = "0111" then hi_addr <= "00";
					elsif keypad_col = "1011" then hi_addr <= "01";
					elsif keypad_col = "1101" then hi_addr <= "10";
					elsif keypad_col = "1110" then hi_addr <= "11";
					else hi_addr <= "00";
					end if;
					 		  
					if keypad_row = "0111" then low_addr <= "00";
					elsif keypad_row = "1011" then low_addr <= "01";
					elsif keypad_row = "1101" then low_addr <= "10";
					elsif keypad_row = "1110" then low_addr <= "11";
					else low_addr <= "00";
				   end if;
					
				   output_register <= s(to_integer(unsigned(hi_addr) & unsigned(low_addr)));
					
					next_state <= dbnce_press; -- only one key pressed
				else
					if prev_press = '1' then
						prev_press <= '0';	--	send out 'no key pressed'
						--output_register <= "00000000";
					   next_state <= dbnce_press;
					else
						next_state <= k_press; -- no keypress, keep waiting
					end if;
					
            end if;
				
         when dbnce_press =>
            new_data <= '0';
            debounce_reset <= '0';
            col_scan <= '0';
            if(debounce_done = '1') then      --debounced
               next_state <= w_ack;
            else
               next_state <= dbnce_press;        -- counter done (debounced)
            end if;
         when w_ack =>
            new_data <= '1';
            debounce_reset <= '1';
            col_scan <= '0';
            if(new_data_ack = '1') then
               next_state <= dataxfer;
            else
               next_state <= w_ack;
            end if;
         when dataxfer =>
            new_data <= '0';
            debounce_reset <= '1';
            col_scan <= '0';
            if(new_data_ack = '1') then
               next_state <= dataxfer;
            else
               next_state <= k_press;
            end if;
      end case;
   end process combinational;

   state_logic : process(clock,reset)
   begin
      if reset = '1' then
         state <= k_press;
      elsif(rising_edge(clock)) then
         state <= next_state;
      end if;
   end process state_logic;

--end mixed;

--purpose: takes the system clock and drops it to 2mS clock.
--type : sequential.
--inputs : sys_clk, reset.
--outputs : clk.
clock_div : process (sys_clk, reset, divider)
begin -- process clock_div
	if reset = '0' then	-- asynchronous reset (active low)
		divider	<= to_unsigned(0, 16);
		clock		<= '0';
	elsif rising_edge(sys_clk) then 
		if divider = X"8235" then
			clock		<= not clock;
			divider 	<= to_unsigned(0, 16);
		else 
			divider	<= divider + to_unsigned(1, 16);
		end if;
	end if;
end process clock_div;
clk<= clock;

end;
