----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2025 10:14:15
-- Design Name: 
-- Module Name: FSM_tb - Behavioral
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
use IEEE.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM_tb is
--  Port ( );
end FSM_tb;

architecture Behavioral of FSM_tb is
    component FSM
    Generic (
            tiempo_espera : integer
        );
        Port (
            CLK : in STD_LOGIC;
            RST : in STD_LOGIC; 
            START_TICK : in STD_LOGIC; -- de PULSADOR in
            GAME_OVER_SIGNAL : in STD_LOGIC; -- de LÓGICA
            LEVEL_COMPLETE_SIGNAL : in STD_LOGIC; -- de LÓGICA
            CURRENT_STATE_OUT : out STD_LOGIC_VECTOR(1 downto 0) -- máquina de estados
        );
    end component;
    
    signal clk_tb : std_logic := '0';
    signal rst_tb : std_logic := '0';
    signal start_tick_tb : std_logic := '0';
    signal game_over_tb : std_logic := '0';
    signal level_complete_tb : std_logic := '0';
    signal current_state_tb : std_logic_vector(1 downto 0);

    -- Constante para el periodo del reloj (ej: 10ns para 100MHz)
    constant CLK_PERIOD : time := 10 ns;    
    constant TIMEOUT_SIMULACION : integer := 50;    
begin
    
    uut: FSM 
        generic map(
        tiempo_espera => TIMEOUT_SIMULACION
        )
        port map(
        CLK => clk_tb,
        RST => rst_tb,
        START_TICK => start_tick_tb,
        GAME_OVER_SIGNAL => game_over_tb,
        LEVEL_COMPLETE_SIGNAL => level_complete_tb,
        CURRENT_STATE_OUT => current_state_tb
    );
    
    clk_process :process  --generación del reloj
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD/2;
        clk_tb <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    stim_proc: process
    begin
        rst_tb <= '1';
        start_tick_tb <= '0';
        game_over_tb <= '0';
        level_complete_tb <= '0';
        wait for CLK_PERIOD * 5;
        
        -- Verifica RESET
        rst_tb <= '0';
        wait for CLK_PERIOD*2; 
        assert (current_state_tb = "00")
            report "No cambia a MENU (00)" severity failure;
        report "Cambia el estado correctamente a MENU";
        
        wait for CLK_PERIOD * 5;
        
        -- Verifica transición MENU --> JUEGO
        start_tick_tb <= '1';
        wait for CLK_PERIOD;
        start_tick_tb <= '0';
        wait for CLK_PERIOD;
        assert (current_state_tb = "01")
            report "No cambia a JUEGO (01)" severity failure;
        report "Cambia el estado correctamente a JUEGA";
        
        wait  for CLK_PERIOD * 10; --un poco más largo como si estuviera jugando
        
        game_over_tb <= '1';
        wait for CLK_PERIOD*2; --asegurar que detecta el choque y transita de estado
        game_over_tb <='0';
        wait for CLK_PERIOD*2;
        assert (current_state_tb = "10")
            report "No PIERDE (10)" severity failure;
        report "Cambia el estado correctamente a PIERDE";

        
        wait for CLK_PERIOD * 5;
        
        rst_tb <= '1';
        wait for CLK_PERIOD*2; --asegura que se haya pulsado RST
        rst_tb <= '0';
        wait for CLK_PERIOD *2;
        assert (current_state_tb = "00")
            report "No cambia al MENU (00)" severity failure;
        report "Cambia correctamente con RESET";
        
        wait for CLK_PERIOD*5;
        
        start_tick_tb <= '1';
        wait for CLK_PERIOD;
        start_tick_tb <= '0';
        wait for CLK_PERIOD * 10;
        level_complete_tb <= '1';
        wait for CLK_PERIOD;
        level_complete_tb <= '0';
        wait for CLK_PERIOD*2;
        assert(current_state_tb = "11")
            report "No cambia a GANA (11)" severity failure;
        report "Cambia correctamente a GANA";
        
        --Prueba del timeout por si no se pulsa RESET
        start_tick_tb <= '1'; 
        wait for CLK_PERIOD*2;
        start_tick_tb <= '0';
        wait for CLK_PERIOD*2;
        
        game_over_tb <= '1';
        wait for CLK_PERIOD*2;
        game_over_tb <= '0';
        wait for CLK_PERIOD*4;
        assert(current_state_tb = "10")
            report "No ha llegado a PIERDE (10)" severity failure;
        
        report "Espera al temporizador";
        wait for CLK_PERIOD * 60; --El temporizador dura 50 ciclos
        
        assert(current_state_tb = "00")
            report "NO ha vuelto al menú pasado el TIMEOUT" severity failure;
        report "La espera funciona";
        
        report "Todo funciona perfecto";
        wait;
    end process;
              

end Behavioral;
