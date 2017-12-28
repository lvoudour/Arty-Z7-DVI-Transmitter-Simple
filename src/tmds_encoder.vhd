library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tmds_encoder is
  port(
    clk_i   : in  std_logic;                    -- pixel clock
    pixel_i : in  std_logic_vector(7 downto 0); -- pixel data
    ctrl_i  : in  std_logic_vector(1 downto 0); -- control data
    de_i    : in  std_logic;                    -- pixel data enable (not blanking)
    tmds_o  : out std_logic_vector(9 downto 0)
  );
end entity tmds_encoder;

architecture rtl of tmds_encoder is
  signal qm_xor     : std_logic_vector(8 downto 0) := (others=>'0');
  signal qm_xnor    : std_logic_vector(8 downto 0) := (others=>'0');
  signal ones_pixel : unsigned(3 downto 0) := (others=>'0');
  signal qm         : std_logic_vector(8 downto 0) := (others=>'0');
  
  signal de_r       : std_logic := '0';
  signal ctrl_r     : std_logic_vector(1 downto 0) := (others=>'0');
  signal qm_r       : std_logic_vector(8 downto 0) := (others=>'0');
  signal ones_qm_x  : unsigned(3 downto 0) := (others=>'0');
  signal bias_r     : integer range -8 to 8 := 0; -- 5 bits
  signal diff       : integer range -8 to 8 := 0; -- 5 bits
  signal tmds_r     : std_logic_vector(9 downto 0) := (others=>'0');

begin

  -- First stage: Transition minimized encoding

  qm_xor(0) <= pixel_i(0);
  qm_xor(8) <= '1';
  encode_xor: for n in 1 to 7 generate
  begin
    qm_xor(n) <= qm_xor(n-1) xor pixel_i(n);
  end generate;

  qm_xnor(0) <= pixel_i(0);
  qm_xnor(8) <= '0';
  encode_xnor: for n in 1 to 7 generate
  begin
    qm_xnor(n) <= qm_xnor(n-1) xnor pixel_i(n);
  end generate;

  -- count the number of ones in the symbol
  ones_pixel_p : process(pixel_i)
    variable sum : unsigned(3 downto 0);
  begin
    sum := (others=>'0');
    for n in 0 to 7 loop
      sum := sum + to_integer(unsigned(pixel_i(n downto n)));
    end loop;
    ones_pixel <= sum;
  end process;

  -- select encoding based on number of ones
  qm <= qm_xnor when (ones_pixel > 4) or (ones_pixel = 4 and pixel_i(0)='0') else qm_xor;

  -- Second stage: Fix DC bias

  qm_r_p : process(clk_i)
  begin
    if rising_edge(clk_i) then
      de_r   <= de_i;
      ctrl_r <= ctrl_i;
      qm_r   <= qm;
    end if;
  end process;

  -- count the number of ones in the encoded symbol
  ones_qm_p : process(qm_r)
    variable sum : unsigned(3 downto 0);
  begin
    sum := (others=>'0');
    for n in 0 to 7 loop
      sum := sum + to_integer(unsigned(qm_r(n downto n)));
    end loop;
    ones_qm_x <= sum;
  end process;

  -- Calculate the difference between the number of ones (n1) and number of zeros (n0) in the encoded symbol
  diff <= to_integer(ones_qm_x & '0') - 8; -- n1-n0 = 2*n1 - 8

  tmds_p : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if (de_r = '0') then
        case ctrl_r is
          when "00"   => tmds_r <= "1101010100";
          when "01"   => tmds_r <= "0010101011";
          when "10"   => tmds_r <= "0101010100";
          when others => tmds_r <= "1010101011";
        end case;
        bias_r <= 0;
      else
        if (bias_r = 0) or (diff = 4) then
          if (qm_r(8) = '0') then
            tmds_r <= "10" & (not qm_r(7 downto 0));
            bias_r <= bias_r - diff;
          else
            tmds_r <= "01" & qm_r(7 downto 0);
            bias_r <= bias_r + diff;
          end if;
        else
          if ((bias_r > 0) and (diff > 4)) or
             ((bias_r < 0) and (diff < 4)) then
            tmds_r <= '1' & qm_r(8) & (not qm_r(7 downto 0));
            if (qm_r(8) = '0') then
              bias_r <= bias_r - diff;
            else
              bias_r <= bias_r - diff + 2;
            end if;
          else
            tmds_r <= '0' & qm_r;
            if (qm_r(8) = '0') then
              bias_r <= bias_r + diff;
            else
              bias_r <= bias_r + diff - 2;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  tmds_o <= tmds_r;

end architecture;