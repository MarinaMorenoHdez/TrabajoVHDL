----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2025 10:12:42
-- Design Name: 
-- Module Name: FSM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM is
    generic(
        tiempo_espera : integer := 500_000_000
        );

    Port (
        CLK           : in  STD_LOGIC;
        RST_N          : in  STD_LOGIC; -- Reset activo a nivel alto ('1')
        -- Entradas de eventos (Ticks/Señales de otros módulos)
        START_TICK          : in  STD_LOGIC; -- Pulso para pasar de MENU a JUEGO
        GAME_OVER_SIGNAL    : in  STD_LOGIC; -- Nivel alto si el coche choca (de Game_Logic)
        LEVEL_COMPLETE_SIGNAL : in STD_LOGIC; -- Nivel alto si se acaba el tiempo (de Game_Logic)
        -- Salida de estado actual codificada
        -- "00": MENU, "01": JUEGO, "10": PIERDE, "11": GANA
        CURRENT_STATE_OUT   : out STD_LOGIC_VECTOR(1 downto 0) 
    );
end FSM;

architecture Behavioral of FSM is

    type fsm_state_t is (S_MENU, S_GAME, S_LOSE, S_WIN);
    signal current_state, next_state : fsm_state_t;
    
    signal timer_counter : unsigned(31 downto 0) := (others => '0'); --inicializar para el tb
    signal timeout_value : unsigned(31 downto 0);
begin

    timeout_value <= to_unsigned(tiempo_espera, 32);
    
    --Process secuencial del contador y reset
    proc_1 : process(CLK, RST_N)
    begin
        if RST_N = '0' then
            current_state <= S_MENU;
            timer_counter <= (others => '0');
        elsif rising_edge(CLK) then
            current_state <= next_state;
            
            if (current_state = S_LOSE or current_state = S_WIN) then
                if timer_counter < timeout_value then
                    timer_counter <= timer_counter +1;
                end if;
            else
                timer_counter <= (others => '0');
            end if;
        end if;
    end process;
    
    --Process combinacional cambio de estados
    proc_2 : process(current_state, START_TICK, GAME_OVER_SIGNAL, LEVEL_COMPLETE_SIGNAL, timer_counter, timeout_value)
        begin
            next_state <= current_state;
            
            case current_state is
                -- 1) MENU - JUEGO
                when S_MENU =>
                    if START_TICK = '1' then
                        next_state <= S_GAME;
                     end if;
                -- 2) JUEGO - PERDER / GANAR
                when S_GAME =>
                    if GAME_OVER_SIGNAL = '1' then
                        next_state <= S_LOSE;
                    elsif LEVEL_COMPLETE_SIGNAL = '1' then
                        next_state <= S_WIN;
                    end if;
                -- 3) PERDER - MENU    
                when S_LOSE =>
                    if (START_TICK = '1') or (timer_counter >= timeout_value) then
                        next_state <= S_MENU;
                    end if;
                -- 4) GANAR - MENU
                when S_WIN => 
                    if (START_TICK = '1') or (timer_counter >= timeout_value) then
                        next_state <= S_MENU;
                    end if;
                
                when others =>
                    next_state <= S_MENU;     
                end case;
        end process;
        
        with current_state select CURRENT_STATE_OUT <=
            "00" when S_MENU,
            "01" when S_GAME,
            "10" when S_LOSE,
            "11" when S_WIN,
            "00" when others;
                
end Behavioral;
