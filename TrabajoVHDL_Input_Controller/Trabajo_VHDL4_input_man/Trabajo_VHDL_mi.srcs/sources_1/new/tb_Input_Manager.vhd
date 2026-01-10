----------------------------------------------------------------------------------
-- Company: G36 ETSIDI
-- Engineer: Sergio Llana Ayen
-- 
-- Create Date: 15.12.2025 21:38:48
-- Design Name: 
-- Module Name: tb_Input_Manager - Behavioral
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


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_Input_Manager IS
END tb_Input_Manager;
 
ARCHITECTURE behavior OF tb_Input_Manager IS 
 
    COMPONENT Input_Manager
    GENERIC(
        DEBOUNCE_CYCLES : integer
    );
    PORT(
        CLK : IN std_logic;
        RST_N : IN std_logic;
        BTN_L_IN : IN std_logic;
        BTN_R_IN : IN std_logic;
        BTN_START_IN : IN std_logic;
        SW_VEHICLE_IN : IN std_logic;
        SW_DIFF_IN : IN std_logic_vector(2 downto 0);
        TICK_L : OUT std_logic;
        TICK_R : OUT std_logic;
        TICK_START : OUT std_logic;
        SW_VEHICLE_SYNC : OUT std_logic;
        SW_DIFF_SYNC : OUT std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    
    -- Señales
    signal CLK : std_logic := '0';
    signal RST_N : std_logic := '1';
    signal BTN_L_IN : std_logic := '0';
    signal BTN_R_IN : std_logic := '0';
    signal BTN_START_IN : std_logic := '0';
    signal SW_VEHICLE_IN : std_logic := '0';
    signal SW_DIFF_IN : std_logic_vector(2 downto 0) := "000";

    -- Salidas
    signal TICK_L : std_logic;
    signal TICK_R : std_logic;
    signal TICK_START : std_logic;
    signal SW_VEHICLE_SYNC : std_logic;
    signal SW_DIFF_SYNC : std_logic_vector(2 downto 0);
 
    constant CLK_period : time := 10 ns;
 
BEGIN
 
    -- Instanciamos con debounce corto (5 ciclos) para simulación
    uut: Input_Manager 
    GENERIC MAP (
        DEBOUNCE_CYCLES => 5
    )
    PORT MAP (
        CLK => CLK, RST_N => RST_N,
        BTN_L_IN => BTN_L_IN, BTN_R_IN => BTN_R_IN, BTN_START_IN => BTN_START_IN,
        SW_VEHICLE_IN => SW_VEHICLE_IN, SW_DIFF_IN => SW_DIFF_IN,
        TICK_L => TICK_L, TICK_R => TICK_R, TICK_START => TICK_START,
        SW_VEHICLE_SYNC => SW_VEHICLE_SYNC, SW_DIFF_SYNC => SW_DIFF_SYNC
    );

    CLK_process :process
    begin
        CLK <= '0'; wait for CLK_period/2;
        CLK <= '1'; wait for CLK_period/2;
    end process;
 
    stim_proc: process
    begin		
        -- Reset inicial
        RST_N <= '0';
        wait for 100 ns;	
        RST_N <= '1';
        wait for CLK_period*2;

        --------------------------------------------------
        -- PRUEBA DE BOTON (Ruido + Debounce + Edge)
        --------------------------------------------------
        -- Ruido inicial
        BTN_L_IN <= '1'; wait for CLK_period; 
        BTN_L_IN <= '0'; wait for CLK_period;
        -- Pulsación firme
        BTN_L_IN <= '1'; 
        wait for CLK_period * 20; -- Esperamos más que el debounce (5 ciclos)
        
        -- Verificación visual: TICK_L debería haber hecho un pulso 
        -- aprox a los 7-8 ciclos (2 sync + 5 debounce + edge).

        BTN_L_IN <= '0';
        wait for CLK_period * 10;

        --------------------------------------------------
        -- PRUEBA DE SWITCHES (Solo Sync)
        --------------------------------------------------
        SW_DIFF_IN <= "101";
        SW_VEHICLE_IN <= '1';
        
        wait for CLK_period * 5;
        -- Deberían aparecer en la salida sincronizados (2 ciclos de retraso)

        wait;
    end process;

END;
