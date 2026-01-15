----------------------------------------------------------------------------------
-- Company: G36 
-- Engineer: Sergio Llana Ayen
-- 
-- Create Date: 13.12.2025 16:26:09
-- Design Name: 
-- Module Name: Debouncer - Behavioral
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
use IEEE.NUMERIC_STD.ALL; -- Necesario para poder contar

entity Debouncer is
    Generic (      
        -- NOTA: 1,000,000 para FPGA (10ms a 100MHz).
        TIMEOUT_CYCLES : integer := 1000000 
    );
    Port ( 
        CLK     : in  STD_LOGIC;
        RST_N     : in  STD_LOGIC; -- Reset Activo Alto
        BTN_IN  : in  STD_LOGIC; -- Entrada ruidosa (ya sincronizada)
        BTN_OUT : out STD_LOGIC  -- Salida limpia
    );
end Debouncer;

architecture Behavioral of Debouncer is
    signal counter      : integer range 0 to TIMEOUT_CYCLES := 0;
    signal btn_prev     : std_logic := '0'; 
    signal btn_out_sync : std_logic := '0';
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Reset Activo Alto
            if RST_N = '0' then
                counter      <= 0;
                btn_prev     <= '0';
                btn_out_sync <= '0';
            else
                -- LÓGICA DEL DEBOUNCER
                
                -- ¿La entrada es distinta a lo que ya tengo validado en la salida?
                if (BTN_IN /= btn_out_sync) then
                    
                    -- ¿es igual a lo que vi hace un instante?
                    if (BTN_IN = btn_prev) then
                        -- sí, lo es. ¿Hemos esperado suficiente?
                        if counter < TIMEOUT_CYCLES then
                            counter <= counter + 1; -- Seguimos contando
                        else
                            -- TIEMPO CUMPLIDO
                            btn_out_sync <= BTN_IN; -- lo tomamos por valido
                            counter<= 0;
                        end if;
                    else
                        -- No es igual a lo que vi hace un instante (ruido), reiniciamos cuenta
                        counter <= 0;
                    end if;
                else
                    -- Si la entrada ya es igual a la salida, todo tranquilo, no contamos
                    counter <=0;
                end if;
                
                -- Guardamos el estado actual para comparar en el siguiente ciclo
                btn_prev <= BTN_IN;
                
            end if;
        end if;
    end process;

    BTN_OUT <= btn_out_sync;

end Behavioral;