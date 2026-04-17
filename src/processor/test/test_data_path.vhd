----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2026 10:39:02 AM
-- Design Name: 
-- Module Name: test_data_path - Behavioral
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

entity test_data_path is
--  Port ( );
end test_data_path;

architecture Behavioral of test_data_path is

    component pipeline_buffer
        Port ( Ain, OPin, Bin, Cin : in STD_LOGIC_VECTOR (7 downto 0);
               Aout, Bout, Cout, OPout : out STD_LOGIC_VECTOR (7 downto 0);
               CLK, RST : in STD_LOGIC);
    end component;
    
    component mux 
        port(
            SelectA     : in  std_logic;
            InA, InB    : in  std_logic_vector(7 downto 0);
            S : out std_logic_vector(7 downto 0)
        );
    end component;
    
    constant Clock_period : time := 10 ns;

    -- signals for both
    signal clk_test : std_logic := '0';
    
    signal Ain_test, OPin_test, Bin_test, Cin_test : STD_LOGIC_VECTOR (7 downto 0) := (others => '1');
    signal Aout_test, Bout_test, Cout_test, OPout_test, Stest : STD_LOGIC_VECTOR (7 downto 0);           
    signal RST_test, SelectA_test : STD_LOGIC := '0';
    
    


begin

    uut_pipebuf : pipeline_buffer PORT MAP(
        CLK => clk_test,
        Ain => Ain_test,
        Bin => Bin_test,
        Cin => Cin_test,
        OPin => OPin_test,
        Aout => Aout_test,
        Bout => Bout_test,
        Cout => Cout_test,
        OPout => Opout_test,
        RST => RST_test
    );
    
    uut_mux : mux PORT MAP(
        InA => Aout_test,
        InB => Bout_test,
        S => Stest,
        SelectA => SelectA_test
    );

    clock_process : process
    begin
        loop
            clk_test <= not (clk_test);
            wait for Clock_period / 2;
        end loop;
    end process;
    
    RST_test <= '1' after 35ns;
    Bin_test <= X"D7" after 11ns;
    OPin_test <= X"02" after 55ns;
    SelectA_test <= '1' after 65ns;


end Behavioral;
