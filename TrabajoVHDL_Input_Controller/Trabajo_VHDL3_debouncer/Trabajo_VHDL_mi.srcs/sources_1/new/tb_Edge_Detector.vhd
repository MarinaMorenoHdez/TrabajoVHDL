----------------------------------------------------------------------------------
-- Company: G36
-- Engineer: Sergio Llana Ayen
-- 
-- Create Date: 13.12.2025 14:56:44
-- Design Name: 
-- Module Name: tb_Edge_Detector - Behavioral
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

ENTITY tb_Edge_Detector IS
END tb_Edge_Detector;
 
ARCHITECTURE behavior OF tb_Edge_Detector IS

component Edge_Detector 
PORT(
        CLK     : in  STD_LOGIC;
        RST_N     : in  STD_LOGIC;
        SIG_IN  : in  STD_LOGIC; -- Señal sincronizada y sin rebotes
        EDGE_OUT: out STD_LOGIC  -- Pulso de 1 ciclo
    );
end COMPONENT;

-- Señales a conectar
signal CLK: std_logic:='0';
signal SIG_IN: std_logic:='0';
signal EDGE_OUT: std_logic;
signal RST_N: std_logic:='1'; 

-- periodo del reloj - 100MHz
constant CLK_Period: time:=10 ns;

begin

-- instanciamos Edge_Detector
uut: Edge_Detector PORT MAP(
CLK => CLK,
SIG_IN => SIG_IN,
EDGE_OUT => EDGE_OUT,
RST_N => RST_N

);

--proceso del reloj

CLK_process: process
begin
CLK <='0'; wait for CLK_Period/2;
CLK <='1'; wait for CLK_Period/2;
end process; 

-- proceso de estimulos

estim_process: process
begin		
------------SIMULAMOS EL ARRANQUE:
        -- Al encender, pulsamos Reset para limpiar basura
        RST_N <= '0';      
        SIG_IN <= '0';
        wait for 50 ns;	

        ---SOLTAMOS RESET (EMPIEZA EL JUEGO):
        RST_N <= '1';      
        wait for CLK_period * 2;

        --PRUEBA DE FLANCO 
        wait until falling_edge(CLK);
        SIG_IN <= '1'; -- Pulsador de juego presionado
        
        wait for CLK_period * 5;
        
        ---PRUEBA DE RESET EN MITAD DE PULSACIÓN
        SIG_IN <= '0'; wait for 20 ns;
        SIG_IN <= '1'; -- Pulsamos un pulsador
        wait for 10 ns;
        RST_N <= '0';     -- Pulsamos Reset de golpe
        -- La señal EDGE se corta.

        wait;
    end process;
END;



