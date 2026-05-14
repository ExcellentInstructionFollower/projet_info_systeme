library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    port(
        clk     : in  std_logic;
        rst     : in  std_logic;                      -- actif bas
        rw      : in  std_logic;                      -- 1 = read, 0 = write
        addr    : in  std_logic_vector(7 downto 0);
        data_in : in  std_logic_vector(7 downto 0);
        data_out: out std_logic_vector(7 downto 0)
    );
end data_memory;

architecture rtl of data_memory is

    type mem_array is array (0 to 255) of std_logic_vector(7 downto 0);
    signal memory : mem_array := (others => (others => '0'));

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                memory <= (others => (others => '0'));
            elsif rw = '0' then
                memory(to_integer(unsigned(addr))) <= data_in;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if falling_edge(clk) then --so that B catches up to the other signals in MAWB
            if rw = '1' then
                data_out <= memory(to_integer(unsigned(addr)));
            end if;
        end if;
    end process;
end rtl;

------------------------------------------------------------------
------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity inst_memory is
    port(
        clk      : in  std_logic;
        addr     : in  std_logic_vector(7 downto 0);
        Aout, Bout, Cout, OPout  : out std_logic_vector(7 downto 0)
    );
end inst_memory;

architecture rtl of inst_memory is
    type mem_array is array (0 to 255) of std_logic_vector(31 downto 0);
    
    -- hardcoded example (form: OP A B C)
    signal memory : mem_array := (
        0 => X"06050344",
        1 => X"06024577",
        2 => X"05060544",
        3 => X"00000000",
        4 => X"FFFFFFFF",
        5 => X"01070502",
        6 => X"02080205",
        7 => X"03090205",
        8 => X"0e010500",
        9 => X"0d0a0100",
        others => (others => '0')
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            OPout <= memory(to_integer(unsigned(addr)))(31 downto 24);
            Aout <= memory(to_integer(unsigned(addr)))(23 downto 16);
            Bout <= memory(to_integer(unsigned(addr)))(15 downto 8);
            Cout <= memory(to_integer(unsigned(addr)))(7 downto 0);
        end if;
    end process;
end rtl;