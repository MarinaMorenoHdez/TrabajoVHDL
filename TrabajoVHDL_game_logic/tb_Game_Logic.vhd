LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY tb_Game_Logic IS
END tb_Game_Logic;
 
ARCHITECTURE behavior OF tb_Game_Logic IS 
 
    -- Componente a probar (UUT)
    COMPONENT Game_Logic
    PORT(
         CLK : IN  std_logic;
         RST_N : IN  std_logic;
         ENABLE_GAME : IN  std_logic;
         RESET_INTERNAL : IN  std_logic;
         TICK_L : IN  std_logic;
         TICK_R : IN  std_logic;
         SW_VEHICLE : IN  std_logic;
         SW_DIFFICULTY : IN  std_logic_vector(2 downto 0);
         COLLISION_FLAG : OUT  std_logic;
         WIN_FLAG : OUT  std_logic;
         CAR_POS_OUT : OUT  integer range 0 to 15;
         ROAD_L_LIMIT : OUT  integer range 0 to 15;
         ROAD_R_LIMIT : OUT  integer range 0 to 15;
         PROGRESS_LEDS : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    
    -- Señales
    signal CLK : std_logic := '0';
    signal RST_N : std_logic := '0';
    signal ENABLE_GAME : std_logic := '0';
    signal RESET_INTERNAL : std_logic := '0';
    signal TICK_L : std_logic := '0';
    signal TICK_R : std_logic := '0';
    signal SW_VEHICLE : std_logic := '0';
    signal SW_DIFFICULTY : std_logic_vector(2 downto 0) := "000";

    -- Salidas
    signal COLLISION_FLAG : std_logic;
    signal WIN_FLAG : std_logic;
    signal CAR_POS_OUT : integer range 0 to 15;
    signal ROAD_L_LIMIT : integer range 0 to 15;
    signal ROAD_R_LIMIT : integer range 0 to 15;
    signal PROGRESS_LEDS : std_logic_vector(15 downto 0);
 
    constant CLK_period : time := 10 ns;
 
BEGIN
 
    uut: Game_Logic PORT MAP (
          CLK => CLK, RST_N => RST_N,
          ENABLE_GAME => ENABLE_GAME, RESET_INTERNAL => RESET_INTERNAL,
          TICK_L => TICK_L, TICK_R => TICK_R,
          SW_VEHICLE => SW_VEHICLE, SW_DIFFICULTY => SW_DIFFICULTY,
          COLLISION_FLAG => COLLISION_FLAG, WIN_FLAG => WIN_FLAG,
          CAR_POS_OUT => CAR_POS_OUT,
          ROAD_L_LIMIT => ROAD_L_LIMIT, ROAD_R_LIMIT => ROAD_R_LIMIT,
          PROGRESS_LEDS => PROGRESS_LEDS
        );

    -- Reloj
    CLK_process :process
    begin
        CLK <= '0'; wait for CLK_period/2;
        CLK <= '1'; wait for CLK_period/2;
    end process;
 
    -- Proceso Principal de Pruebas
    stim_proc: process
    begin		
        -- 1. RESET
        RST_N <= '0';
        wait for 100 ns;	
        RST_N <= '1';
        wait for CLK_period;
        ENABLE_GAME <= '1';
        
        report "==== INICIO DE SIMULACION ====";

        -- -------------------------------------------------------------
        -- 2. PRUEBA DE MOVIMIENTO (MOTO vs COCHE)
        -- -------------------------------------------------------------
        report "--> Probando MOTO (Resolucion fina, pasos de 1)";
        SW_VEHICLE <= '1'; -- Moto
        wait for CLK_period;
        -- Mover Izquierda (7 -> 8)
        TICK_L <= '1'; wait for CLK_period; TICK_L <= '0';
        wait for CLK_period*2;
        assert CAR_POS_OUT = 8 report "ERROR: Moto no se movio a 8" severity error;

        report "--> Probando COCHE (Resolucion gruesa, pasos de 2)";
        SW_VEHICLE <= '0'; -- Coche
        wait for CLK_period;
        -- Mover Izquierda (8 -> 10) (Estaba en 8, +2 = 10)
        TICK_L <= '1'; wait for CLK_period; TICK_L <= '0';
        wait for CLK_period*2;
        assert CAR_POS_OUT = 10 report "ERROR: Coche no se movio a 10" severity error;

        -- Volver al centro aprox para jugar
        TICK_R <= '1'; wait for CLK_period; TICK_R <= '0'; -- 10 -> 8
        wait for CLK_period;
        TICK_R <= '1'; wait for CLK_period; TICK_R <= '0'; -- 8 -> 6
        wait for CLK_period*5;

        -- -------------------------------------------------------------
        -- 3. PRUEBA DE MODO PROGRESIVO ("101")
        -- -------------------------------------------------------------
        report "--> Activando MODO CAMPANA PROGRESIVO (101)";
        SW_DIFFICULTY <= "101"; 
        
        -- Reiniciamos partida interna para empezar de 0 leds
        RESET_INTERNAL <= '1'; wait for CLK_period; RESET_INTERNAL <= '0';
        
        report "--> Esperando a que el juego avance y se llenen los LEDs...";
        -- Vamos a esperar lo suficiente para ganar.
        -- Con STEPS_PER_LED = 2 y SPEED = 4, esto sera rapido.
        
        -- Bucle de espera activa hasta ganar
        while WIN_FLAG = '0' loop
            wait for CLK_period * 10;
            -- Si quieres ver el progreso en la consola:
            -- report "Leds: " & integer'image(to_integer(unsigned(PROGRESS_LEDS)));
        end loop;
        
        report "==== ¡VICTORIA DETECTADA! (WIN_FLAG = 1) ====";
        wait for CLK_period * 10;

        -- -------------------------------------------------------------
        -- 4. PRUEBA DE COLISIÓN
        -- -------------------------------------------------------------
        report "--> Probando Colision...";
        RESET_INTERNAL <= '1'; wait for CLK_period; RESET_INTERNAL <= '0';
        wait for CLK_period;
        
        -- Vamos a chocar contra la pared izquierda.
        -- La pared izquierda suele estar en > 10.
        -- Movemos el coche a tope izquierda (15).
        
        SW_VEHICLE <= '0'; -- Coche corre mas
        for i in 1 to 8 loop
            TICK_L <= '1'; wait for CLK_period; TICK_L <= '0';
            wait for CLK_period * 2;
        end loop;
        
        -- Ahora estamos en 15 o cerca. Esperamos a que la carretera nos toque.
        wait for CLK_period * 50;
        
        if COLLISION_FLAG = '1' then
            report "==== COLISION EXITOSA ====";
        else
            report "WARN: No hubo colision (quizas la carretera se alejo por azar)" severity warning;
        end if;

        wait;
    end process;

END;