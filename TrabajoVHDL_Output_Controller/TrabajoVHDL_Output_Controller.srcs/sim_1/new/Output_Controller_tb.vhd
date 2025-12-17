library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Output_Controller_tb is
end Output_Controller_tb;

architecture Behavioral of Output_Controller_tb is

    component Output_Controller is
        Port ( 
            CLK           : in  STD_LOGIC;
            RST_N         : in  STD_LOGIC;
            current_state : in  STD_LOGIC_VECTOR(1 downto 0);
            tipo_vehi_in  : in  STD_LOGIC;
            vehi_pos      : in  INTEGER range 0 to 15;
            road_left     : in  INTEGER range 0 to 15;
            road_right    : in  INTEGER range 0 to 15;
            progress      : in  STD_LOGIC_VECTOR(15 downto 0);
            DISPLAY       : out STD_LOGIC_VECTOR (7 downto 0);
            SEGMENT       : out STD_LOGIC_VECTOR (6 downto 0);
            LEDS_PROGRESS : out STD_LOGIC_VECTOR (15 downto 0);
            LEDS_RGB      : out STD_LOGIC_VECTOR (2 downto 0)
        );
    end component;

    signal CLK           : STD_LOGIC := '0';
    signal RST_N         : STD_LOGIC := '0';
    signal current_state : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal tipo_vehi_in  : STD_LOGIC := '0';
    signal vehi_pos      : INTEGER range 0 to 15 := 0;
    signal road_left     : INTEGER range 0 to 15 := 0;
    signal road_right    : INTEGER range 0 to 15 := 0;
    signal progress      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    signal DISPLAY       : STD_LOGIC_VECTOR (7 downto 0);
    signal SEGMENT       : STD_LOGIC_VECTOR (6 downto 0);
    signal LEDS_PROGRESS : STD_LOGIC_VECTOR (15 downto 0);
    signal LEDS_RGB      : STD_LOGIC_VECTOR (2 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: Output_Controller
    port map (
        CLK           => CLK,
        RST_N         => RST_N,
        current_state => current_state,
        tipo_vehi_in  => tipo_vehi_in,
        vehi_pos      => vehi_pos,
        road_left     => road_left,
        road_right    => road_right,
        progress      => progress,
        DISPLAY       => DISPLAY,
        SEGMENT       => SEGMENT,
        LEDS_PROGRESS => LEDS_PROGRESS,
        LEDS_RGB      => LEDS_RGB
    );

    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD / 2;
        CLK <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
    begin
        RST_N <= '0';
        wait for 100 ns;
        
        RST_N <= '1';
        current_state <= "00"; 
        progress      <= (others => '0');
        wait for 1 ms;

        current_state <= "01";
        vehi_pos      <= 7; 
        road_left     <= 0;  
        road_right    <= 1; 
        progress      <= "0000000011111111"; 
        wait for 10 ms; 
        
        road_left     <= 2; 
        road_right    <= 3;
        progress      <= "1111111111111111"; 
        wait for 10 ms;

        current_state <= "10";
        wait for 20 ms;

        current_state <= "11";
        wait for 10 ms;

        assert false report "Testbench Finalizado con Exito" severity failure;
        wait;
    end process;

end Behavioral;