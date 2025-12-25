library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TOP_JUEGO_tb is
end TOP_JUEGO_tb;

architecture sim of TOP_JUEGO_tb is

    component TOP_JUEGO
        PORT(
            CLK100MHZ     : in std_logic;
            RESET_N       : in std_logic;
            BTN_START     : in std_logic;
            BTN_L         : in std_logic;
            BTN_R         : in std_logic;
            DIFICULTAD_SW : in std_logic_vector(2 downto 0);
            TIPO_V_SW     : in std_logic;
            DISPLAYS      : out std_logic_vector(7 downto 0);
            SEGMENTOS     : out std_logic_vector(6 downto 0);
            LEDS_PROGRESO : out std_logic_vector(15 downto 0);
            LEDS_RGB      : out std_logic_vector(2 downto 0);
            BUZZER_PIN    : out std_logic
        );
    end component;

    signal clk_tb       : std_logic := '0';
    signal rst_n_tb     : std_logic := '0';
    signal btn_start_tb : std_logic := '0';
    signal btn_l_tb     : std_logic := '0';
    signal btn_r_tb     : std_logic := '0';
    signal diff_sw_tb   : std_logic_vector(2 downto 0) := "101"; -- Modo Progresivo
    signal tipo_v_tb    : std_logic := '0'; -- '0' para Coche

    signal displays_tb  : std_logic_vector(7 downto 0);
    signal segmentos_tb : std_logic_vector(6 downto 0);
    signal leds_prog_tb : std_logic_vector(15 downto 0);
    signal leds_rgb_tb  : std_logic_vector(2 downto 0);
    signal buzzer_tb    : std_logic;

    -- Constante de reloj (100MHz = 10ns)
    constant clk_period : time := 10 ns;

begin

    UUT: TOP_JUEGO
    port map (
        CLK100MHZ     => clk_tb,
        RESET_N       => rst_n_tb,
        BTN_START     => btn_start_tb,
        BTN_L         => btn_l_tb,
        BTN_R         => btn_r_tb,
        DIFICULTAD_SW => diff_sw_tb,
        TIPO_V_SW     => tipo_v_tb,
        DISPLAYS      => displays_tb,
        SEGMENTOS     => segmentos_tb,
        LEDS_PROGRESO => leds_prog_tb,
        LEDS_RGB      => leds_rgb_tb,
        BUZZER_PIN    => buzzer_tb
    );

    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		

        rst_n_tb <= '0';
        wait for 100 ns;
        
        rst_n_tb <= '1';
        wait for 100 ns;
        
        --Sonido de cambio de vehículo
        tipo_v_tb <= '1';
        wait for 10 us;
        
        --Sonido de cambio de dificultad
        diff_sw_tb <= "010";
        wait for 10 us;

        btn_start_tb <= '1';
        wait for 50 ns;
        
        btn_start_tb <= '0';
        wait for 200 ns;


        for i in 0 to 3 loop
            btn_l_tb <= '1';
            wait for 40 ns;
            btn_l_tb <= '0';
            wait for 100 ns;
        end loop;

        tipo_v_tb <= '1';
        diff_sw_tb <= "100"; 
        
        wait for 500 ns;

        btn_r_tb <= '1';
        wait for 40 ns;
        
        btn_r_tb <= '0';
        wait for 200 ns;

        wait for 2000 ns;
        
        rst_n_tb <= '0';
        wait for 100 ns;
        
        rst_n_tb <= '1';
        
        report "Fin de la simulacion";
        wait;
    end process;

end sim;
