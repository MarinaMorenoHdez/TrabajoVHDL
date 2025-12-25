library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Input_Manager is
    Generic (
        -- Este valor se pasará al Debouncer interno.
        -- 1,000,000 para implementación real (10ms)
        -- 5 o 10 para simulación
        DEBOUNCE_CYCLES : integer := 1000000 
    );
    Port ( 
        CLK             : in  STD_LOGIC;
        RST_N             : in  STD_LOGIC; -- flanco subida
        
        -- Entradas Físicas
        BTN_L_IN        : in  STD_LOGIC;
        BTN_R_IN        : in  STD_LOGIC;
        BTN_START_IN    : in  STD_LOGIC;
        SW_VEHICLE_IN   : in  STD_LOGIC;
        SW_DIFF_IN      : in  STD_LOGIC_VECTOR (2 downto 0);
        
        -- Salidas Procesadas
        TICK_L          : out STD_LOGIC;
        TICK_R          : out STD_LOGIC;
        TICK_START      : out STD_LOGIC;
        SW_VEHICLE_SYNC : out STD_LOGIC;
        SW_DIFF_SYNC    : out STD_LOGIC_VECTOR (2 downto 0)
    );
end Input_Manager;

architecture Structural of Input_Manager is

    ---------------------------------------------------------------------------
    -- DECLARACIÓN DE COMPONENTES
    ---------------------------------------------------------------------------
    component Synchronizer
        Port ( CLK : in STD_LOGIC; ASYNC_IN : in STD_LOGIC; SYNC_OUT : out STD_LOGIC);
    end component;

    component Edge_Detector
        Port ( CLK : in STD_LOGIC; RST_N : in STD_LOGIC; SIG_IN : in STD_LOGIC; EDGE_OUT : out STD_LOGIC);
    end component;

    component Debouncer
        Generic ( TIMEOUT_CYCLES : integer );
        Port ( CLK : in STD_LOGIC; RST_N : in STD_LOGIC; BTN_IN : in STD_LOGIC; BTN_OUT : out STD_LOGIC);
    end component;

    ---------------------------------------------------------------------------
    -- SEÑALES INTERNAS (Cables de conexión)
    ---------------------------------------------------------------------------
    -- Cables para BTN_L
    signal s_btn_l_sync : std_logic;
    signal s_btn_l_deb  : std_logic;
    
    -- Cables para BTN_R
    signal s_btn_r_sync : std_logic;
    signal s_btn_r_deb  : std_logic;

    -- Cables para BTN_START
    signal s_btn_start_sync : std_logic;
    signal s_btn_start_deb  : std_logic;

begin

    ---------------------------------------------------------------------------
    -- 1. CADENA DEL BOTÓN IZQUIERDO (L)
    ---------------------------------------------------------------------------
    Inst_Sync_L: Synchronizer port map (
        CLK => CLK, ASYNC_IN => BTN_L_IN, SYNC_OUT => s_btn_l_sync
    );
    
    Inst_Deb_L: Debouncer 
    generic map ( TIMEOUT_CYCLES => DEBOUNCE_CYCLES )
    port map (
        CLK => CLK, RST_N => RST_N, BTN_IN => s_btn_l_sync, BTN_OUT => s_btn_l_deb
    );
    
    Inst_Edge_L: Edge_Detector port map (
        CLK => CLK, RST_N => RST_N, SIG_IN => s_btn_l_deb, EDGE_OUT => TICK_L
    );

    ---------------------------------------------------------------------------
    -- 2. CADENA DEL BOTÓN DERECHO (R)
    ---------------------------------------------------------------------------
    Inst_Sync_R: Synchronizer port map (
        CLK => CLK, ASYNC_IN => BTN_R_IN, SYNC_OUT => s_btn_r_sync
    );
    
    Inst_Deb_R: Debouncer 
    generic map ( TIMEOUT_CYCLES => DEBOUNCE_CYCLES )
    port map (
        CLK => CLK, RST_N => RST_N, BTN_IN => s_btn_r_sync, BTN_OUT => s_btn_r_deb
    );
    
    Inst_Edge_R: Edge_Detector port map (
        CLK => CLK, RST_N => RST_N, SIG_IN => s_btn_r_deb, EDGE_OUT => TICK_R
    );

    ---------------------------------------------------------------------------
    -- 3. CADENA DEL BOTÓN START
    ---------------------------------------------------------------------------
    Inst_Sync_Start: Synchronizer port map (
        CLK => CLK, ASYNC_IN => BTN_START_IN, SYNC_OUT => s_btn_start_sync
    );
    
    Inst_Deb_Start: Debouncer 
    generic map ( TIMEOUT_CYCLES => DEBOUNCE_CYCLES )
    port map (
        CLK => CLK, RST_N => RST_N, BTN_IN => s_btn_start_sync, BTN_OUT => s_btn_start_deb
    );
    
    Inst_Edge_Start: Edge_Detector port map (
        CLK => CLK, RST_N => RST_N, SIG_IN => s_btn_start_deb, EDGE_OUT => TICK_START
    );

    ---------------------------------------------------------------------------
    -- 4. SWITCHES (Solo Sincronización)
    ---------------------------------------------------------------------------
    -- Switch Vehículo
    Inst_Sync_Veh: Synchronizer port map (
        CLK => CLK, ASYNC_IN => SW_VEHICLE_IN, SYNC_OUT => SW_VEHICLE_SYNC
    );

    -- Switches Dificultad (Usamos un bucle generate para los 3 bits)
    Gen_Sync_Diff: for i in 0 to 2 generate
        Inst_Sync_Diff: Synchronizer port map (
            CLK => CLK, 
            ASYNC_IN => SW_DIFF_IN(i), 
            SYNC_OUT => SW_DIFF_SYNC(i)
        );
    end generate;

end Structural;