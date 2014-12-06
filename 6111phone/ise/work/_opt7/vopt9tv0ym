library verilog;
use verilog.vl_types.all;
entity femul is
    generic(
        W               : integer := 17;
        N               : integer := 15;
        C               : integer := 19;
        LOGC            : integer := 4;
        LOGN            : integer := 4
    );
    port(
        clock           : in     vl_logic;
        start           : in     vl_logic;
        a_in            : in     vl_logic_vector(254 downto 0);
        b_in            : in     vl_logic_vector(254 downto 0);
        ready           : out    vl_logic;
        done            : out    vl_logic;
        \out\           : out    vl_logic_vector(254 downto 0)
    );
end femul;
