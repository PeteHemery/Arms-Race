library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad is
  port	  
	   (reset,sys_clk,new_data_ack 									: in std_logic;
      new_data													 			: out std_logic;
			debounce_reset													: inout std_logic;
   		keypad_row  													: in std_logic_vector(3 downto 0);
			keypad_col														: out std_logic_vector(3 downto 0);
			output_register												: out std_logic_vector(7 downto 0));
end keypad;

architecture netlist of keypad is

	component keypadctrl
		port
			(reset,new_data_ack,debounce_done,sys_clk			 			: in std_logic;
			new_data,col_scan,clk												: out std_logic;
	 		debounce_reset															: out std_logic;
   		keypad_row  															: in std_logic_vector(3 downto 0);
			keypad_col																: in std_logic_vector(3 downto 0);
			output_register														: out std_logic_vector(7 downto 0));
      
	end component;

  component colscan
      port
			(clk,reset,enable 	: in std_logic;
         Q 							: out std_logic_vector(3 downto 0));
			
   end component;

  component debounce
		port
			(clk,reset 				: in std_logic;
			complete 				: out std_logic);
			
   end component;
	
	component my_buf4
		port
		(
			col_in :  in  STD_LOGIC_VECTOR(3 downto 0);
			col_out :  out  STD_LOGIC_VECTOR(3 downto 0));
	end component;

   -- internal signals
   signal int_scan_enable				: std_logic;
   signal int_debounce_done			: std_logic;
   signal	clk							: std_logic;
	signal column_buffer					: std_logic_vector(3 downto 0);

--   signal add_out 						: std_logic_vector(7 downto 0);
  
	begin

   debounce0: debounce 
		port map
		(clk=>clk, reset=>debounce_reset, complete=>int_debounce_done);

   colscan0: colscan 
		port map
		(clk=>clk, reset=>reset, enable=>int_scan_enable, Q=>column_buffer);
 
	keypadctrl0: keypadctrl 
		port map
		(clk=>clk, sys_clk=>sys_clk, reset=>reset, new_data_ack=>new_data_ack,
      debounce_done=>int_debounce_done,
      new_data=>new_data,
      debounce_reset=>debounce_reset,
      col_scan=>int_scan_enable,
      keypad_row=>keypad_row,
		keypad_col=>column_buffer,
		output_register=>output_register);
		
	my_buf40: my_buf4
	   port map
	  (col_in=>column_buffer,
	  col_out=>keypad_col);

end netlist;
