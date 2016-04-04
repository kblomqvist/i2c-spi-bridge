----------------------------------------------------------
-- Design  : I2c MAster
-- Author  : Kim Blomqvist
----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c.all;

entity i2c_master_tb is     -- entity declaration
end i2c_master_tb;

-----------------------------------------------------------------------

architecture testbench of i2c_master_tb is

  signal t_scl: std_logic;
  signal t_sda: std_logic;
  signal t_clk:     std_logic;
  signal t_start:     std_logic;
  signal t_reset:     std_logic;
  signal t_sr:         std_logic_vector(7 downto 0);

  signal t_clear:     std_logic;
  signal t_count:     std_logic;
  signal t_state: i2c_state;
  signal foo: std_logic_vector(7 downto 0);

begin

  i2c_u: entity work.i2c_master port map (t_clk, t_scl, t_sda, t_state, t_start, t_reset, t_sr);
  foo <= std_logic_vector(to_unsigned(i2c_state'pos(t_state), 8));

  process
  begin -- clock (200 kHz)
    t_clk <= '0';
    wait for 2 ns;
    t_clk <= '1';
    wait for 2 ns;
  end process;

  process
  begin
    t_sr <= "11010010";
    t_start <= '1';
    t_reset <= '0';
    t_sda <= 'Z';
    wait for 3 ns;
    t_reset <= '1';
    wait for 3 ns;
    t_start <= '0';
    wait for 10 ns;
    t_start <= '0';
    wait for 58 ns;
    t_sda <= '0'; -- ACK
    wait for 8 ns;
    t_sda <= 'Z';
    t_sr <= "11110101";
    wait for 10 ns;
    t_start <= '1';

    report "Testbench of Adder completed successfully!"
    severity note;
  wait;

  end process;

end testbench;

----------------------------------------------------------------
