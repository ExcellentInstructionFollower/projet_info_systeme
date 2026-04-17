----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 10:13:11 AM
-- Design Name: 
-- Module Name: data_path - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pipeline_buffer is
    Port ( Ain, Bin, Cin, OPin : in STD_LOGIC_VECTOR (7 downto 0);
           Aout, Bout, Cout, OPout : out STD_LOGIC_VECTOR (7 downto 0);
           CLK, RST : in STD_LOGIC);
end pipeline_buffer;

architecture Behavioral of pipeline_buffer is

signal Abuf, Bbuf, Cbuf, OPbuf : STD_LOGIC_VECTOR (7 downto 0);

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '0' then
                Abuf <= (others => '0');
                Bbuf <= (others => '0');
                Cbuf <= (others => '0');
                OPbuf <= (others => '0');
            else 
                Abuf <= Ain;
                Bbuf <= Bin;
                Cbuf <= Cin;
                OPbuf <= OPin;
            end if;
        end if;
    end process;
    
    process(CLK)
    begin
        if rising_edge(CLK) then
            Aout <= Abuf;
            Bout <= Bbuf;
            Cout <= Cbuf;
            OPout <= OPbuf;
        end if;
    end process;

end Behavioral;

------------------------------------------------------------------
------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux is
    port(
        SelectA     : in  std_logic;
        InA, InB    : in  std_logic_vector(7 downto 0);
        S : out std_logic_vector(7 downto 0)
    );
end mux;

architecture rtl of mux is

begin
    process(SelectA, InA, InB)
    begin
        if SelectA = '1' then
            S <= InA;
        else
            S <= InB;
        end if;
    end process;
end rtl;
