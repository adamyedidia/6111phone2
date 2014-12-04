library verilog;
use verilog.vl_types.all;
entity sending_fsm is
    generic(
        PUBLIC_KEY_SIZE : integer := 256;
        WIDTH           : integer := 16;
        LOG_PUBLIC_KEY_SIZE: integer := 8;
        LOGSIZE         : integer := 4
    );
    port(
        clock           : in     vl_logic;
        curve_out       : in     vl_logic_vector;
        curve_done      : in     vl_logic;
        incoming_packet_header: in     vl_logic_vector;
        recordingToB    : out    vl_logic;
        recordAddr      : out    vl_logic_vector;
        recordData      : out    vl_logic_vector;
        done            : out    vl_logic
    );
end sending_fsm;
