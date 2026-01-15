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
        SW_DIFFICULTY   : in  STD_LOGIC_VECTOR(2 downto 0); 
        
        COLLISION_FLAG  : out STD_LOGIC;
        WIN_FLAG        : out STD_LOGIC;
        
        VEHI_POS_OUT    : out INTEGER range 0 to 15; 
        ROAD_L_LIMIT    : out INTEGER range 0 to 15; 
        ROAD_R_LIMIT    : out INTEGER range 0 to 15; 
        PROGRESS_LEDS   : out STD_LOGIC_VECTOR(15 downto 0) 
    );
end Game_Logic;

architecture Behavioral of Game_Logic is

    -- CONFIGURACIÓN  
    constant SPEED_EASY   : integer := 45_000_000; -- 0.45s
    constant SPEED_MEDIUM : integer := 30_000_000; -- 0.30s
    constant SPEED_HARD   : integer := 15_000_000; -- 0.15s
    
    constant STEPS_PER_LED : integer := 5; 

    -- SEÑALES INTERNAS
    signal vehi_pos       : integer range 0 to 15 := 7; 
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
        variable lfsr_next      : std_logic;
        variable move_step      : integer;
        variable puede_ir_izq   : boolean;
        variable puede_ir_der   : boolean;
    begin
        if rising_edge(CLK) then
            if RST_N = '0' or RESET_INTERNAL = '1' then
                vehi_pos         <= 7;
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

                -- CALCULAR CAPACIDAD DE MOVIMIENTO DEL JUGADOR
                puede_ir_izq := (vehi_pos + move_step) < road_l;
                puede_ir_der := (vehi_pos - move_step) > road_r;

                -- MOVIMIENTO JUGADOR
                if TICK_L = '1' then
                    if (vehi_pos + move_step) <= 15 then 
                         vehi_pos <= vehi_pos + move_step;
                    else
                         vehi_pos <= 15; 
                    end if;
                elsif TICK_R = '1' then
                    if (vehi_pos - move_step) >= 0 then 
                         vehi_pos <= vehi_pos - move_step; 
                    else
                         vehi_pos <= 0; 
                    end if;
                end if;

                -- MOTOR DE TIEMPO 
                case SW_DIFFICULTY is
                    when "001" => current_max_tick <= SPEED_EASY;
                    when "010" => current_max_tick <= SPEED_MEDIUM;
                    when "100" => current_max_tick <= SPEED_HARD;
                    when "101" => 
                        if progress_count < 6 then
                            current_max_tick <= SPEED_EASY;
                        elsif progress_count < 12 then
                            current_max_tick <= SPEED_MEDIUM;
                        else
                            current_max_tick <= SPEED_HARD;
                        end if;
                    when others => current_max_tick <= SPEED_EASY;
                end case;
                
                -- Contador del Timer
                if tick_counter < current_max_tick then
                    tick_counter <= tick_counter + 1;
                else
                    tick_counter <= 0; 
                    
                    lfsr_next := lfsr_reg(15) xor lfsr_reg(13) xor lfsr_reg(12) xor lfsr_reg(10);
                    lfsr_reg <= lfsr_reg(14 downto 0) & lfsr_next;
                    
                    -- Mover Carretera con Lógica Anti-Bloqueo
                    case random_action is
                        when "01" => -- Intento mover ambos a la IZQUIERDA (subir valor)
                            if road_l < 15 then
                                -- Si el borde derecho (road_r) va a tocar al coche
                                if (road_r + 1) >= vehi_pos then
                                    -- Solo permitimos si el coche tiene espacio a la izquierda para esquivar
                                    if puede_ir_izq then
                                        road_l <= road_l + 1; road_r <= road_r + 1;
                                    else
                                        -- Si no tiene salida, forzamos alivio hacia el otro lado
                                        if road_r > 0 then road_l <= road_l - 1; road_r <= road_r - 1; end if;
                                    end if;
                                else
                                    road_l <= road_l + 1; road_r <= road_r + 1;
                                end if;
                            end if;

                        when "10" => -- Intento mover ambos a la DERECHA (bajar valor)
                            if road_r > 0 then
                                -- Si el borde izquierdo (road_l) va a tocar al coche
                                if (road_l - 1) <= vehi_pos then
                                    -- Solo permitimos si el coche tiene espacio a la derecha para esquivar
                                    if puede_ir_der then
                                        road_l <= road_l - 1; road_r <= road_r - 1;
                                    else
                                        -- Si no tiene salida, forzamos alivio hacia el otro lado
                                        if road_l < 15 then road_l <= road_l + 1; road_r <= road_r + 1; end if;
                                    end if;
                                else
                                    road_l <= road_l - 1; road_r <= road_r - 1;
                                end if;
                            end if;

                        when "11" => 
                            -- GARANTIZAR ESPACIO MÍNIMO (Hueco según vehículo + margen)
                            if (road_l - road_r) > (move_step + 3) then 
                                -- Si cerrar road_l atrapa al coche sin salida a la derecha
                                if (road_l - 1 <= vehi_pos) and not puede_ir_der then
                                    road_l <= road_l + 1; -- Abrimos por seguridad
                                -- Si cerrar road_r atrapa al coche sin salida a la izquierda
                                elsif (road_r + 1 >= vehi_pos) and not puede_ir_izq then
                                    road_r <= road_r - 1; -- Abrimos por seguridad
                                else
                                    -- Es seguro estrechar un poco
                                    road_l <= road_l - 1;
                                    road_r <= road_r + 1;
                                end if;
                            else
                                -- Si el hueco es muy pequeño, obligamos a ensanchar
                                if road_l < 15 then road_l <= road_l + 1; end if;
                                if road_r > 0  then road_r <= road_r - 1; end if;                                         
                            end if;
                        when others => null;
                    end case;

                    -- Progreso
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
                    
                end if; 

                -- Colisiones (Se mantiene la lógica para cuando el jugador no esquiva)
                if (vehi_pos >= road_l) or (vehi_pos <= road_r) then
                    COLLISION_FLAG <= '1';
                end if;

            end if;
        end if;
    end process;

    -- SALIDAS
    VEHI_POS_OUT <= vehi_pos;
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