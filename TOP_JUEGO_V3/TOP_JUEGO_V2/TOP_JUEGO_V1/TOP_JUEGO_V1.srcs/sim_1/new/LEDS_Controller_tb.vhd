library IEEE;
use IEEE.std_logic_1164.all;

entity LEDS_Controller_tb is
end entity LEDS_Controller_tb;

architecture behavioral of LEDS_Controller_tb is

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

    signal s_CLK           : STD_LOGIC := '0';
    signal s_RST_N         : STD_LOGIC := '0';
    signal s_current_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal s_progress      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    
    signal s_LEDS_PROGRESS : STD_LOGIC_VECTOR(15 downto 0);
    signal s_LEDS_RGB      : STD_LOGIC_VECTOR(2 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    uut: LEDS_Controller
    port map (
        CLK => s_CLK,
        RST_N => s_RST_N,
        current_state => s_current_state,
        progress => s_progress,
        LEDS_PROGRESS => s_LEDS_PROGRESS,
        LEDS_RGB => s_LEDS_RGB
    );

    clk_gen: process
    begin
        s_CLK <= '0';
        wait for CLK_PERIOD / 2;
        s_CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;
    
    stim_gen: process
    begin
        s_RST_N <= '0';
        wait for 20 ns;
        s_RST_N <= '1';
        wait for 20 ns;

        --  INICIO
        s_current_state <= "00";
        s_progress <= (others => '0');
        wait for 50 ns;

        --  JUGANDO
        s_current_state <= "01";
        s_progress <= x"00FF";
        wait for 50 ns;

        --  PERDIDO
        s_current_state <= "10";
        wait for 50 ns;

        --  GANADO
        s_current_state <= "11";
        s_progress <= x"FFFF";
        wait for 50 ns;

        assert false report "Simulación terminada correctamente." severity failure;
    end process;
end architecture behavioral;
