----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.12.2025 17:56:14
-- Design Name: 
-- Module Name: Buzzer_controller - Behavioral
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

entity Buzzer_controller is
Port (
        CLK             : in  STD_LOGIC;
        RST_N           : in  STD_LOGIC; 
        current_state   : in  STD_LOGIC_VECTOR(1 downto 0);
        tipo_vehi_in    : in  STD_LOGIC;
        difficulty_sw   : in  STD_LOGIC_VECTOR(2 downto 0); 
        
        BUZZER_OUT      : out STD_LOGIC
    );
end Buzzer_controller;

architecture Behavioral of Buzzer_controller is

    signal prev_difficulty : std_logic_vector(2 downto 0) := (others => '0');
    signal prev_vehicle    : std_logic := '0';
    signal prev_state      : std_logic_vector(1 downto 0) := "00";
    
    signal trigger_select  : std_logic := '0';
    signal trigger_pierde   : std_logic := '0';
    signal trigger_gana     : std_logic := '0';
    
    constant DIV_TONO_AGUDO : integer := 50000; -- 10 en tb/ 50000
    constant DIV_TONO_GRAVE  : integer := 200000; -- 40 en tb/ 200000
    constant DURACION_BUZZER : integer := 20000000; -- 2000 en tb/ 20000000
    
    signal contador_tono      : integer range 0 to DIV_TONo_GRAVE := 0;
    signal duracion  : integer range 0 to (DURACION_BUZZER * 3) := 0;
    
    signal buzzer_active     : std_logic := '0';
    signal buzzer_pwm_int    : std_logic := '0'; 
    signal current_tone_div  : integer := DIV_TONO_AGUDO;
    
begin

    process(CLK, RST_N)
    begin
        if RST_N = '0' then -- Reset activo bajo
            buzzer_active <= '0';
            buzzer_pwm_int <= '0';
            duracion <= 0;
            prev_difficulty <= (others => '0');
            prev_vehicle <= '0';
            prev_state <= "00";
        elsif rising_edge(CLK) then
        
            trigger_select <= '0'; 
            trigger_pierde <= '0'; 
            trigger_gana <= '0';
            
            -- Sonido al seleccionar nivel o vehículo
            if (difficulty_sw /= prev_difficulty) or (tipo_vehi_in /= prev_vehicle) then
                 trigger_select <= '1';
            end if;
            -- Sonido al ganar o perder
            if (current_state = "10") and (prev_state /= "10") then
                trigger_pierde <= '1';
            end if;
            if (current_state = "11") and (prev_state /= "11") then
                trigger_gana <= '1';
            end if;
            
            prev_difficulty <= difficulty_sw;
            prev_vehicle    <= tipo_vehi_in;
            prev_state      <= current_state;
             
            if buzzer_active = '0' then
                if trigger_pierde = '1' then
                    buzzer_active <= '1';
                    duracion <= DURACION_BUZZER * 3; 
                    current_tone_div <= DIV_TONO_AGUDO;
                    contador_tono <= 0;
                elsif (trigger_select = '1') or (trigger_gana = '1') then
                    buzzer_active <= '1';
                    duracion <= DURACION_BUZZER; 
                    current_tone_div <= DIV_TONO_AGUDO;
                    contador_tono <= 0;
                end if;
                buzzer_pwm_int <= '0'; -- Silencio  
            else
                if duracion > 0 then
                    duracion <= duracion - 1;
                    
                    if contador_tono < current_tone_div then
                        contador_tono <= contador_tono + 1;
                    else
                        contador_tono <= 0;
                        buzzer_pwm_int <= not buzzer_pwm_int; -- Toggle
                    end if;
                else
                    buzzer_active <= '0'; -- Fin del sonido
                end if;
            end if;
        end if;
    end process;
    
    BUZZER_OUT <= buzzer_pwm_int when buzzer_active = '1' else '0';
                     

end Behavioral;
