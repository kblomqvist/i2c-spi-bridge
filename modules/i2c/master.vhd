-------------------------------------------------------
-- Design      : I2c MAster
-- Author      : Kim Blomqvist
-------------------------------------------------------
  
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------

entity i2c is

port(
  scl : inout std_logic;  -- Bus clock pin
  sda : inout std_logic;  -- Bus data pin
  clk : in std_logic;     -- Bus speed is clk/2
  start_n : in std_logic; -- Issues start from hi->lo and
                          -- stop from lo->hi transitio
--ack : out std_logic; -- High when ACK in bus goes low after next cycle
  reset_n : in std_logic;
  shift_register : inout std_logic_vector(7 downto 0));
end i2c;

-------------------------------------------------------

architecture behv of i2c is
  type state_t is (idle, sread, swrite, sstop);
  signal state : state_t := idle;
  signal scl_i : std_logic;

begin

  process(clk, reset_n) -- Handles SDA and state
    variable rwbit : std_logic;
    variable i : integer range 0 to 7;
  begin
    if reset_n='0' then
      sda <= 'Z';
      state <= idle;
    elsif rising_edge(clk) then -- CLK RISING EDGE
      case state is
      when idle =>
        sda <= 'Z';
        if start_n='0' then
          i := 7;
          sda <= '0';
          rwbit := shift_register(0);
          state <= swrite;
        end if;
      when swrite =>
        if scl='0' and shift_register(i)='0' then
          sda <= '0';
        elsif scl='0' and shift_register(i)='1' then
          sda <= 'Z';
        else -- SCL is high. It's time to index next bit.
          if i > 0 then
          i := i - 1;
          end if;
        end if;
      when sread =>
        if scl='1' then
          i := i - 1; -- Next bit
        end if;

--        state <= ack when (i=0) else state;
--        state <= sread when rwbit='1' else state;
      --when ack =>
        -- implement
      when others =>
        state <= state;
      end case;
    elsif falling_edge(clk) then -- CLK FALLING EDGE
      case state is
      when sread =>
--        shift_register(i) <= sda when scl='1';
--        state <= ack when i=0;
        state <= state;
      when others =>
        state <= state;
      end case;
    end if;
  end process;

  process(clk, reset_n) -- Handles SCL according to state
  begin
    if reset_n='0' then
      scl_i <= '1';
    elsif falling_edge(clk) then
      case state is
      when idle =>
        scl_i <= '1';

      when others =>
        scl_i <= not scl_i;
      end case;
    end if;
  end process;
  scl <= '0' when scl_i='0' else 'Z';

end behv;

-------------------------------------------------------
