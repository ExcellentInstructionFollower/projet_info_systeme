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
        if rising_edge(clk) then
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
        inst_out : out std_logic_vector(7 downto 0)
    );
end inst_memory;

architecture rtl of inst_memory is
    type mem_array is array (0 to 255) of std_logic_vector(7 downto 0);
    
    -- hardcoded example
    signal memory : mem_array := (
        0 => X"01",
        1 => X"02",
        2 => X"03",
        3 => X"00",
        4 => X"FF",
        others => X"00"
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            inst_out <= memory(to_integer(unsigned(addr)));
        end if;
    end process;
end rtl;