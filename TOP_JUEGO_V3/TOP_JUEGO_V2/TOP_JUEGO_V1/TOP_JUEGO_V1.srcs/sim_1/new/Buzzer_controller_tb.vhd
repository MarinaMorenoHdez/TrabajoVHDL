----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.12.2025 19:51:07
-- Design Name: 
-- Module Name: Buzzer_controller_tb - Behavioral
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

entity Buzzer_controller_tb is
end Buzzer_controller_tb;

architecture Behavioral of Buzzer_controller_tb is
    
    component Buzzer_controller
    Port (
        CLK             : in  STD_LOGIC;
        RST_N           : in  STD_LOGIC;
        current_state   : in  STD_LOGIC_VECTOR(1 downto 0);
        tipo_vehi_in    : in  STD_LOGIC;
        difficulty_sw   : in  STD_LOGIC_VECTOR(2 downto 0);
        BUZZER_OUT      : out STD_LOGIC
    );
    end component;
    
    signal clk_tb : std_logic := '0';
    signal rst_n_tb : std_logic := '0';
    signal current_state_tb : std_logic_vector(1 downto 0) := "00"; -- MENU
    signal tipo_vehi_tb : std_logic := '0';
    signal difficulty_tb : std_logic_vector(2 downto 0) := "000";
    
    signal buzzer_out_tb : std_logic;

    constant CLK_PERIOD : time := 10 ns;
    constant espera_corta : time := 25 us; 
    constant espera_larga  : time := 70 us; 
begin
    uut: Buzzer_controller port map (
        CLK => clk_tb,
        RST_N => rst_n_tb,
        current_state => current_state_tb,
        tipo_vehi_in => tipo_vehi_tb,
        difficulty_sw => difficulty_tb,
        BUZZER_OUT => buzzer_out_tb
    );
    
    clk_process :process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD/2;
        clk_tb <= '1'; wait for CLK_PERIOD/2;
    end process;
    
    stim_proc: process
    begin
        report "INICIO SIMULACION BUZZER";
        
        rst_n_tb <= '0'; -- Reset activo
        current_state_tb <= "00";
        tipo_vehi_tb <= '0';
        difficulty_tb <= "001";
        wait for CLK_PERIOD * 10;
        
        rst_n_tb <= '1';
        wait for CLK_PERIOD * 5;
        
        assert (buzzer_out_tb = '0') report "FALLO" severity failure;

           -- Esperamos: Tono agudo (rápido), duración corta.

        report "TEST 1: Provocando sonido de seleccion en la dificultad";
        difficulty_tb <= "010"; 
        
        wait for espera_corta;
        
        assert (buzzer_out_tb = '0') 
            report "FALLO" severity failure;
        report "TEST 1 finalizado.";
        wait for CLK_PERIOD * 20; 

        report "TEST 2: Provocando sonido cuando gana";
        current_state_tb <= "01"; 
        wait for CLK_PERIOD * 5;
        current_state_tb <= "11"; 
        
        wait for espera_corta;

        assert (buzzer_out_tb = '0') 
            report "FALLO" severity failure;
        report "TEST 2 finalizado.";
        wait for CLK_PERIOD * 20;

        report "TEST 3: Provocando sonido cuando choca";
        current_state_tb <= "01"; 
        wait for CLK_PERIOD * 5;
        current_state_tb <= "10";

        wait for espera_larga;

        assert (buzzer_out_tb = '0') 
            report "FALLO" severity failure;
        report "TEST 2 finalizado.";

        report "FIN DE LA SIMULACION.";
        wait;
    end process;
    
end Behavioral;
