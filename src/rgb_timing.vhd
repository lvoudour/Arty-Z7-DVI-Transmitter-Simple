library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity rgb_timing is
  port(
    clk_i   : in  std_logic;
    hsync_o : out std_logic;
    vsync_o : out std_logic;
    blank_o : out std_logic
  );
end entity rgb_timing;

architecture rtl of rgb_timing is
  constant C_RES_X   : integer := 1280;
  constant C_RES_Y   : integer := 720;
  
  constant C_HFRONT  : integer := 110;
  constant C_HSYNC   : integer := 40;
  constant C_HBACK   : integer := 220;
  constant C_HBLANK  : integer := C_HFRONT + C_HSYNC + C_HBACK;

  constant C_VFRONT  : integer := 5;
  constant C_VSYNC   : integer := 5;
  constant C_VBACK   : integer := 20;
  constant C_VBLANK  : integer := C_VFRONT + C_VSYNC + C_VBACK;

  constant C_TOTAL_X : integer := C_RES_X + C_HBLANK;
  constant C_TOTAL_Y : integer := C_RES_Y + C_VBLANK;

  signal x : unsigned(11 downto 0) := (others => '0');
  signal y : unsigned(11 downto 0) := (others => '0');
begin
  
  timing_p : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if x = C_RES_X-1 then
        blank_o <= '1';
      elsif x = C_TOTAL_X-1 and (y < C_RES_Y-1 or y = C_TOTAL_Y-1) then
        blank_o <= '0';            
      end if;
      
      if x = C_RES_X+C_HFRONT-1 then
        hsync_o <= '1';
      elsif x = C_RES_X+C_HFRONT+C_HSYNC-1 then
        hsync_o <= '0';
      end if;

      if x = C_TOTAL_X-1 then 
        x <= (others => '0');
        
        if y = C_RES_Y+C_VFRONT-1 then
            vsync_o  <= '1';
        elsif y = C_RES_Y+C_VFRONT+C_VSYNC-1 then
            vsync_o  <= '0';
        end if;
        
        if y = C_TOTAL_Y-1 then
            y <= (others => '0');
        else
            y <= y +1;
        end if;
      else
        x <= x + 1;
      end if;    
    end if;
  end process;

end architecture;