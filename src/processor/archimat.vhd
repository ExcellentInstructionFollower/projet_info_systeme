library IEEE;
use IEEE.STD_LOGIC_UNSIGN.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU (Arithmetic Logic Unit)
entity alu is
    port(
        a, b : in  std_logic_vector(3 downto 0);
        op   : in  std_logic_vector(1 downto 0);
        y    : out std_logic_vector(3 downto 0);
        zf   : out std_logic
    );
end alu;

architecture rtl of alu is
begin
    y  <= a + b when op = "00" else
          a - b when op = "01" else
          a and b when op = "10" else
          a or b;

    zf <= '1' when y = "0000" else '0';
end rtl;


-- 4 * 8‑bits register bank
entity register_bank is
    port(
        clk  : in  std_logic;
        we   : in  std_logic;
        addr : in  std_logic_vector(1 downto 0);
        din  : in  std_logic_vector(7 downto 0);
        dout : out std_logic_vector(7 downto 0)
    );
end register_bank;

architecture rtl of register_bank is
    type rarray is array(0 to 3) of std_logic_vector(7 downto 0);
    signal r : rarray := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) and we = '1' then
            r(to_integer(unsigned(addr))) <= din;
        end if;
    end process;

    dout <= r(to_integer(unsigned(addr)));
end rtl;
