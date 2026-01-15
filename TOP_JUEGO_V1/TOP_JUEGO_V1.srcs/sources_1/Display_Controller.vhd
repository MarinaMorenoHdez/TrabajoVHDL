library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Controller is 
    generic(
        WIDTH : INTEGER := 16
    );
    
    Port (
        CLK           : in  STD_LOGIC;
        RST_N         : in  STD_LOGIC;
        current_state : in  STD_LOGIC_VECTOR (1 downto 0);
        tipo_vehi_in  : in  STD_LOGIC;
        vehi_pos      : in  integer range 0 to WIDTH - 1;    
        road_left     : in  integer range 0 to WIDTH - 1;
        road_right    : in  integer range 0 to WIDTH - 1;
        DISPLAY       : out STD_LOGIC_VECTOR (7 downto 0); -- Anodos
        SEGMENT       : out STD_LOGIC_VECTOR (6 downto 0)  -- Catodos (gfedcba)
    );
end Display_Controller;

architecture Behavioral of Display_Controller is 

    -- Segmentos activos a nivel BAJO ('0' = encendido)
    -- g f e d c b a
    constant car          : STD_LOGIC_VECTOR(6 downto 0) := "1000000"; -- '0' (g OFF)
    constant dibujo_der   : STD_LOGIC_VECTOR(6 downto 0) := "1001111"; -- Segmentos E,F
    constant dibujo_izq   : STD_LOGIC_VECTOR(6 downto 0) := "1111001"; -- Segmentos B,C
    
    -- Letras (espero que se entienda menos la W)
    constant char_W : std_logic_vector(6 downto 0) := "0101010"; 
    constant char_I : std_logic_vector(6 downto 0) := "1111001"; 
    constant char_N : std_logic_vector(6 downto 0) := "0101011"; 
    constant char_E : std_logic_vector(6 downto 0) := "0000110"; 
    constant char_R : std_logic_vector(6 downto 0) := "0101111"; 
    constant char_L : std_logic_vector(6 downto 0) := "1000111"; 
    constant char_O : std_logic_vector(6 downto 0) := "1000000"; 
    constant char_S : std_logic_vector(6 downto 0) := "0010010";
    
    signal counter : unsigned(19 downto 0) := (others => '0');
    signal select_display : integer range 0 to 7;

begin

    process(RST_N, CLK)
    begin
        if RST_N = '0' then
            counter <= (others => '0');
        elsif rising_edge(CLK) then
            counter <= counter + 1;
        end if;
    end process;
    
    -- Seleccionar display rápido
    select_display <= to_integer(counter(19 downto 17)); 
    
    process(select_display, vehi_pos, road_left, road_right, tipo_vehi_in, current_state)
        variable v_display : std_logic_vector(7 downto 0);
        variable v_segment : std_logic_vector(6 downto 0);
    begin
        v_segment := "1111111"; -- Apagado por defecto 

        -- Selección de Ánodo 
        case select_display is
            when 0 => v_display := "11111110"; 
            when 1 => v_display := "11111101";
            when 2 => v_display := "11111011"; 
            when 3 => v_display := "11110111";
            when 4 => v_display := "11101111"; 
            when 5 => v_display := "11011111";
            when 6 => v_display := "10111111"; 
            when 7 => v_display := "01111111";
            when others => v_display := "11111111";
        end case;

        -- LÓGICA DE ESTADOS
        case current_state is
            when "11" => -- WINNER
                case select_display is
                    when 5 => v_segment := char_W; 
                    when 4 => v_segment := char_I;
                    when 3 => v_segment := char_N; 
                    when 2 => v_segment := char_N;
                    when 1 => v_segment := char_E; 
                    when 0 => v_segment := char_R;
                    when others => v_segment := "1111111";
                end case;

            when "10" => -- LOSER
                case select_display is
                    when 4 => v_segment := char_L; 
                    when 3 => v_segment := char_O;
                    when 2 => v_segment := char_S; 
                    when 1 => v_segment := char_E;
                    when 0 => v_segment := char_R;
                    when others => v_segment := "1111111";
                end case;

            when others => -- JUGANDO
                -- Vehículo 
                if (vehi_pos / 2) = select_display then
                    if tipo_vehi_in = '1' then                                                  -- Moto
                        if (vehi_pos rem 2) = 0 then v_segment := v_segment and dibujo_izq;
                        else                         v_segment := v_segment and dibujo_der;
                        end if;
                    else                                                                        -- Coche
                        v_segment := v_segment and car;
                    end if;
                end if;
                
                if (road_left / 2) = select_display then
                    if (road_left rem 2) = 0 then v_segment := v_segment and dibujo_izq;
                    else                         v_segment := v_segment and dibujo_der;
                    end if;
                end if;
                if (road_right / 2) = select_display then
                    if (road_right rem 2) = 0 then v_segment := v_segment and dibujo_izq;
                    else                          v_segment := v_segment and dibujo_der;
                    end if;
                end if;
        end case;

        DISPLAY <= v_display;
        SEGMENT <= v_segment;
        
    end process;
   
end Behavioral;
