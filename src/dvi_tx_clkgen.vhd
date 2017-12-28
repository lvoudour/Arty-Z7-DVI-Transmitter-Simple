--------------------------------------------------------------------------------
--
--  Arty-Z7 DVI Transmitter Clock Generator
--
--  
--
--------------------------------------------------------------------------------
--  This work is licensed under the MIT License (see the LICENSE file for terms)
--  Copyright 2016 Lymperis Voudouris 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;

entity dvi_tx_clkgen is
  port(
    clk_i       : in  std_logic; -- 125 MHz reference clock
    arst_i      : in  std_logic; -- asynchronous reset (from board pin)
    locked_o    : out std_logic; -- synchronous to reference clock
    pixel_clk_o : out std_logic; -- pixel clock
    sclk_o      : out std_logic; -- serdes clock (framing clock)
    sclk_x5_o   : out std_logic  -- serdes clock x5 (bit clock)
  );
end entity dvi_tx_clkgen;

architecture rtl of dvi_tx_clkgen is

  signal clkfb_x            : std_logic;
  signal refrst_x           : std_logic;
  signal mmcm_locked_x      : std_logic;
  signal mmcm_locked_sync_x : std_logic;
  signal mmcm_rst_r         : std_logic;
  signal bufr_rst_r         : std_logic;
  signal pixel_clk_x        : std_logic;
  signal sclk_x5_x          : std_logic;

  type fsm_mmcm_rst_t is (WAIT_LOCK, LOCKED);
  signal state_mmcm_rst : fsm_mmcm_rst_t := WAIT_LOCK;
begin
  
  -- The reset bridge will make sure we can use the async rst
  -- safely in the reference clock domain
  refrst_inst : entity work.rst_bridge
    port map(
      arst_in  => arst_i,
      sclk_in  => clk_i,
      srst_out => refrst_x
    );

  -- sync MMCM lock signal to the reference clock domain
  sync_mmcm_locked_inst : entity work.sync_dff
    port map(
      async_in => mmcm_locked_x,
      sclk_in  => clk_i,
      sync_out => mmcm_locked_sync_x
    );

  -- Need to generate an MMCM reset pulse >= 5 ns (Xilinx DS191).
  -- We can use the reference clock to create the pulse. The fsm
  -- below will only work is the reference clk frequency is < 200MHz.
  -- The BUFR needs to be reset any time the MMCM acquires lock.
  fsm_mmcm_rst_p : process(refrst_x, clk_i)
  begin
    if (refrst_x='1') then
      state_mmcm_rst <= WAIT_LOCK;
      mmcm_rst_r <= '1';
      bufr_rst_r <= '0';
    elsif rising_edge(clk_i) then
      mmcm_rst_r <= '0';
      bufr_rst_r <= '0';
      case state_mmcm_rst is
        when WAIT_LOCK =>
          if (mmcm_locked_sync_x='1') then
            bufr_rst_r     <= '1';
            state_mmcm_rst <= LOCKED;
          end if;

        when LOCKED =>
          if (mmcm_locked_sync_x='0') then
            mmcm_rst_r     <= '1';
            state_mmcm_rst <= WAIT_LOCK;
          end if;
      end case;

    end if;
  end process;

  
  mmcme2_adv_inst : MMCME2_ADV
    generic map (
      BANDWIDTH            => "OPTIMIZED",
      CLKFBOUT_MULT_F      => 12.0,
      CLKFBOUT_PHASE       => 0.0,
      CLKIN1_PERIOD        => 8.0,  -- 125 MHz
      CLKOUT0_DIVIDE_F     => 2.0,  -- 1.0 for 1080p
      CLKOUT1_DIVIDE       => 10,   -- 5 for 1080p
      COMPENSATION         => "ZHOLD",
      DIVCLK_DIVIDE        => 2,
      REF_JITTER1          => 0.0
    )
    port map (
      CLKOUT0              => sclk_x5_x,
      CLKOUT0B             => open,
      CLKOUT1              => pixel_clk_x,
      CLKOUT1B             => open,
      CLKOUT2              => open,
      CLKOUT2B             => open,
      CLKOUT3              => open,
      CLKOUT3B             => open,
      CLKOUT4              => open,
      CLKOUT5              => open,
      CLKOUT6              => open,
      CLKFBOUT             => clkfb_x,
      CLKFBOUTB            => open,

      CLKIN1               => clk_i,
      CLKIN2               => '0',
      CLKFBIN              => clkfb_x,
      CLKINSEL             => '1',

      DCLK                 => '0',
      DEN                  => '0',
      DWE                  => '0',
      DADDR                => (others=>'0'),
      DI                   => (others=>'0'),
      DO                   => open,
      DRDY                 => open,

      PSCLK                => '0',
      PSEN                 => '0',
      PSINCDEC             => '0',
      PSDONE               => open,

      LOCKED               => mmcm_locked_x,
      PWRDWN               => '0',
      RST                  => mmcm_rst_r,
      CLKFBSTOPPED         => open,
      CLKINSTOPPED         => open
    );

  bufio_inst : BUFIO
    port map (
      O => sclk_x5_o, 
      I => sclk_x5_x
    );

  -- If the clock to the BUFR is stopped, then a reset (CLR) 
  -- must be applied after the clock returns (see Xilinx UG472)
  bufr_inst : BUFR
    generic map (
      BUFR_DIVIDE => "5",
      SIM_DEVICE => "7SERIES"
    )
    port map (
      O   => sclk_o,
      CE  => '1',
      CLR => bufr_rst_r,
      I   => sclk_x5_x
    );


  -- The tools will issue a warning that pixel clock is not 
  -- phase aligned to sclk_x, sclk_x5_x. We can safely
  -- ignore it as we don't care about the phase relationship
  -- of the pixel clock to the sampling clocks.
  bufg_inst : BUFG
    port map (
      O => pixel_clk_o,
      I => pixel_clk_x
    );

  locked_p : process(mmcm_locked_x, clk_i)
  begin
    if (mmcm_locked_x='0') then
      locked_o <= '0';
    elsif rising_edge(clk_i) then
      -- Raise locked only after BUFR has been reset
      if (bufr_rst_r='1') then
        locked_o <= '1';
      end if;
    end if;
  end process;

end architecture;