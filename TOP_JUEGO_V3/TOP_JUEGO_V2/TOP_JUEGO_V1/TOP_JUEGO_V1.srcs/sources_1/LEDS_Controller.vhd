library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LEDS_Controller is
    Port(
        CLK           : in  STD_LOGIC;
        RST_N         : in  STD_LOGIC;
        current_state : in  STD_LOGIC_VECTOR(1 downto 0);
        progress      : in  STD_LOGIC_VECTOR(15 downto 0);
        LEDS_PROGRESS : out STD_LOGIC_VECTOR (15 downto 0);
        LEDS_RGB      : out STD_LOGIC_VECTOR (2 downto 0)
    );
end LEDS_Controller;

architecture behavioral of LEDS_Controller is
begin
    process(RST_N, current_state, progress)
    begin
        if RST_N = '0' then
            LEDS_PROGRESS <= (others => '0');
            LEDS_RGB      <= (others => '0'); 
        else
            LEDS_PROGRESS <= progress;

            case current_state is
                when "00" => -- INICIO
                    LEDS_RGB <= "111"; -- Blanco 
                when "01" => -- JUGANDO
                    LEDS_RGB <= "001"; -- Azul
                when "10" => -- PERDIDO
                    LEDS_RGB <= "100"; -- Rojo
                when "11" => -- GANADO
                    LEDS_RGB <= "010"; -- Verde
                when others =>
                    LEDS_RGB <= "000";
            end case;
        end if;
    end process;
end architecture behavioral;