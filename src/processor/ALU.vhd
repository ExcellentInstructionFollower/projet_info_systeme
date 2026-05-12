library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
--use IEEE.NUMERIC_STD.ALL;

-- ALU (Arithmetic Logic Unit)
entity alu is
    port(
        A, B : in  std_logic_vector(7 downto 0);
        Ctrl_ALU   : in  std_logic_vector(2 downto 0); -- 001 = Add, 011 = Sub, 010 = MUL, 100 = DIV
        S    : out std_logic_vector(7 downto 0);
        N, O, Z, C   : out std_logic
    );
end alu;

architecture rtl of alu is
    signal Aext, Bext : std_logic_vector(15 downto 0);--std_logic_vector(15 downto 0);
    signal Sext : std_logic_vector(15 downto 0);
begin
    Aext <= X"00" & A;
    Bext<= X"00" & B;
    
    Sext  <= Aext + Bext when Ctrl_ALU = "001" else
          Aext - Bext when Ctrl_ALU = "011" else
          A * B when Ctrl_ALU = "010" else
          --std_logic_vector(Aext / Bext) when Ctrl_ALU = "011" and Bext /= X"0000" else
          X"0000";
    
       
    S <= Sext(7 downto 0);
    Z <= '0' when Sext(7 downto 0) /= X"00" else '1';
    C <= '1' when (Sext(15 downto 8) = X"01" or Sext(15 downto 8) = X"FE") and (Ctrl_ALU = "000" or Ctrl_ALU = "001") else '0';
    O <= '1' when Sext(15 downto 8) /= X"00" and Ctrl_ALU = "010" else '0';
    N <= '1' when Sext(15) = '1' else '0';
end rtl;

