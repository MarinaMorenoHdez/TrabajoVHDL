library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Controller_tb is
end Display_Controller_tb;

architecture Behavioral of Display_Controller_tb is

    component Display_Controller is
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
            DISPLAY       : out STD_LOGIC_VECTOR (7 downto 0);
            SEGMENT       : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    signal CLK           : STD_LOGIC := '0';
    signal RST_N         : STD_LOGIC := '0';
    signal current_state : STD_LOGIC_VECTOR (1 downto 0) := "00";
    
    signal tipo_vehi_in  : STD_LOGIC := '0';
    signal vehi_pos      : integer range 0 to 15 := 0;
    
    signal road_left     : integer range 0 to 15 := 0;
    signal road_right    : integer range 0 to 15 := 15;
    
    signal DISPLAY       : STD_LOGIC_VECTOR (7 downto 0);
    signal SEGMENT       : STD_LOGIC_VECTOR (6 downto 0);

    constant CLK_PERIOD : time := 10 ns; 

begin

    uut: Display_Controller
    port map (
        CLK           => CLK,
        RST_N         => RST_N,
        current_state => current_state,
        tipo_vehi_in  => tipo_vehi_in,
        vehi_pos      => vehi_pos, 
        road_left     => road_left,
        road_right    => road_right,
        DISPLAY       => DISPLAY,
        SEGMENT       => SEGMENT
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
        
        current_state <= "01"; 
        tipo_vehi_in  <= '0';
        vehi_pos      <= 9;
        road_left     <= 0; 
        road_right    <= 15;
        wait for 2 ms; 
        
        road_left     <= 1;
        road_right    <= 14;
        wait for 2 ms;
        
        vehi_pos      <= 7;
        road_left     <= 2;
        road_right    <= 13;
        wait for 2 ms;
        
        current_state <= "10";
        wait for 2 ms;
        
        assert false report "Simulación Finalizada Correctamente" severity failure;
    end process;

end Behavioral;
