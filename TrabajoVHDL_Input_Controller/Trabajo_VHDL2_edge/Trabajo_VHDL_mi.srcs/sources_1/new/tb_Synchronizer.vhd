----------------------------------------------------------------------------------
-- Company: ETSIDI G36
-- Engineer: Sergio Llana Ayen
-- 
-- Create Date: 13.12.2025 13:08:27
-- Design Name: 
-- Module Name: tb_Synchronizer - Behavioral
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
 
ENTITY tb_Synchronizer IS
END tb_Synchronizer;
 
ARCHITECTURE behavior OF tb_Synchronizer IS 
 
    COMPONENT Synchronizer
    PORT(
        CLK : IN  std_logic;
        ASYNC_IN : IN  std_logic;
        SYNC_OUT : OUT  std_logic
        );
    END COMPONENT;
    
    --Inputs
    signal CLK : std_logic := '0';
    signal ASYNC_IN : std_logic := '0';
    --Outputs
    signal SYNC_OUT : std_logic;
    
    constant CLK_period : time := 10 ns;
 
BEGIN
 
    uut: Synchronizer PORT MAP (
          CLK => CLK,
          ASYNC_IN => ASYNC_IN,
          SYNC_OUT => SYNC_OUT
        );

    -- Reloj de 100MHz
    CLK_process :process
    begin
        CLK <= '0'; wait for CLK_period/2;
        CLK <= '1'; wait for CLK_period/2;
    end process;
 
    stim_proc: process
    begin		
        wait for 100 ns;
        
        -- Caso 1: Cambio la entrada a '1'
        -- Lo hago a los 3ns despues del flanco para simular evento asincrono
        wait for 3 ns; 
        ASYNC_IN <= '1';
        
        -- La salida SYNC_OUT NO debe cambiar en el siguiente flanco inmediato.
        -- Debe cambiar 2 flancos después.
        
        wait for CLK_period * 4;
        
        -- Caso 2: Cambio la entrada a '0'
        wait for 7 ns; -- Otro tiempo aleatorio
        ASYNC_IN <= '0';

        wait;
    end process;

END;