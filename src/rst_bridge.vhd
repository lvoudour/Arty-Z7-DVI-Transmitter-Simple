library ieee;
use ieee.std_logic_1164.all;

entity rst_bridge is
  generic(
    G_ARST_POLARITY : std_logic := '1';
    G_SRST_POLARITY : std_logic := '1'
  );
  port(
    arst_in  : in  std_logic;
    sclk_in  : in  std_logic;
    srst_out : out std_logic
  );
end entity rst_bridge;

architecture rtl of rst_bridge is
  signal srst_d0_r : std_logic;
  signal srst_d1_r : std_logic;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of srst_d0_r, srst_d1_r: signal is "TRUE"; 
begin

  reset_dff_p : process(arst_in, sclk_in)
  begin
    if (arst_in = G_ARST_POLARITY) then
      srst_d0_r <= G_SRST_POLARITY;
      srst_d1_r <= G_SRST_POLARITY;
    elsif rising_edge(sclk_in) then
      srst_d0_r <= not G_SRST_POLARITY;
      srst_d1_r <= srst_d0_r;
    end if;
  end process;

  srst_out <= srst_d1_r;

end architecture;