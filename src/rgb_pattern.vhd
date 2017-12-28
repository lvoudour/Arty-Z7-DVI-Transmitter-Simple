library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity rgb_pattern is
  port(
    clk_i       : in  std_logic;
    hsync_i     : in  std_logic;
    vsync_i     : in  std_logic;
    blank_i     : in  std_logic;
    hsync_o     : out std_logic;
    vsync_o     : out std_logic;
    blank_o     : out std_logic;
    red_o       : out std_logic_vector(7 downto 0);
    green_o     : out std_logic_vector(7 downto 0);
    blue_o      : out std_logic_vector(7 downto 0)
  );
end entity rgb_pattern;

architecture rtl of rgb_pattern is
  -- Update color every 120 frames (every 2 seconds at 60Hz)
  constant C_TIMER_MAX : integer := 120;

  type color_rom_t is array (natural range <>) of std_logic_vector(23 downto 0);
  signal color_rom_r : color_rom_t(0 to 3) := (x"3F52E3", x"F6F6F6", x"EFE891", x"F12D2D");
  signal color_id_r  : integer range 0 to 3 := 0;
  signal timer_r     : integer range 0 to C_TIMER_MAX-1 := 0;
  signal vsync_r     : std_logic := '0';
begin


  update_p: process(clk_i)
  begin
    if rising_edge(clk_i) then
      vsync_r <= vsync_i;
      if vsync_i = '1' and vsync_r='0'  then
        if (timer_r=C_TIMER_MAX-1) then
          color_id_r <= color_id_r + 1;
          timer_r <= 0;
        else
          timer_r <= timer_r + 1;
        end if;
      end if;

    end if;
  end process;

  draw_p: process(clk_i)
  begin
    if rising_edge(clk_i) then
      hsync_o <= hsync_i;
      vsync_o <= vsync_i;
      if blank_i = '0' then
        red_o   <= color_rom_r(color_id_r)(23 downto 16);
        green_o <= color_rom_r(color_id_r)(15 downto 8);
        blue_o  <= color_rom_r(color_id_r)(7 downto 0);
        blank_o <= '0';
      else
        red_o   <= (others => '0');
        green_o <= (others => '0');
        blue_o  <= (others => '0');   
        blank_o <= '1';
      end if;
    end if;
  end process;

end architecture;