library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- entity declaration
entity keypadctrl is
   port(
      clock,reset,new_data_ack,debounce_done : in std_logic;
      new_data,loadMSD,loadLSD,add_load,data_enable,debounce_reset,row_scan : out std_logic;
      keypad_column : in std_logic_vector(2 downto 0)
   );
end keypadctrl;

architecture mixed of keypadctrl is
   type state_type is(
      w_press1,dbnce_press1,w_rls1,dbnce_rls1,
      w_press2,dbnce_press2,w_rls2,dbnce_rls2,
      w_ack,dataxfer
   );
   signal state,next_state : state_type;

begin
   combinational : process(state,keypad_column,new_data_ack,debounce_done)
   begin
      case state is
         when w_press1 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '1';
            row_scan <= '1';
            if keypad_column = "111" then    -- no keypress, keep waiting
               next_state <= w_press1;
            else                             -- keypress
               next_state <= dbnce_press1;
            end if;
         when dbnce_press1 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '0';
            row_scan <= '0';
            if(debounce_done = '1') then      --debounced
               next_state <= w_rls1;
            else
               next_state <= dbnce_press1;        -- counter done (debounced)
            end if;
         when w_rls1 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '1';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '1';
            row_scan <= '0';
            if keypad_column = "111" then   -- key release
               next_state <= dbnce_rls1;
            else
               next_state <= w_rls1;      -- key not released, keep waiting
            end if;
         when dbnce_rls1 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '0';
            row_scan <= '0';
            if(debounce_done = '1') then
               next_state <= w_press2;      -- waiting for counter (debouncing)
            else
               next_state <= dbnce_rls1;    -- counter done (debounced)
            end if;
         when w_press2 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '1';
            row_scan <= '1';
            if keypad_column = "111" then   -- no keypress, keep waiting
               next_state <= w_press2;
            else
               next_state <= dbnce_press2;  -- keypress
            end if;
         when dbnce_press2 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '0';
            row_scan <= '0';
            if(debounce_done = '1') then   -- waiting for counter (debouncing)
               next_state <= w_rls2;
            else                          -- counter done (debounced)
               next_state <= dbnce_press2;
            end if;
         when w_rls2 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '1';
            add_load <= '0';
            debounce_reset <= '1';
            row_scan <= '0';
            if keypad_column = "111" then   -- key released
               next_state <= dbnce_rls2;
            else
               next_state <= w_rls2;        -- key not released yet
            end if;
         when dbnce_rls2 =>
            new_data <= '0';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '1';
            debounce_reset <= '0';
            row_scan <= '0';
            if(debounce_done = '1') then   -- waiting for counter (debouncing)
               next_state <= w_ack;
            else                          -- counter done (debounced)
               next_state <= dbnce_rls2;
            end if;
         when w_ack =>
            new_data <= '1';
            data_enable <= '0';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '1';
            row_scan <= '0';
            if(new_data_ack = '1') then
               next_state <= dataxfer;
            else
               next_state <= w_ack;
            end if;
         when dataxfer =>
            new_data <= '0';
            data_enable <= '1';
            loadMSD <= '0';
            loadLSD <= '0';
            add_load <= '0';
            debounce_reset <= '1';
            row_scan <= '0';
            if(new_data_ack = '1') then
               next_state <= dataxfer;
            else
               next_state <= w_press1;
            end if;
      end case;
   end process combinational;

   state_logic : process(clock,reset)
   begin
      if reset = '1' then
         state <= w_press1;
      elsif(rising_edge(clock)) then
         state <= next_state;
      end if;
   end process state_logic;

end mixed;

entity debounce is
   port(
      clock,reset : in std_logic;
      complete : out std_logic
   );
end debounce;

architecture behavioural of debounce is
begin
   counter : process(reset,clock)
      variable count : std_logic_vector(6 downto 0);
   begin
      if(reset = '1') then
         count := "1100100";   -- initial value 100
--         count := "0001010";   -- value 10 for testing
         complete <= '0';
      elsif(rising_edge(clock)) then
         if (count /= "0000000") then
            count := count - '1';
            complete <= '0';
         else
            complete <= '1';
         end if;
      end if;
   end process counter;
end behavioural;

-- entity declaration
entity rowscan is
   port(
      clock,reset,enable : in std_logic;
      Q : inout std_logic_vector(3 downto 0)
   );
end rowscan;

architecture behaviour of rowscan is
begin
   scan : process(clock,reset)
   begin
      if reset = '1' then
         Q <= "0111";
      elsif falling_edge(clock) and (enable = '1') then
         if Q = "0111" then
            Q <= "1011";
         elsif Q = "1011" then
            Q <= "1101";
         elsif Q = "1101" then
            Q <= "1110";
         elsif Q = "1110" then
            Q <= "0111";
         end if;
      end if;
   end process scan;
end behaviour;
purpose: takes the system clock snd drops it to 2mS clock.
--	type : sequential.
-- inputs : sys_clk, restn.
-- outputs : clk.
clock_div : process (sys_clk, restn)
begin -- process clock_div
	if resetn = '0' then
		divider	<= to unsigned(0, 16);
		clk		<= '0';
	elseif sys_clk'event and sys_clk = '1' then -- raising clock edge
		if divider = X"8235" then
			clk		<= not clk;
			divider 	<= to_unsigned(0, 16);
		else 
			divider	<= divider + to_unsigned(1, 16);
		end if;
	end if
end process clock_div;

   state_logic : process(clock,reset)
   begin
      if reset = '1' then
         state <= w_press1;
      elsif(rising_edge(clock)) then
         state <= next_state;
      end if;
   end process state_logic;

end mixed;