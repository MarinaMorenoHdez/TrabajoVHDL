library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Pattern_Generator is
    Port ( 
        -- ENTRADAS (Lo que le dice el resto del juego)
        columna_actual : in  integer range 0 to 7; -- ¿Qué display (ánodo) estamos pintando AHORA?
        pos_coche      : in  integer range 0 to 7; -- ¿En qué display está el coche?
        pos_muro_izq   : in  integer range 0 to 7; -- ¿Dónde está el límite izquierdo de la carretera?
        pos_muro_der   : in  integer range 0 to 7; -- ¿Dónde está el límite derecho?
        
        -- SALIDA (Lo que va a los segmentos físicos)
        segmentos      : out STD_LOGIC_VECTOR (6 downto 0) -- Cátodos CA-CG
    );
end Pattern_Generator;

architecture Behavioral of Pattern_Generator is
begin
    -- AÚN NO ESCRIBIMOS LA LÓGICA AQUÍ
    -- En TDD, primero hacemos que falle el test o que no haga nada.
    segmentos <= "1111111"; -- Por defecto apagado (ánodo común)
end Behavioral;
