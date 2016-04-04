library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package i2c is
  type i2c_state is (IDLE, READ, WRITE, WACK, ACK, NAK, STOP);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c.all;

entity i2c_master is

port(
  clk : in std_logic;     -- Bus speed is clk/2
  scl : out std_logic;    -- Bus clock pin
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
      scl_i <= '1';
      state <= IDLE;

    elsif rising_edge(clk) then
      case state is
      when IDLE =>
        sda <= 'Z';
        if start_n='0' then
          i := 7;
          sda <= '0';
          rwbit := shift_register(0);
          state <= WRITE;
        end if;
      when WRITE =>
        if scl_i='0' and shift_register(i)='0' then
          sda <= '0';
        elsif scl_i='0' and shift_register(i)='1' then
          sda <= 'Z';
        else -- SCL is high. It's time to index next bit.
          if i=0 then
            i := 7;
            state <= WACK;
          else
            i := i - 1;
          end if;
        end if;
      when WACK =>
        sda <= 'Z';
        if scl_i='1' then
          if sda='0' then
            state <= ACK;
          else
            state <= NAK;
          end if;
        end if;
      when STOP =>
        if scl_i='0' then
          sda <= '0';
        elsif scl_i='1' and sda='0' then
          sda <= 'Z';
          state <= IDLE;
        end if;
      when others =>
        state <= state;
      end case;

    elsif falling_edge(clk) then
      scl_i <= not scl_i;
      case state is
      when IDLE =>
        scl_i <= '1';
      when ACK =>
        if rwbit='1' then
          state <= READ;
        else
          state <= WRITE;
        end if;
      when NAK =>
        state <= STOP;
      when others =>
        state <= state;
      end case;
    end if;
  end process;

  scl <= '0' when scl_i='0' else 'Z';

end behv;
