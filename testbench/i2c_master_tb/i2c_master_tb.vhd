----------------------------------------------------------
-- Design  : Simple testbench for an 8-bit VHDL counter
-- Author  : Javier D. Garcia-Lasheras
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;			 

entity i2c_master_tb is			-- entity declaration
end i2c_master_tb;

-----------------------------------------------------------------------

architecture testbench of i2c_master_tb is

    component i2c
    port(   
		  scl : inout std_logic;  -- Bus clock pin
		  sda : inout std_logic;  -- Bus data pin
		  clk : in std_logic;     -- Bus speed is clk/2
		  start_n : in std_logic; -- Issues start from hi->lo and
		                          -- stop from lo->hi transition
		  reset_n : in std_logic;
		  shift_register : inout std_logic_vector(7 downto 0)
    );
    end component;

    signal t_scl: std_logic;
    signal t_sda: std_logic;
    signal t_clk:     std_logic;
    signal t_start:     std_logic;
    signal t_reset:     std_logic;
    signal t_sr:         std_logic_vector(7 downto 0);

    signal t_clear:     std_logic;
    signal t_count:     std_logic;

begin
    
    i2c_u: i2c port map (t_scl, t_sda, t_clk, t_start, t_reset, t_sr);
	
    process				 
    begin -- clock (200 kHz)
		t_clk <= '0';
		wait for 2 ns;
		t_clk <= '1';
		wait for 2 ns;
    end process;
	
    process
    begin				
    	t_sr <= "10100101";
    	t_start <= '1';
    	t_reset <= '0';
		wait for 3 ns;	
    	t_reset <= '1';
		wait for 3 ns;	
    	t_start <= '0';

		report "Testbench of Adder completed successfully!" 
		severity note; 
	wait;
		
    end process;

end testbench;

----------------------------------------------------------------
