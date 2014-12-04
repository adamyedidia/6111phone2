library verilog;
use verilog.vl_types.all;
entity receiveFrame is
    generic(
        WIDTH           : integer := 16;
        LOGSIZE         : integer := 1
    );
    port(
        clock           : in     vl_logic;
        serialClock     : in     vl_logic;
        serialData      : in     vl_logic;
        data            : out    vl_logic_vector;
        ready           : out    vl_logic;
        sampleReady     : out    vl_logic;
        index           : out    vl_logic_vector;
        i               : out    vl_logic_vector(15 downto 0)
    );
end receiveFrame;
