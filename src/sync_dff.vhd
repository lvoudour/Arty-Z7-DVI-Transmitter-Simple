library ieee;
use ieee.std_logic_1164.all;

entity sync_dff is
  port(
    async_in : in  std_logic;
    sclk_in  : in  std_logic;
    sync_out : out std_logic
  );
end entity sync_dff;

architecture rtl of sync_dff is
  signal sync_d0_r : std_logic;
  signal sync_d1_r : std_logic;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of sync_d0_r, sync_d1_r: signal is "TRUE"; 
begin

  sync_dff_p : process(sclk_in)
  begin
    if rising_edge(sclk_in) then
      sync_d0_r <= async_in;
      sync_d1_r <= sync_d0_r;
    end if;
  end process;

  sync_out <= sync_d1_r;

end architecture;