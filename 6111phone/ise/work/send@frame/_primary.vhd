library verilog;
use verilog.vl_types.all;
entity sendFrame is
    generic(
        WIDTH           : integer := 32;
        LOGSIZE         : integer := 1
    );
    port(
        clock           : in     vl_logic;
        start           : in     vl_logic;
        index           : out    vl_logic_vector;
        data            : in     vl_logic_vector;
        serialClock     : out    vl_logic;
        serialData      : out    vl_logic;
        readyAtNext     : out    vl_logic
    );
end sendFrame;
