library verilog;
use verilog.vl_types.all;
entity sendFrame is
    generic(
        WIDTH           : integer := 16
    );
    port(
        clock           : in     vl_logic;
        start           : in     vl_logic;
        data            : in     vl_logic_vector;
        serialClock     : out    vl_logic;
        serialData      : out    vl_logic;
        readyAtNext     : out    vl_logic
    );
end sendFrame;
