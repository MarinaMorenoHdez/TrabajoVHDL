library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Synchronizer is
    Port ( 
        CLK       : in  STD_LOGIC;
        ASYNC_IN  : in  STD_LOGIC;
        SYNC_OUT  : out STD_LOGIC
    );
end Synchronizer;

architecture Behavioral of Synchronizer is
    signal s_reg1 : std_logic := '0';
    signal s_reg2 : std_logic := '0';
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Primer Flip-Flop captura la entrada asíncrona
            s_reg1 <= ASYNC_IN;
            -- Segundo Flip-Flop captura la salida del primero (ya estable)
            s_reg2 <= s_reg1;
        end if;
    end process;

    -- La salida es el segundo flip-flop
    SYNC_OUT <= s_reg2;

end Behavioral;