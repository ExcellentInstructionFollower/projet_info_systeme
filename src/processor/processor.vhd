library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity processor is
    Port (
        CLK, RST : std_logic
     );
end processor;

architecture Behavioral of processor is

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
    
    component ALU
    Port ( A, B : in  std_logic_vector(7 downto 0);
        Ctrl_ALU   : in  std_logic_vector(2 downto 0);
        S    : out std_logic_vector(7 downto 0);
        N, O, Z, C   : out std_logic);
    end component;
    
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
    
    --signals instructions memory
    signal instruction_pointer : std_logic_vector(7 downto 0);
    signal nb_nop : std_logic_vector(2 downto 0);
    
    
    --signals LI/DI (IF/ID)
    signal select_decode, rst_ifid : std_logic;
    signal registers_to_mux : std_logic_vector(7 downto 0);
    signal Aifid_in, Bifid_in, Cifid_in, OPifid_in: std_logic_vector(7 downto 0);
    signal Aifid_out, Bifid_out, Cifid_out, OPifid_out: std_logic_vector(7 downto 0);
    
    --signals DI/EX (ID/EX)
    signal LC_execute : std_logic;
    signal Bidex_in, Cidex_in: std_logic_vector(7 downto 0);
    signal Aidex_out, Bidex_out, Cidex_out, OPidex_out: std_logic_vector(7 downto 0);
    
    --signals EX/Mem (EX/MA)
    signal LC_memory : std_logic;
    signal Bexma_in, Cexma_in: std_logic_vector(7 downto 0);
    signal Aexma_out, Bexma_out, Cexma_out, OPexma_out: std_logic_vector(7 downto 0);
    
    --signals Mem/RE (MA/WB)
    signal LC_writeback : std_logic;
    signal Bmawb_in, Cmawb_in: std_logic_vector(7 downto 0);
    signal Amawb_out, Bmawb_out, Cmawb_out, OPmawb_out: std_logic_vector(7 downto 0);


begin

    uut_ram: data_memory PORT MAP(
        clk     => clk,
        rst     => rst,
        rw      => LC_memory,
        addr    => Bexma_out,
        data_in => Bexma_out,
        data_out=> Bmawb_in
    );

    uut_rom: inst_memory PORT MAP(
        clk      => clk,
        addr     => instruction_pointer,
        OPout=> OPifid_in,
        Aout=> Aifid_in,
        Bout=> Bifid_in,
        Cout=> Cifid_in
    );
    
    uut_registers: register_bank PORT MAP (
        addrA => Bifid_out (3 downto 0),
        addrB => Cifid_out (3 downto 0),
        addrW => Amawb_out (3 downto 0),
        W     => LC_writeback,
        data  => Bmawb_out,
        rst   => rst,
        clk   => clk,
        QA    => registers_to_mux,
        QB    => Cidex_in
    );
    
    uut_mux_decode : mux PORT MAP(
        InA => Bifid_out,
        InB => registers_to_mux,
        S => Bidex_in,
        SelectA => select_decode
    );
    
    uut_IFID: pipeline_buffer PORT MAP(
        CLK => clk,
        Ain => Aifid_in,
        Bin => Bifid_in,
        Cin => Cifid_in,
        OPin => OPifid_in,
        Aout => Aifid_out,
        Bout => Bifid_out,
        Cout => Cifid_out,
        OPout => OPifid_out,
        RST => rst_ifid
    );
    
    uut_IDEX: pipeline_buffer PORT MAP(
        CLK => clk,
        Ain => Aifid_out,
        Bin => Bidex_in,
        Cin => Cidex_in,
        OPin => OPifid_out,
        Aout => Aidex_out,
        Bout => Bidex_out,
        Cout => Cidex_out,
        OPout => OPidex_out,
        RST => rst
    );
    
    uut_EXMA: pipeline_buffer PORT MAP(
        CLK => clk,
        Ain => Aidex_out,
        Bin => Bidex_out,
        Cin => Cexma_in,
        OPin => OPidex_out,
        Aout => Aexma_out,
        Bout => Bexma_out,
        Cout => Cexma_out,
        OPout => OPexma_out,
        RST => rst
    );
    
    uut_MAWB: pipeline_buffer PORT MAP(
        CLK => clk,
        Ain => Aexma_out,
        Bin => Bexma_out,
        Cin => Cmawb_in,
        OPin => OPexma_out,
        Aout => Amawb_out,
        Bout => Bmawb_out,
        Cout => Cmawb_out,
        OPout => OPmawb_out,
        RST => rst
    );
    
    

    IFID_process : process(CLK) 
    begin
        if rising_edge(CLK) then
            if (RST = '0') then
                instruction_pointer <= X"00";
                nb_nop <= (others => '0');
                rst_ifid <= '0';
            elsif (nb_nop /= "000") then
                rst_ifid <= '0';
                nb_nop <= nb_nop - "001";
                instruction_pointer <= instruction_pointer;
            elsif (OPifid_in = X"05") then
                if ((OPifid_out = X"05" or OPifid_out = X"06") and Bifid_in = Aifid_out) then
                    rst_ifid <= '0';
                    nb_nop <= "100";
                    instruction_pointer <= instruction_pointer;
                elsif ((OPidex_out = X"05" or OPidex_out = X"06") and Bifid_in = Aidex_out) then
                    rst_ifid <= '0';
                    nb_nop <= "011";
                    instruction_pointer <= instruction_pointer;
                elsif ((OPexma_out = X"05" or OPexma_out = X"06") and Bifid_in = Aexma_out) then
                    rst_ifid <= '0';
                    nb_nop <= "010";
                    instruction_pointer <= instruction_pointer;
                elsif ((OPmawb_out = X"05" or OPmawb_out = X"06") and Bifid_in = Amawb_out) then
                    rst_ifid <= '0';
                    nb_nop <= "001";
                    instruction_pointer <= instruction_pointer;
                end if;
            else 
                instruction_pointer <= instruction_pointer + X"01";
                rst_ifid <= '1';
            end if;
        end if;
        
    end process;
    
    IDEX_process : process(OPifid_out) 
    begin
        if (OPifid_out = X"05") then
            select_decode <= '0';
        else
            select_decode <= '1';
        
        end if;     
    
    end process;
    
    EXMA_process : process(CLK) 
    begin
        if rising_edge(CLK) then
        end if;
        
    end process;
    
    MAWB_process : process(OPmawb_out) 
    begin
        if (OPmawb_out = X"06" or OPmawb_out = X"05") then
            LC_writeback <= '1';
        else
            LC_writeback <= '0';
        
        end if;  
        
    end process;

end Behavioral;
