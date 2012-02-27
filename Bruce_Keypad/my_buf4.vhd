-- Copyright (C) 1991-2011 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II"
-- VERSION		"Version 11.0 Build 208 07/03/2011 Service Pack 1 SJ Full Version"
-- CREATED		"Tue Feb 21 16:32:38 2012"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY my_buf4 IS 
	PORT
	(
		col_in :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		col_out :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END my_buf4;

ARCHITECTURE bdf_type OF my_buf4 IS 

COMPONENT alt_outbuf
	PORT(i : IN STD_LOGIC;
		 o : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	col_in_bus :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	col_out_bus :  STD_LOGIC_VECTOR(3 DOWNTO 0);


BEGIN 



b2v_inst3 : alt_outbuf
PORT MAP(i => col_in_bus(3),
		 o => col_out_bus(3));


b2v_inst4 : alt_outbuf
PORT MAP(i => col_in_bus(2),
		 o => col_out_bus(2));


b2v_inst5 : alt_outbuf
PORT MAP(i => col_in_bus(1),
		 o => col_out_bus(1));


b2v_inst6 : alt_outbuf
PORT MAP(i => col_in_bus(0),
		 o => col_out_bus(0));

col_out <= col_out_bus;
col_in_bus <= col_in;

END bdf_type;