----------------------------------------------------------------------------------
-- Company: G36
-- Engineer: Sergio Llana AYen
-- 
-- Create Date: 13.12.2025 14:39:37
-- Design Name: 
-- Module Name: Edge_Detector - Behavioral
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

entity Edge_Detector is
    Port ( 
        CLK     : in  STD_LOGIC;
        RST_N     : in  STD_LOGIC;
        SIG_IN  : in  STD_LOGIC; -- Señal sincronizada y sin rebotes
        EDGE_OUT: out STD_LOGIC  -- Pulso de 1 ciclo
    );
end Edge_Detector;

architecture Behavioral of Edge_Detector is
signal sreg: std_logic_vector(2 downto 0);
begin
process(CLK)
  begin
         if rising_edge(CLK) then
         if RST_N = '0' then 
         sreg <= "000"; -- limpiamos el registro
         else
             sreg <= sreg(1 downto 0) & SIG_IN;
         end if;
         end if;
  end process;
with sreg select
        EDGE_OUT <= '1' when "001",
        '0' when others;
end Behavioral;
