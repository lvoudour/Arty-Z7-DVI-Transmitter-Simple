library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity rgb_to_dvi is
  port(
    sclk_i      : in  std_logic;
    sclk_x5_i   : in  std_logic;
    pixel_clk_i : in  std_logic;
    arst_i      : in  std_logic;
    
    red_i       : in  std_logic_vector(7 downto 0);
    green_i     : in  std_logic_vector(7 downto 0);
    blue_i      : in  std_logic_vector(7 downto 0);
    hsync_i     : in  std_logic;
    vsync_i     : in  std_logic;
    blank_i     : in  std_logic;

    dvi_clk_p_o : out std_logic;
    dvi_clk_n_o : out std_logic;
    dvi_tx0_p_o : out std_logic;
    dvi_tx0_n_o : out std_logic;
    dvi_tx1_p_o : out std_logic;
    dvi_tx1_n_o : out std_logic;
    dvi_tx2_p_o : out std_logic;
    dvi_tx2_n_o : out std_logic
  );
end entity rgb_to_dvi;

architecture rtl of rgb_to_dvi is

  type tmds_array is array (natural range <>) of std_logic_vector(9 downto 0);
  signal tmds_x : tmds_array(0 to 2) := (others=>(others=>'0'));
  signal c0 : std_logic_vector(1 downto 0) := (others=>'0');
  signal c1 : std_logic_vector(1 downto 0) := (others=>'0');
  signal c2 : std_logic_vector(1 downto 0) := (others=>'0');
  signal de : std_logic := '0';
begin

  de <= not blank_i;
  c0 <= (vsync_i & hsync_i);
  tmds_0_inst : entity work.tmds_encoder
    port map(
      clk_i   => pixel_clk_i,
      pixel_i => blue_i,
      ctrl_i  => c0,
      de_i    => de,
      tmds_o  => tmds_x(0)
    );

  tmds_1_inst : entity work.tmds_encoder
    port map(
      clk_i   => pixel_clk_i,
      pixel_i => green_i,
      ctrl_i  => c1,
      de_i    => de,
      tmds_o  => tmds_x(1)
    );

  tmds_2_inst : entity work.tmds_encoder
    port map(
      clk_i   => pixel_clk_i,
      pixel_i => red_i,
      ctrl_i  => c2,
      de_i    => de,
      tmds_o  => tmds_x(2)
    );

  oserdes_tx0_inst : entity work.oserdes_ddr_10_1
    port map(
      clk_i     => sclk_i,
      clk_x5_i  => sclk_x5_i,
      arst_i    => arst_i,
      pdata_i   => tmds_x(0),
      sdata_p_o => dvi_tx0_p_o,
      sdata_n_o => dvi_tx0_n_o
    );

  oserdes_tx1_inst : entity work.oserdes_ddr_10_1
    port map(
      clk_i     => sclk_i,
      clk_x5_i  => sclk_x5_i,
      arst_i    => arst_i,
      pdata_i   => tmds_x(1),
      sdata_p_o => dvi_tx1_p_o,
      sdata_n_o => dvi_tx1_n_o
    );

  oserdes_tx2_inst : entity work.oserdes_ddr_10_1
    port map(
      clk_i     => sclk_i,
      clk_x5_i  => sclk_x5_i,
      arst_i    => arst_i,
      pdata_i   => tmds_x(2),
      sdata_p_o => dvi_tx2_p_o,
      sdata_n_o => dvi_tx2_n_o
    );

  oserdes_clk_inst : entity work.oserdes_ddr_10_1
    port map(
      clk_i     => sclk_i,
      clk_x5_i  => sclk_x5_i,
      arst_i    => arst_i,
      pdata_i   => "0000011111", -- clock doesn't need tmds encoding, just output a pulse
      sdata_p_o => dvi_clk_p_o,
      sdata_n_o => dvi_clk_n_o
    );

end architecture;