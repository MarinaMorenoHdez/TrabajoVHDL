library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Output_Controller is
    generic(
        WIDTH : INTEGER := 16 -- leds y displays
    );
    
    Port (
        CLK           : in  STD_LOGIC;
        RST_N         : in  STD_LOGIC;
        
        current_state : in  STD_LOGIC_VECTOR(1 downto 0);
        tipo_vehi_in  : in  STD_LOGIC;
        vehi_pos      : in  INTEGER range 0 to WIDTH - 1;
        road_left     : in  INTEGER range 0 to WIDTH - 1;
        road_right    : in  INTEGER range 0 to WIDTH - 1;
        progress      : in  STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
        difficulty_sw : in  STD_LOGIC_VECTOR(2 downto 0);
                
        DISPLAY       : out STD_LOGIC_VECTOR (7 downto 0);
        SEGMENT       : out STD_LOGIC_VECTOR (6 downto 0);
        LEDS_PROGRESS : out STD_LOGIC_VECTOR (WIDTH - 1 downto 0);
        LEDS_RGB      : out STD_LOGIC_VECTOR (2 downto 0);
        BUZZER_OUT    : out STD_LOGIC
    );
end Output_Controller;

architecture Structural of Output_Controller is

    component Display_Controller is
        generic(
            WIDTH : INTEGER := 16
        );
        Port (
            CLK           : in  STD_LOGIC;
            RST_N         : in  STD_LOGIC;
            current_state : in  STD_LOGIC_VECTOR (1 downto 0);
            tipo_vehi_in  : in  STD_LOGIC;
            vehi_pos      : in  INTEGER range 0 to WIDTH - 1;
            road_left     : in  INTEGER range 0 to WIDTH - 1;
            road_right    : in  INTEGER range 0 to WIDTH - 1;
            DISPLAY       : out STD_LOGIC_VECTOR (7 downto 0);
            SEGMENT       : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    component LEDS_Controller is
        generic(
            WIDTH : INTEGER := 16
        );
        Port(
            CLK           : in  STD_LOGIC;
            RST_N         : in  STD_LOGIC;
            current_state : in  STD_LOGIC_VECTOR(1 downto 0);
            progress      : in  STD_LOGIC_VECTOR(WIDTH - 1 downto 0);
            LEDS_PROGRESS : out STD_LOGIC_VECTOR (WIDTH - 1 downto 0);
            LEDS_RGB      : out STD_LOGIC_VECTOR (2 downto 0)
        );
    end component;
    
    component Buzzer_controller is
        Port (
                CLK           : in  STD_LOGIC;
                RST_N         : in  STD_LOGIC;
                current_state : in  STD_LOGIC_VECTOR(1 downto 0);
                tipo_vehi_in  : in  STD_LOGIC;
                difficulty_sw : in  STD_LOGIC_VECTOR(2 downto 0);
                BUZZER_OUT    : out STD_LOGIC
            );
    end component;

begin

    Inst_Display_Controller: Display_Controller
    port map(
        CLK           => CLK,
        RST_N         => RST_N,
        current_state => current_state,
        tipo_vehi_in  => tipo_vehi_in,
        vehi_pos      => vehi_pos,
        road_left     => road_left,
        road_right    => road_right,
        DISPLAY       => DISPLAY,     
        SEGMENT       => SEGMENT       
    );

    Inst_LEDS_Controller: LEDS_Controller
    port map(
        CLK           => CLK,
        RST_N         => RST_N,
        current_state => current_state,
        progress      => progress,
        LEDS_PROGRESS => LEDS_PROGRESS,
        LEDS_RGB      => LEDS_RGB   
    );
    
    Inst_Buzzer_controller: Buzzer_controller
    port map(
        CLK           => CLK,
        RST_N         => RST_N,
        current_state => current_state, -- Para sonidos de win/crash
        tipo_vehi_in  => tipo_vehi_in,  -- Para sonido de cambio vehículo
        difficulty_sw => difficulty_sw, -- Para sonido de cambio dificultad
        BUZZER_OUT    => BUZZER_OUT     -- A la salida física
    );

end Structural;
