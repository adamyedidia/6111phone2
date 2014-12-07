library verilog;
use verilog.vl_types.all;
entity sending_fsm is
    generic(
        SECRET_KEY_SIZE : integer := 255;
        PUBLIC_KEY_SIZE : integer := 255;
        WIDTH           : integer := 8;
        LOG_PUBLIC_KEY_SIZE: integer := 8;
        LOGSIZE         : integer := 6
    );
    port(
        clock           : in     vl_logic;
        start           : in     vl_logic;
        secret_key_seed : in     vl_logic_vector;
        incoming_packet_new: in     vl_logic;
        incoming_packet_read_index: out    vl_logic_vector;
        incoming_packet_read_data: in     vl_logic_vector;
        outgoing_packet_write_index: out    vl_logic_vector;
        outgoing_packet_write_data: out    vl_logic_vector;
        outgoing_packet_write_enable: out    vl_logic;
        outgoing_packet_sending: out    vl_logic;
        shared_key      : out    vl_logic_vector;
        done            : out    vl_logic;
        state           : out    vl_logic_vector(2 downto 0)
    );
end sending_fsm;
