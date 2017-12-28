
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_dvi_tx is

end entity tb_dvi_tx;

architecture behv of tb_dvi_tx is

  signal clk_i       : std_logic;
  signal rst_i       : std_logic;
  signal dvi_clk_p_o : std_logic;
  signal dvi_clk_n_o : std_logic;
  signal dvi_tx0_p_o : std_logic;
  signal dvi_tx0_n_o : std_logic;
  signal dvi_tx1_p_o : std_logic;
  signal dvi_tx1_n_o : std_logic;
  signal dvi_tx2_p_o : std_logic;
  signal dvi_tx2_n_o : std_logic;

  constant C_CLK_PERIOD : time := 8 ns;

begin

  clk_gen_p : process
  begin
    clk_i <= '1';
    wait for C_CLK_PERIOD / 2;
    clk_i <= '0';
    wait for C_CLK_PERIOD / 2;
  end process;

  reset_gen_p : process
  begin
    rst_i <= '1', '0' after 20*C_CLK_PERIOD;
    wait;
  end process;

  DUT : entity work.dvi_tx
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
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