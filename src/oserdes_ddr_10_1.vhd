library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity oserdes_ddr_10_1 is
  port(
    clk_i         : in  std_logic;
    clk_x5_i      : in  std_logic;
    arst_i        : in  std_logic;
    pdata_i       : in  std_logic_vector(9 downto 0);
    sdata_p_o     : out std_logic;
    sdata_n_o     : out std_logic
  );
end entity oserdes_ddr_10_1;

architecture rtl of oserdes_ddr_10_1 is

  signal rst_x    : std_logic;
  signal sdout_x  : std_logic;
  signal shift1_x : std_logic;
  signal shift2_x : std_logic;
begin
  
  oserdes_arst_inst : entity work.rst_bridge
    port map(
      arst_in  => arst_i,
      sclk_in  => clk_i,
      srst_out => rst_x
    );

  oserdes2_master_inst : OSERDESE2
    generic map (
      DATA_RATE_OQ   => "DDR",
      DATA_RATE_TQ   => "SDR",
      DATA_WIDTH     => 10,
      SERDES_MODE    => "MASTER",
      TBYTE_CTL      => "FALSE",
      TBYTE_SRC      => "FALSE",
      TRISTATE_WIDTH => 1
    )
    port map (
      OFB       => open,
      OQ        => sdout_x,
      SHIFTOUT1 => open,
      SHIFTOUT2 => open,
      TBYTEOUT  => open,
      TFB       => open,
      TQ        => open,
      CLK       => clk_x5_i,
      CLKDIV    => clk_i,
      D1        => pdata_i(0),
      D2        => pdata_i(1),
      D3        => pdata_i(2),
      D4        => pdata_i(3),
      D5        => pdata_i(4),
      D6        => pdata_i(5),
      D7        => pdata_i(6),
      D8        => pdata_i(7),
      OCE       => '1',
      RST       => rst_x,
      SHIFTIN1  => shift1_x,
      SHIFTIN2  => shift2_x,
      T1        => '0',
      T2        => '0',
      T3        => '0',
      T4        => '0',
      TBYTEIN   => '0',
      TCE       => '0'
    );

  oserdes2_slave_inst : OSERDESE2
    generic map (
      DATA_RATE_OQ   => "DDR",
      DATA_RATE_TQ   => "SDR",
      DATA_WIDTH     => 10,
      SERDES_MODE    => "SLAVE",
      TBYTE_CTL      => "FALSE",
      TBYTE_SRC      => "FALSE",
      TRISTATE_WIDTH => 1
    )
    port map (
      OFB       => open,
      OQ        => open,
      SHIFTOUT1 => shift1_x,
      SHIFTOUT2 => shift2_x,
      TBYTEOUT  => open,
      TFB       => open,
      TQ        => open,
      CLK       => clk_x5_i,
      CLKDIV    => clk_i,
      D1        => '0',
      D2        => '0',
      D3        => pdata_i(8),
      D4        => pdata_i(9),
      D5        => '0',
      D6        => '0',
      D7        => '0',
      D8        => '0',
      OCE       => '1',
      RST       => rst_x,
      SHIFTIN1  => '0',
      SHIFTIN2  => '0',
      T1        => '0',
      T2        => '0',
      T3        => '0',
      T4        => '0',
      TBYTEIN   => '0',
      TCE       => '0'
    );


  tmds_obufds_inst: OBUFDS
    generic map (
      IOSTANDARD => "TMDS_33"
    )
    port map (
      O  => sdata_p_o,
      OB => sdata_n_o,
      I  => sdout_x
    );

end architecture;