library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TOP_JUEGO is
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
end TOP_JUEGO;

architecture Structural of TOP_JUEGO is
    
    component FSM is
        Generic( tiempo_espera : integer := 500_000_000 );
        Port (
            CLK                   : in  STD_LOGIC;
            RST_N                 : in  STD_LOGIC;
            START_TICK            : in  STD_LOGIC;
            GAME_OVER_SIGNAL      : in  STD_LOGIC;
            LEVEL_COMPLETE_SIGNAL : in  STD_LOGIC;
            CURRENT_STATE_OUT     : out STD_LOGIC_VECTOR(1 downto 0) 
        );
    end component;
    
    component Input_Manager is
        Generic ( DEBOUNCE_CYCLES : integer := 1_000_000 );
        Port ( 
            CLK             : in  STD_LOGIC;
            RST_N           : in  STD_LOGIC;
            BTN_L_IN        : in  STD_LOGIC;
            BTN_R_IN        : in  STD_LOGIC;
            BTN_START_IN    : in  STD_LOGIC;
            SW_VEHICLE_IN   : in  STD_LOGIC;
            SW_DIFF_IN      : in  STD_LOGIC_VECTOR (2 downto 0);
            TICK_L          : out STD_LOGIC;
            TICK_R          : out STD_LOGIC;
            TICK_START      : out STD_LOGIC;
            SW_VEHICLE_SYNC : out STD_LOGIC;
            SW_DIFF_SYNC    : out STD_LOGIC_VECTOR (2 downto 0)
        );
    end component;
    
    component Game_Logic is
        Port ( 
            CLK             : in  STD_LOGIC;
            RST_N           : in  STD_LOGIC;
            ENABLE_GAME     : in  STD_LOGIC;
            RESET_INTERNAL  : in  STD_LOGIC;
            TICK_L          : in  STD_LOGIC;
            TICK_R          : in  STD_LOGIC;
            SW_VEHICLE      : in  STD_LOGIC;
            SW_DIFFICULTY   : in  STD_LOGIC_VECTOR(2 downto 0);
            COLLISION_FLAG  : out STD_LOGIC;
            WIN_FLAG        : out STD_LOGIC;
            VEHI_POS_OUT    : out INTEGER range 0 to 15; 
            ROAD_L_LIMIT    : out INTEGER range 0 to 15; 
            ROAD_R_LIMIT    : out INTEGER range 0 to 15; 
            PROGRESS_LEDS   : out STD_LOGIC_VECTOR(15 downto 0) 
        );
    end component;
    
    component Output_Controller is
        Port ( 
            CLK           : in  STD_LOGIC;
            RST_N         : in  STD_LOGIC;
            current_state : in  STD_LOGIC_VECTOR(1 downto 0);
            tipo_vehi_in  : in  STD_LOGIC;
            vehi_pos      : in  INTEGER range 0 to 15;        
            road_left     : in  INTEGER range 0 to 15;
            road_right    : in  INTEGER range 0 to 15;
            progress      : in  STD_LOGIC_VECTOR(15 downto 0);
            difficulty_sw : in  std_logic_vector (2 downto 0);
            DISPLAY       : out STD_LOGIC_VECTOR (7 downto 0);
            SEGMENT       : out STD_LOGIC_VECTOR (6 downto 0);
            LEDS_PROGRESS : out STD_LOGIC_VECTOR (15 downto 0);
            LEDS_RGB      : out STD_LOGIC_VECTOR (2 downto 0);
            BUZZER_OUT    : out std_logic
        );
    end component;

    signal w_tick_l        : std_logic;
    signal w_tick_r        : std_logic;
    signal w_tick_start    : std_logic;
    signal w_sw_vehicle    : std_logic;
    signal w_sw_diff       : std_logic_vector(2 downto 0);
    signal w_current_state : std_logic_vector(1 downto 0);
    signal w_enable_game    : std_logic;
    signal w_reset_internal : std_logic;
    signal w_collision     : std_logic;
    signal w_win           : std_logic;
    signal w_vehi_pos      : integer range 0 to 15;
    signal w_road_l        : integer range 0 to 15;
    signal w_road_r        : integer range 0 to 15;
    signal w_progress      : std_logic_vector(15 downto 0);

begin

    w_enable_game <= '1' when w_current_state = "01" else '0';
    w_reset_internal <= '1' when w_current_state = "00" else '0';

    U_INPUT: Input_Manager 
    Generic Map ( DEBOUNCE_CYCLES => 1_000_000 )
    Port Map (
        CLK             => CLK100MHZ,
        RST_N           => RESET_N,
        BTN_L_IN        => BTN_L,
        BTN_R_IN        => BTN_R,
        BTN_START_IN    => BTN_START,
        SW_VEHICLE_IN   => TIPO_V_SW,
        SW_DIFF_IN      => DIFICULTAD_SW, 
        TICK_L          => w_tick_l,
        TICK_R          => w_tick_r,
        TICK_START      => w_tick_start,
        SW_VEHICLE_SYNC => w_sw_vehicle,
        SW_DIFF_SYNC    => w_sw_diff
    );

    U_FSM: FSM 
    Generic Map ( tiempo_espera => 500_000_000 )
    Port Map (
        CLK                   => CLK100MHZ,
        RST_N                 => RESET_N,
        START_TICK            => w_tick_start,
        GAME_OVER_SIGNAL      => w_collision,
        LEVEL_COMPLETE_SIGNAL => w_win,
        CURRENT_STATE_OUT     => w_current_state
    );

    U_GAME_LOGIC: Game_Logic 
    Port Map (
        CLK             => CLK100MHZ,
        RST_N           => RESET_N,
        ENABLE_GAME     => w_enable_game,
        RESET_INTERNAL  => w_reset_internal,
        TICK_L          => w_tick_l,
        TICK_R          => w_tick_r,
        SW_VEHICLE      => w_sw_vehicle,
        SW_DIFFICULTY   => w_sw_diff,
        COLLISION_FLAG  => w_collision,
        WIN_FLAG        => w_win,
        VEHI_POS_OUT    => w_vehi_pos,
        ROAD_L_LIMIT    => w_road_l,
        ROAD_R_LIMIT    => w_road_r,
        PROGRESS_LEDS   => w_progress
    );

    U_OUTPUT: Output_Controller 
    Port Map (
        CLK           => CLK100MHZ,
        RST_N         => RESET_N,
        current_state => w_current_state,
        tipo_vehi_in  => w_sw_vehicle, 
        vehi_pos      => w_vehi_pos,
        road_left     => w_road_l,
        road_right    => w_road_r,
        progress      => w_progress,
        DISPLAY       => DISPLAYS,
        SEGMENT       => SEGMENTOS,
        LEDS_PROGRESS => LEDS_PROGRESO,
        LEDS_RGB      => LEDS_RGB,
        difficulty_sw => w_sw_diff,
        BUZZER_OUT => BUZZER_PIN
    );

end Structural;