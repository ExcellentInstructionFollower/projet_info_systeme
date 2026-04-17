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
            clk     : in  std_logic;
            addr    : in  std_logic_vector(7 downto 0);
            OPout, Aout, Bout, Cout: out std_logic_vector(7 downto 0)
        );
    end component;

    constant Clock_period : time := 20 ns;

    -- signals for both
    signal clk_test : std_logic := '0';
    
    -- signals data memory (RAM)
    signal rst_ram_test    : std_logic := '0';
    signal rw_ram_test     : std_logic := '1';
    signal addr_ram_test   : std_logic_vector(7 downto 0) := (others => '0');
    signal din_ram_test    : std_logic_vector(7 downto 0) := (others => '0');
    signal dout_ram_test   : std_logic_vector(7 downto 0);

    -- signals instruction memory (ROM)
    signal addr_rom_test   : std_logic_vector(7 downto 0) := (others => '0');
    signal OPout_rom_test, Aout_rom_test, Bout_rom_test, Cout_rom_test   : std_logic_vector(7 downto 0);

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
        OPout=> OPout_rom_test,
        Aout=> Aout_rom_test,
        Bout=> Bout_rom_test,
        Cout=> Cout_rom_test
    );

    Clock_process : process
    begin
        loop
            clk_test <= not (clk_test);
            wait for Clock_period / 2;
        end loop;
    end process;

simu_process: process
    begin
        -- test RAM
    
        -- Reset RAM
        rst_ram_test <= '0';
        wait until rising_edge(clk_test);
        wait for 10 ns;
        rst_ram_test <= '1';
        wait for 10 ns;
        -- dout_ram_test should be "00"
    
        -- Write to RAM at address 0x0A
        addr_ram_test <= X"0A";
        din_ram_test  <= X"CA";
        rw_ram_test <= '0';  -- write mode
        wait until rising_edge(clk_test);
        wait for 10 ns;
        rw_ram_test <= '1';  -- read mode
        wait for 10 ns;
    
        -- Write to a different location in RAM at address 0x14
        addr_ram_test <= X"14";
        din_ram_test  <= X"FE";
        rw_ram_test <= '0';  -- write mode
        wait until rising_edge(clk_test);
        wait for 10 ns;
        rw_ram_test <= '1';  -- read mode
        wait for 10 ns;
    
        -- Verify that the value at address 0x0A is still 0xCA
        addr_ram_test <= X"0A";
        wait until rising_edge(clk_test);
        wait for 10 ns;
        -- dout_ram_test should still be "CA"
    
        -- test ROM
    
        -- read at address 0x00
        addr_rom_test <= X"01";
        wait until rising_edge(clk_test);
        wait for 10 ns;
        -- dout_rom_test should be "02" (because of hardcoded example)
    
        -- read at address 0x01
        addr_rom_test <= X"02";
        wait until rising_edge(clk_test);
        wait for 10 ns;
        -- dout_rom_test should be "03" (because of hardcoded example)
    
        -- read at address 0x04
        addr_rom_test <= X"04";
        wait until rising_edge(clk_test);
        wait for 10 ns;
        -- dout_rom_test should be "FF" (because of hardcoded example)
    end process;
end Behavioral;