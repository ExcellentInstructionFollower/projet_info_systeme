library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_bank is
    port(
        addrA : in  std_logic_vector(3 downto 0);
        addrB : in  std_logic_vector(3 downto 0);
        addrW : in  std_logic_vector(3 downto 0);
        W     : in  std_logic;                      -- actif haut
        data : in  std_logic_vector(7 downto 0);
        rst   : in  std_logic;                      -- actif bas
        clk   : in  std_logic;
        QA    : out std_logic_vector(7 downto 0);
        QB    : out std_logic_vector(7 downto 0)
    );
end register_bank;

architecture rtl of register_bank is

    type reg_array is array (0 to 15) of std_logic_vector(7 downto 0);
    signal regs : reg_array := (others => (others => '0'));
    
    signal data_read_a : std_logic_vector(7 downto 0);
    signal data_read_b : std_logic_vector(7 downto 0);

begin
    process(clk)
    begin

        if rising_edge(clk) then

            if rst = '0' then
                for i in 0...15
                    regs(i) <= (others => '0');
            
            elsif W = '1' then
                regs(to_integer(unsigned(addrW))) <= data;
            end if;

        end if;

    end process;

    data_read_a <= regs(to_integer(unsigned(addrA)));
    data_read_b <= regs(to_integer(unsigned(addrB)));
    
    process(W, addrW, addrA, addrB, data, data_read_a, data_read_b)
    begin

        if (W = '1' and addrW = addrA) then
            QA <= data;
        else
            QA <= data_read_a;
        end if;

        if (W = '1' and addrW = addrB) then
            QB <= data;
        else
            QB <= data_read_b;
        end if;
        
    end process;

end rtl;