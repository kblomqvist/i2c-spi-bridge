library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i2c is
  type i2c_state is (idle, start, read, write, wait_ack, ack, nak, stop);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c.all;

entity i2c_master is

port(
  clk : in std_logic;     -- Bus speed is clk/2
  scl : inout std_logic;  -- Bus clock pin
  sda : inout std_logic;  -- Bus data pin
  state: inout i2c_state;
  start_n : in std_logic; -- Issues start from hi->lo transition
  reset_n : in std_logic;
  shift_register : in std_logic_vector(7 downto 0));
end i2c_master;

architecture behv of i2c_master is
  signal scl_i : std_logic;

begin
  process(clk, reset_n)
    variable rwbit : std_logic;
    variable i : integer range 0 to 7;

  begin
    if reset_n='0' then
      sda <= 'Z';
      scl <= 'Z';
      state <= idle;

    elsif rising_edge(clk) then
      case state is
      when idle =>
        sda <= 'Z';
        if start_n='0' then
          i := 7;
          sda <= '0';
          rwbit := shift_register(0);
          state <= write;
        end if;
      when write =>
        if scl='0' and shift_register(i)='0' then
          sda <= '0';
        elsif scl='0' and shift_register(i)='1' then
          sda <= 'Z';
        else -- SCL is high. It's time to index next bit.
          if i=0 then
            state <= wait_ack;
          else
            i := i - 1;
          end if;
        end if;
      when wait_ack =>
        i := 7;
        sda <= 'Z';
        if scl='Z' then
          if sda='0' then
            state <= ack;
          else
            state <= nak;
          end if;
        end if;
      when stop =>
        if scl='0' then
          sda <= '0';
        elsif scl='Z' and sda='0' then
          sda <= 'Z';
          state <= idle;
        end if;
      when others =>
        state <= state;
      end case;

    elsif falling_edge(clk) then
      scl_i <= not scl_i;
      case state is
      when idle =>
        scl_i <= '1';
      when ack =>
        if rwbit='1' then
          state <= read;
        else
          state <= write;
        end if;
      when nak =>
        state <= stop;
      when others =>
        state <= state;
      end case;
    end if;
  end process;

  scl <= '0' when scl_i='0' else 'Z';

end behv;
