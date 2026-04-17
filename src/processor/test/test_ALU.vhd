library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_ALU is
--  Port ( );
end test_ALU;


architecture Behavioral of test_ALU is

    component ALU
    Port ( A, B : in  std_logic_vector(7 downto 0);
        Ctrl_ALU   : in  std_logic_vector(2 downto 0);
        S    : out std_logic_vector(7 downto 0);
        N, O, Z, C   : out std_logic);
    end component;
    
    constant Clock_period : time := 20ns;
    
    signal CK_test : STD_LOGIC := '0';
    signal N_test : STD_LOGIC;
    signal O_test : STD_LOGIC;
    signal Z_test : STD_LOGIC;
    signal C_test : STD_LOGIC;
    signal Ctrl_test : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
    signal A_test : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal B_test : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal S_test : STD_LOGIC_VECTOR (7 downto 0);
    
begin

    uut_ALU : ALU PORT MAP(
        Ctrl_ALU=>Ctrl_test,
        A=>A_test,
        B=>B_test,
        N=>N_test,
        O=>O_test,
        Z=>Z_test,
        C=>C_test,
        S=>S_test
    );
        
    Clock_process : process
    begin
    CK_test <= not(CK_test);
    wait for Clock_period/2;
    end process;
    
    Ctrl_test <= "001" after 60ns, "010" after 120ns, "011" after 180ns;
    A_test <= X"10" after 10ns, X"fe" after 30ns, X"14" after 80ns, X"00" after 90ns, X"32" after 130ns, X"E9" after 150ns;
    B_test <= X"24" after 20ns, X"e4" after 40ns, X"57" after 50ns, X"01" after 100ns, X"FE" after 110ns, X"02" after 120ns, X"C4" after 140ns, X"03" after 200ns, X"00" after 220ns;
     

end Behavioral;
