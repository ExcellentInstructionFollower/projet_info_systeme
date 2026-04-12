library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_memory is
end test_memory;

architecture Behavioral of test_memory is

    component data_memory
        port(
            clk     : in  std_logic;
            rst     : in  std_logic;
            rw      : in  std_logic;
            addr    : in  std_logic_vector(7 downto 0);
            data_in : in  std_logic_vector(7 downto 0);
            data_out: out std_logic_vector(7 downto 0)
        );
    end component;

    component inst_memory
        port(
            clk      : in  std_logic;
            addr     : in  std_logic_vector(7 downto 0);
            instr_out: out std_logic_vector(7 downto 0)
        );
    end component;

    constant Clock_period : time := 20 ns;

    -- signals for both
    signal clk : std_logic := '0';
    
    -- signals data memory (RAM)
    signal rst_ram    : std_logic := '0';
    signal rw_ram     : std_logic := '1';
    signal addr_ram   : std_logic_vector(7 downto 0) := (others => '0');
    signal din_ram    : std_logic_vector(7 downto 0) := (others => '0');
    signal dout_ram   : std_logic_vector(7 downto 0);

    -- signals instruction memory (ROM)
    signal addr_rom   : std_logic_vector(7 downto 0) := (others => '0');
    signal dout_rom   : std_logic_vector(7 downto 0);

begin

    -- Instanciation RAM
    uut_ram: data_memory PORT MAP(
        clk     => clk_test,
        rst     => rst_ram_test,
        rw      => rw_ram_test,
        addr    => addr_ram_test,
        data_in => din_ram_test,
        data_out=> dout_ram_test
    );

    -- Instanciation ROM
    uut_rom: inst_memory PORT MAP(
        clk      => clk_test,
        addr     => addr_rom_test,
        instr_out=> dout_rom_test
    );

    Clock_process : process
    begin
    clk_test <= not(clk_test);
    wait for Clock_period/2;
    end process;

    Stimulus_process: process
    begin

        -- test RAM --

        -- reset RAM
        rst_ram_test <= '0';
        wait for 10 ns;
        rst_ram_test <= '1';
        wait for 10 ns;
        -- dout_ram_test should be "00"

        -- write in RAM
        addr_ram_test <= X"0A";
        din_ram_test  <= X"CA";
        rw_ram_test <= '0';
        wait until rising_edge(clk);
        rw_ram_test <= '1';
        wait for 10 ns;

        -- read in RAM
        addr_ram_test <= X"0A";
        wait for 10 ns;
        -- dout_ram_test should now be "CA"

        -- write elsewhere in RAM
        addr_ram_test <= X"14";
        din_ram_test  <= X"FE";
        rw_ram_test <= '0';
        wait until rising_edge(clk);
        rw_ram_test <= '1';
        wait for 10 ns;
        addr_ram_test <= X"0A";
        wait for 10 ns;
        -- dout_ram_test should still be "CA"

        -- test ROM --

        -- read at different addresses
        addr_rom_test <= X"00";
        wait until rising_edge(clk);
        wait for 10 ns;
        -- dout_rom_test should be "01" (because of hardcoded example)

        addr_rom_test <= X"01";
        wait until rising_edge(clk);
        wait for 10 ns;
        -- dout_rom_test should be "02" (because of hardcoded example)

        addr_rom_test <= X"04";
        wait until rising_edge(clk);
        wait for 10 ns;
        -- dout_rom_test should be "FF" (because of hardcoded example)

        wait for 50 ns;
    end process;

end Behavioral;