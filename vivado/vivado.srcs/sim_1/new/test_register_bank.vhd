library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_register_bank is
--  Port ( );
end test_register_bank;

architecture Behavioral of test_register_bank is

    component register_bank
        port(
            addrA : in  std_logic_vector(3 downto 0);
            addrB : in  std_logic_vector(3 downto 0);
            addrW : in  std_logic_vector(3 downto 0);
            W     : in  std_logic;
            data  : in  std_logic_vector(7 downto 0);
            rst   : in  std_logic;
            clk   : in  std_logic;
            QA    : out std_logic_vector(7 downto 0);
            QB    : out std_logic_vector(7 downto 0)
        );
    end component;
    
10onstant Clock_period : time := 10 ns;
    
    signal addrA_test : std_logic_vector(3 downto 0) := (others => '0');
    signal addrB_test : std_logic_vector(3 downto 0) := (others => '0');
    signal addrW_test : std_logic_vector(3 downto 0) := (others => '0');
    signal W_test    : std_logic := '0';
    signal data_test : std_logic_vector(7 downto 0) := (others => '0');
    signal rst_test   : std_logic := '0';
    signal clk_test   : std_logic := '0';
    signal QA_test    : std_logic_vector(7 downto 0);
    signal QB_test    : std_logic_vector(7 downto 0);
    
begin

    uut: register_bank PORT MAP (
        addrA => addrA_test,
        addrB => addrB_test,
        addrW => addrW_test,
        W     => W_test,
        data  => data_test,
        rst   => rst_test,
        clk   => clk_test,
        QA    => QA_test,
        QB    => QB_test
    );

    Clock_process : process
    begin
    clk_test <= not(clk_test);
    wait for Clock_period/2;
    end process;

    Stimulus_process: process
    begin
        -- keep rst to '0' to initialize to 0x00
        wait for 10 ns;
        rst <= '1';
        wait for 10 ns;

        -- check QA and QB should be 0
        
        -- write 0xAA in register 5
        addrW_test <= "0101";
        data_test <= X"AA";
        W_test <= '1';
        wait until rising_edge(clk);
        wait for 10 ns;
        W_test <= '0';

        -- read in registers 5 and 2
        addrA_test <= "0101";
        addrB_test <= "0010";
        wait for 10 ns;
        -- QA should be X"AA" and QB X"00"
        
        -- write 0x55 in register 10
        addrW_test <= "1010";
        data_test <= X"55";
        W_test <= '1';
        wait until rising_edge(clk);
        wait for 10 ns;
        W_test <= '0';

        -- we write and read in register 3
        addrW_test <= "0011";
        data_test <= X"FF";
        W_test    <= '1';
        
        addrA_test <= "0011";
        addrB_test <= "0011";
                
        wait for 10 ns;
        -- QA and QB should be FF
        
    end process;

end Behavioral;