library verilog;
use verilog.vl_types.all;
entity randomnessExtractor is
    generic(
        BUFFER_LOGSIZE  : integer := 8
    );
    port(
        clock           : in     vl_logic;
        from_ac97_data  : in     vl_logic_vector(7 downto 0);
        ready           : in     vl_logic;
        \buffer\        : out    vl_logic_vector(255 downto 0)
    );
end randomnessExtractor;
