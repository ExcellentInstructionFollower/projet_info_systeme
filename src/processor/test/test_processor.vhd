library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity test_processor is
--  Port ( );
end test_processor;

architecture Behavioral of test_processor is

    component processor is
    Port (
        CLK, RST : std_logic
     );
end component;

    constant Clock_period : time := 10 ns;
    
    signal rst_test   : std_logic := '0';
    signal clk_test   : std_logic := '0';

begin

    uut_processor : processor PORT MAP (
        CLK => clk_test,
        RST => rst_test
    );

    Clock_process : process
    begin
        loop
            clk_test <= not (clk_test);
            wait for Clock_period / 2;
        end loop;
    end process;
    
    rst_test <= '1' after 45ns;


end Behavioral;
