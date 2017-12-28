library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dvi_tx is
  port(
    clk_i         : in  std_logic; -- 125 MHz system clock
    rst_i         : in  std_logic; -- Any board button
    dvi_clk_p_o   : out std_logic;
    dvi_clk_n_o   : out std_logic;
    dvi_tx0_p_o   : out std_logic;
    dvi_tx0_n_o   : out std_logic;
    dvi_tx1_p_o   : out std_logic;
    dvi_tx1_n_o   : out std_logic;
    dvi_tx2_p_o   : out std_logic;
    dvi_tx2_n_o   : out std_logic
  );
end entity dvi_tx;

architecture rtl of dvi_tx is
  signal sclk_x        : std_logic;
  signal sclk_x5_x     : std_logic;
  signal pixel_clk_x   : std_logic;
  signal mmcm_locked_x : std_logic;
  signal rst_no_lock   : std_logic;
  signal hsync_x       : std_logic;
  signal vsync_x       : std_logic;
  signal blank_x       : std_logic;
  signal hsync_r0_x    : std_logic;
  signal vsync_r0_x    : std_logic;
  signal blank_r0_x    : std_logic;
  signal red_x         : std_logic_vector(7 downto 0);
  signal green_x       : std_logic_vector(7 downto 0);
  signal blue_x        : std_logic_vector(7 downto 0);
begin

   dvi_tx_clkgen_inst : entity work.dvi_tx_clkgen
     port map(
       clk_i         => clk_i,
       arst_i        => rst_i,
       locked_o      => mmcm_locked_x,
       pixel_clk_o   => pixel_clk_x,
       sclk_o        => sclk_x,
       sclk_x5_o     => sclk_x5_x
     );

   rgb_timing_inst : entity work.rgb_timing
     port map(
       clk_i   => pixel_clk_x,
       hsync_o => hsync_x,
       vsync_o => vsync_x,
       blank_o => blank_x
     );

   rgb_pattern_inst : entity work.rgb_pattern
     port map(
       clk_i       => pixel_clk_x,
       hsync_i     => hsync_x,
       vsync_i     => vsync_x,
       blank_i     => blank_x,
       hsync_o     => hsync_r0_x,
       vsync_o     => vsync_r0_x,
       blank_o     => blank_r0_x,
       red_o       => red_x,
       green_o     => green_x,
       blue_o      => blue_x
     );

   rst_no_lock <= rst_i or (not mmcm_locked_x);

   rgb_to_dvi_inst : entity work.rgb_to_dvi
     port map(
       sclk_i      => sclk_x,
       sclk_x5_i   => sclk_x5_x,
       pixel_clk_i => pixel_clk_x,
       arst_i      => rst_no_lock,
       
       red_i       => red_x,
       green_i     => green_x,
       blue_i      => blue_x,
       hsync_i     => hsync_r0_x,
       vsync_i     => vsync_r0_x,
       blank_i     => blank_r0_x,

       dvi_clk_p_o => dvi_clk_p_o,
       dvi_clk_n_o => dvi_clk_n_o,
       dvi_tx0_p_o => dvi_tx0_p_o,
       dvi_tx0_n_o => dvi_tx0_n_o,
       dvi_tx1_p_o => dvi_tx1_p_o,
       dvi_tx1_n_o => dvi_tx1_n_o,
       dvi_tx2_p_o => dvi_tx2_p_o,
       dvi_tx2_n_o => dvi_tx2_n_o
     );

end architecture;
