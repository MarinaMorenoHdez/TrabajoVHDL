-- 2. tb_Pattern_Generator.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Pattern_Generator is
    -- El testbench no tiene puertos externos
end tb_Pattern_Generator;

architecture Behavioral of tb_Pattern_Generator is

    -- 1. Declaramos el componente a probar ("Unit Under Test" - UUT)
    component Pattern_Generator
    Port ( 
        columna_actual : in  integer range 0 to 7;
        pos_coche      : in  integer range 0 to 7;
        pos_muro_izq   : in  integer range 0 to 7;
        pos_muro_der   : in  integer range 0 to 7;
        segmentos      : out STD_LOGIC_VECTOR (6 downto 0)
    );
    end component;

    -- 2. Señales internas para conectar al componente
    signal t_columna_actual : integer range 0 to 7 := 0;
    signal t_pos_coche      : integer range 0 to 7 := 0;
    signal t_pos_muro_izq   : integer range 0 to 7 := 0;
    signal t_pos_muro_der   : integer range 0 to 7 := 7;
    signal t_segmentos      : STD_LOGIC_VECTOR (6 downto 0);

    -- 3. Constantes para verificar (Lógica Negativa: 0 = Encendido)
    constant DIBUJO_COCHE : std_logic_vector(6 downto 0) := "0000001"; -- Un '0'
    constant DIBUJO_MURO  : std_logic_vector(6 downto 0) := "1001111"; -- Un '1'
    constant APAGADO      : std_logic_vector(6 downto 0) := "1111111"; -- Nada

begin

    -- 4. Conectamos los cables (Instanciación)
    uut: Pattern_Generator PORT MAP (
        columna_actual => t_columna_actual,
        pos_coche      => t_pos_coche,
        pos_muro_izq   => t_pos_muro_izq,
        pos_muro_der   => t_pos_muro_der,
        segmentos      => t_segmentos
    );

    -- 5. Proceso de Estímulos (El Guion de la prueba)
    stim_proc: process
    begin		
        -- Esperar un poco al inicio
        wait for 100 ns;	

        -----------------------------------------------------------
        -- CASO 1: Dibujar el COCHE
        -----------------------------------------------------------
        -- Situación: El barrido pasa por el display 4. El coche está en el 4.
        t_columna_actual <= 4;
        t_pos_coche      <= 4;
        t_pos_muro_izq   <= 0; -- Muros lejos
        t_pos_muro_der   <= 7;
        
        wait for 10 ns; -- Dar tiempo a que el chip responda
        
        -- Verificación automática (Assert)
        assert (t_segmentos = DIBUJO_COCHE) 
        report "FALLO EN CASO 1: No se dibujó el coche en la posición correcta" 
        severity error;

        -----------------------------------------------------------
        -- CASO 2: Dibujar MURO IZQUIERDO
        -----------------------------------------------------------
        -- Situación: El barrido pasa por el display 2. El muro izq está en el 2.
        t_columna_actual <= 2;
        t_pos_muro_izq   <= 2;
        t_pos_coche      <= 4; -- El coche está en otro lado
        
        wait for 10 ns;
        
        assert (t_segmentos = DIBUJO_MURO) 
        report "FALLO EN CASO 2: No se dibujó el muro izquierdo" 
        severity error;

        -----------------------------------------------------------
        -- CASO 3: Espacio VACÍO
        -----------------------------------------------------------
        -- Situación: Barrido en display 3. No hay coche (4) ni muros (2 y 7).
        t_columna_actual <= 3;
        t_pos_muro_izq   <= 2;
        t_pos_muro_der   <= 7;
        t_pos_coche      <= 4;
        
        wait for 10 ns;
        
        assert (t_segmentos = APAGADO) 
        report "FALLO EN CASO 3: Debería estar apagado y se encendió algo" 
        severity error;

        -- Fin de la prueba
        report "PRUEBA FINALIZADA: Si no hay errores arriba, todo OK.";
        wait;
    end process;

end Behavioral;
