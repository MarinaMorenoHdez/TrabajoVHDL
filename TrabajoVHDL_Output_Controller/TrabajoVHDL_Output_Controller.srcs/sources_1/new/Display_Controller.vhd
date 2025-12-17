library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Controller is 
    Port (
        CLK           : in  STD_LOGIC;
        RST_N         : in  STD_LOGIC;
        current_state : in  STD_LOGIC_VECTOR (1 downto 0);
        tipo_vehi_in  : in  STD_LOGIC;
        vehi_pos      : in  integer range 0 to 15;    
        road_left     : in  integer range 0 to 15;
        road_right    : in  integer range 0 to 15;
        DISPLAY       : out STD_LOGIC_VECTOR (7 downto 0); -- Anodos
        SEGMENT       : out STD_LOGIC_VECTOR (6 downto 0)  -- Catodos (gfedcba)
    );
end Display_Controller;

architecture Behavioral of Display_Controller is 

    -- Segmentos activos a nivel BAJO ('0' = encendido)
    -- g f e d c b a
    constant car          : STD_LOGIC_VECTOR(6 downto 0) := "1000000"; -- '0' (g OFF)
    constant dibujo_par   : STD_LOGIC_VECTOR(6 downto 0) := "1001111"; -- EF encendidos (lado izq digito)
    constant dibujo_impar : STD_LOGIC_VECTOR(6 downto 0) := "1111001"; -- BC encendidos (lado der digito)
    
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
    
    -- Selector de display (Multiplexación) ~95Hz
    select_display <= to_integer(counter(19 downto 17)); 
    
    process(select_display, vehi_pos, road_left, road_right, tipo_vehi_in)
        variable v_display : std_logic_vector(7 downto 0);
        variable v_segment : std_logic_vector(6 downto 0);
    begin
        -- Apagar todo por defecto (Lógica negativa)
        v_segment := "1111111"; 
        
        -- Selector de Anodos (Solo un '0' activo a la vez)
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
        
        -- Lógica del vehículo
        if tipo_vehi_in = '1' then
            -- MOTO (Usa dibujo vertical fino)
            if (vehi_pos / 2) = select_display then
                if (vehi_pos rem 2) = 0 then -- par (izquierda del digito)
                    v_segment := v_segment and dibujo_par;
                else -- impar (derecha del digito)
                    v_segment := v_segment and dibujo_impar; 
                end if;
            end if;
        else
            -- COCHE (Usa el "0" completo)
            if (vehi_pos / 2) = select_display then
                v_segment := v_segment and car; 
            end if;
        end if;
        
        -- Carretera Izquierda
        if (road_left / 2) = select_display then
            if (road_left rem 2) = 0 then 
                v_segment := v_segment and dibujo_par;
            else 
                v_segment := v_segment and dibujo_impar; 
            end if;
        end if;

        -- Carretera Derecha
        if (road_right / 2) = select_display then
            if (road_right rem 2) = 0 then 
                v_segment := v_segment and dibujo_par; 
            else 
                v_segment := v_segment and dibujo_impar;
            end if;
        end if;
  
        DISPLAY <= v_display;
        SEGMENT <= v_segment;

    end process;
   
end Behavioral;
