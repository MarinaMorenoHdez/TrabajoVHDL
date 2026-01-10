LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY tb_Debouncer IS
END tb_Debouncer;
 
ARCHITECTURE Behavioral OF tb_Debouncer IS 
 
    COMPONENT Debouncer 
    GENERIC(
        TIMEOUT_CYCLES : integer
    );
    PORT(
         CLK     : IN  std_logic;
         RST_N     : IN  std_logic;
         BTN_IN  : IN  std_logic;
         BTN_OUT : OUT std_logic
        );
    END COMPONENT;
    
    -- Señales
    signal CLK     : std_logic := '0';
    signal RST_N     : std_logic := '1';
    signal BTN_IN  : std_logic := '0';
    signal BTN_OUT : std_logic;
 
    constant CLK_period : time := 10 ns;
    -- Definimos un tiempo debounce corto para el test
    constant TEST_TIMEOUT : integer := 5; 
 
BEGIN
 
    -- Instanciamos con el Generic configurado a 5 ciclos
    uut: Debouncer 
    GENERIC MAP (
        TIMEOUT_CYCLES => TEST_TIMEOUT
    )
    PORT MAP (
          CLK => CLK,
          RST_N => RST_N,
          BTN_IN => BTN_IN,
          BTN_OUT => BTN_OUT
        );

    CLK_process :process
    begin
        CLK <= '0'; wait for CLK_period/2;
        CLK <= '1'; wait for CLK_period/2;
    end process;
    
 -- proceso de estimulos
    estim_proc: process
    begin		
        --ARRANQUE Y RESET
        RST_N <= '0';
        BTN_IN <= '0';
        wait for 50 ns;
        
        RST_N <= '1'; -- Soltamos reset
        wait for CLK_period * 2;

        -------------------------------------------------------------
        -- CASO 1: SIMULACIÓN DE RUIDO (REBOTES)
        -- Cambiamos la entrada antes de llegar a los 5 ciclos.
        -- LA SALIDA NO DEBE CAMBIAR (debe seguir en 0)
        --------------------------------------------------------------       
        BTN_IN <= '1'; wait for CLK_period * 2; 
        BTN_IN <= '0'; wait for CLK_period * 2; 
        BTN_IN <= '1'; wait for CLK_period * 4; -- casi, pero no
        BTN_IN <= '0'; wait for CLK_period * 2;
        BTN_IN <= '1'; wait for CLK_period * 7; -- se activa
        BTN_IN <= '0'; wait for CLK_period * 7; -- se desactiva
        
       --------------------------------------------------------------
        -- CASO 2: PULSACIÓN ESTABLE
        -- Mantenemos la entrada más de 5 ciclos
        -------------------------------------------------------------       
        BTN_IN <= '1'; 
        -- Esperamos 10 ciclos (el doble del timeout)
        wait for CLK_period * 10;
        
        -- BTN_IN debe ponerse a 1

        -------------------------------------------------------------
        -- CASO 3: SOLTAR EL BOTÓN (Con ruido)
        -------------------------------------------------------------

        BTN_IN <= '0'; wait for CLK_period * 2; -- Rebote al soltar
        BTN_IN <= '1'; wait for CLK_period * 1;
        BTN_IN <= '0'; wait for CLK_period * 10; -- Ya soltado firme
        
        -- BTN_OUT debería bajar a '0' tras el tiempo de espera.

        wait;
    end process;

END;