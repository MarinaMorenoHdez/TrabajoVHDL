library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Game_Logic is
    Port ( 
        CLK             : in  STD_LOGIC;
        RST_N           : in  STD_LOGIC;
        
        ENABLE_GAME     : in  STD_LOGIC;
        RESET_INTERNAL  : in  STD_LOGIC;
        
        TICK_L          : in  STD_LOGIC;
        TICK_R          : in  STD_LOGIC;
        SW_VEHICLE      : in  STD_LOGIC;
        SW_DIFFICULTY   : in  STD_LOGIC_VECTOR(2 downto 0); -- Ahora usaremos "101"
        
        COLLISION_FLAG  : out STD_LOGIC;
        WIN_FLAG        : out STD_LOGIC;
        
        CAR_POS_OUT     : out INTEGER range 0 to 15; 
        ROAD_L_LIMIT    : out INTEGER range 0 to 15; 
        ROAD_R_LIMIT    : out INTEGER range 0 to 15; 
        PROGRESS_LEDS   : out STD_LOGIC_VECTOR(15 downto 0) 
    );
end Game_Logic;

architecture Behavioral of Game_Logic is

    -- ========================================================================
    -- CONFIGURACIÓN 
    -- ======================================================================
    -- Valores para SIMULACIÓN !!!!!!!!!!!!!!!
    -- constant SPEED_EASY   : integer := 5; 
    -- constant SPEED_MEDIUM : integer := 3;
    -- constant SPEED_HARD   : integer := 2;
    -- constant STEPS_PER_LED : integer := 2; 

    -- Valores para FPGA REAL (Descomentar para bitstream)
    constant SPEED_EASY   : integer :=5 ;--50_000_000; -- 0.5s
    constant SPEED_MEDIUM : integer :=3 ;--25_000_000; -- 0.25s
    constant SPEED_HARD   : integer :=2 ;--10_000_000; -- 0.1s
    constant STEPS_PER_LED : integer :=2 ;--10;        -- 10 pasos para 1 LED :)

    -- SEÑALES INTERNAS
    signal car_pos        : integer range 0 to 15 := 7; 
    signal road_l         : integer range 0 to 15 := 13; 
    signal road_r         : integer range 0 to 15 := 2;
    
    signal lfsr_reg       : std_logic_vector(15 downto 0) := x"ACE1"; 
    signal random_action  : std_logic_vector(1 downto 0);
    
    signal tick_counter     : integer := 0;
    signal current_max_tick : integer := SPEED_EASY;
    
    signal progress_count   : integer range 0 to 16 := 0; 
    signal led_step_counter : integer range 0 to STEPS_PER_LED := 0; 

begin

    random_action <= lfsr_reg(1 downto 0);

    process(CLK)
        variable lfsr_next : std_logic;
        variable move_step : integer;
    begin
        if rising_edge(CLK) then
            if RST_N = '0' or RESET_INTERNAL = '1' then
                car_pos          <= 7;
                road_l           <= 13;
                road_r           <= 2;
                tick_counter     <= 0;
                progress_count   <= 0;
                led_step_counter <= 0;
                lfsr_reg         <= x"ACE1";
                COLLISION_FLAG   <= '0';
                WIN_FLAG         <= '0';
            
            elsif ENABLE_GAME = '1' then
                
                -- TIPO DE VEHÍCULO
                if SW_VEHICLE = '1' then
                    move_step := 1; -- moto
                else
                    move_step := 2; -- coche
                end if;

                -- MOVIMIENTO JUGADOR
                if TICK_L = '1' then
                    if (car_pos + move_step) <= 15 then 
                         car_pos <= car_pos + move_step;
                    else
                         car_pos <= 15; 
                    end if;
                elsif TICK_R = '1' then
                    if (car_pos - move_step) >= 0 then 
                         car_pos <= car_pos - move_step; 
                    else
                         car_pos <= 0; 
                    end if;
                end if;

                -- MOTOR DE TIEMPO 
                case SW_DIFFICULTY is
                    when "001" => current_max_tick <= SPEED_EASY;
                    when "010" => current_max_tick <= SPEED_MEDIUM;
                    when "100" => current_max_tick <= SPEED_HARD;

                    -- MODO PROGRESIVO POR ESCALONES
                    when "101" => 
                        if progress_count < 6 then -- menos de 6 LEDs encendidos
                            current_max_tick <= SPEED_EASY;   -- Velocidad lenta
                        elsif progress_count < 12 then
                            current_max_tick <= SPEED_MEDIUM; -- Velocidad media
                        else
                            current_max_tick <= SPEED_HARD;   -- Velocidad Rápida
                        end if;

                    when others => current_max_tick <= SPEED_EASY;
                end case;
                
                -- Contador del Timer
                if tick_counter < current_max_tick then
                    tick_counter <= tick_counter + 1;
                else
                    tick_counter <= 0; 
                    
                    --  Azar
                    lfsr_next := lfsr_reg(15) xor lfsr_reg(13) xor lfsr_reg(12) xor lfsr_reg(10);
                    lfsr_reg <= lfsr_reg(14 downto 0) & lfsr_next;
                    
                    --  Mover Carretera
                    case random_action is
                        when "01" => --Solo nos movemos si la pared IZQUIERDA no se sale del mapa (tope 15)
                            if road_l < 15 then road_l <= road_l + 1; road_r <= road_r + 1; end if;
                        when "10" => --Solo nos movemos si la pared DERECHA no se sale del mapa (tope 0)
                            if road_r > 0 then road_l <= road_l - 1; road_r <= road_r - 1; end if;
                        when "11" => -- ESTRECHAR O ENSANCHAR
                        -- (L - R) > 3 significa que hay al menos 3 huecos libres.
                        -- Como el coche ocupa 2 huecos, estrechar aquí es seguro pero difícil.
                            if (road_l - road_r) > 3 then 
                                road_l <= road_l - 1; 
                            else
                            -- Si entramos aquí es que el hueco es de 3 o menos.
                            -- Para evitar que sea imposible, "abrimos" la carretera.
                                if road_l < 15 then road_l <= road_l + 1; end if;
                                if road_r > 0  then road_r <= road_r - 1; end if;
                            end if;
                        when others => null;
                    end case;

                    -- Progreso con Divisor de Pasos
                    if progress_count < 16 then
                        if led_step_counter < (STEPS_PER_LED - 1) then
                            led_step_counter <= led_step_counter + 1;
                        else
                            led_step_counter <= 0; 
                            progress_count <= progress_count + 1; 
                        end if;
                    else
                         WIN_FLAG <= '1'; 
                    end if;
                    
                end if; -- Fin Timer

                -- Colisiones
                if (car_pos >= road_l) or (car_pos <= road_r) then
                    COLLISION_FLAG <= '1';
                end if;

            end if;
        end if;
    end process;

    -- SALIDAS
    CAR_POS_OUT  <= car_pos;
    ROAD_L_LIMIT <= road_l;
    ROAD_R_LIMIT <= road_r;
    
    with progress_count select
        PROGRESS_LEDS <= x"0000" when 0,
                         x"0001" when 1,
                         x"0003" when 2,
                         x"0007" when 3,
                         x"000F" when 4,
                         x"001F" when 5,
                         x"003F" when 6,
                         x"007F" when 7,
                         x"00FF" when 8,
                         x"01FF" when 9,
                         x"03FF" when 10,
                         x"07FF" when 11,
                         x"0FFF" when 12,
                         x"1FFF" when 13,
                         x"3FFF" when 14,
                         x"7FFF" when 15,
                         x"FFFF" when others;

end Behavioral;