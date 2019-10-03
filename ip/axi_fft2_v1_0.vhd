library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils_pkg.all;

entity axi_fft2_v1_0 is
	generic (
		-- Users to add parameters here
        DATA_WIDTH : integer := 32;
        FFT_SIZE : integer := 8;
        FIXED_POINT_WIDTH : integer := 16;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 6;

		-- Parameters of Axi Slave Bus Interface S01_AXI
		C_S01_AXI_ID_WIDTH	: integer	:= 1;
		C_S01_AXI_DATA_WIDTH	: integer	:= 32;
		C_S01_AXI_ADDR_WIDTH	: integer	:= 12;
		C_S01_AXI_AWUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_ARUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_WUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_RUSER_WIDTH	: integer	:= 1;
		C_S01_AXI_BUSER_WIDTH	: integer	:= 1
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end axi_fft2_v1_0;

architecture arch_imp of axi_fft2_v1_0 is

    -- signal delclarations
        signal reset_s : std_logic;
        
    -- interface to the AXI controllers
        signal reg_data_o : std_logic_vector(maxc(log2c(FFT_SIZE*FFT_SIZE),DATA_WIDTH)-1 downto 0);
        signal log2w_wr_o : std_logic;
        signal width_wr_o : std_logic;
        signal log2h_wr_o : std_logic;
        signal height_wr_o : std_logic;
        signal cmd_wr_o : std_logic;
        
        signal addr_wr_o : std_logic;
        signal dataRE_wr_o : std_logic;
        signal dataIM_wr_o : std_logic;
        
        signal log2w_axi_i : std_logic_vector(log2c(log2c(FFT_SIZE))-1 downto 0);
        signal width_axi_i : std_logic_vector(log2c(FFT_SIZE)-1 downto 0);
        signal log2h_axi_i : std_logic_vector(log2c(log2c(FFT_SIZE))-1 downto 0);
        signal height_axi_i : std_logic_vector(log2c(FFT_SIZE)-1 downto 0);
        signal cmd_axi_i : std_logic;
        signal status_axi_i : std_logic;
        
        signal addr_axi_i : std_logic_vector(log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
        signal dataRE_axi_i : std_logic_vector(DATA_WIDTH-1 downto 0);
        signal dataIM_axi_i : std_logic_vector(DATA_WIDTH-1 downto 0);
        
--        signal mem_addr_o : std_logic_vector(C_S01_AXI_ADDR_WIDTH -((C_S00_AXI_DATA_WIDTH/32)+ 1)-1 downto 0); --log2c(FFT_SIZE*FFT_SIZE) downto 0);
--        signal mem_data_o : std_logic_vector(DATA_WIDTH-1 downto 0);
--        signal mem_wr_o : std_logic;
        
--        signal mem_re_axi_data_i : std_logic_vector(DATA_WIDTH-1 downto 0);
--        signal mem_im_axi_data_i : std_logic_vector(DATA_WIDTH-1 downto 0);
        
    -- interface to the fft2 module
        signal data_i_addr_o : STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
        signal dataRE_i : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        signal dataIM_i : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        signal data_rd_o : STD_LOGIC;
        signal data_rd_i : STD_LOGIC;
        
        signal data_o_addr_o : STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE)-1 downto 0);
        signal dataRE_o : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        signal dataIM_o : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        signal data_wr_o : STD_LOGIC;
        signal data_wr_i : STD_LOGIC;
        
        signal log2w : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
        signal width : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
        
        signal log2h : STD_LOGIC_VECTOR (log2c(log2c(FFT_SIZE))-1 downto 0);
        signal height : STD_LOGIC_VECTOR (log2c(FFT_SIZE)-1 downto 0);
        
        signal start : STD_LOGIC;
        signal ready : STD_LOGIC;
        
    -- auxiliary
        signal mem_addr_i : STD_LOGIC_VECTOR (log2c(FFT_SIZE*FFT_SIZE) downto 0);

begin

-- Instantiation of Axi Bus Interface S00_AXI
axi_fft2_v1_0_S00_AXI_inst : entity work.axi_fft2_v1_0_S00_AXI(arch_imp)
	generic map (
	    DATA_WIDTH => DATA_WIDTH,
	    FFT_SIZE => FFT_SIZE,
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    reg_data_o => reg_data_o,
        log2w_wr_o => log2w_wr_o,
        width_wr_o => width_wr_o,
        log2h_wr_o => log2h_wr_o,
        height_wr_o => height_wr_o,
        cmd_wr_o => cmd_wr_o,
        addr_wr_o => addr_wr_o,
        dataRE_wr_o => dataRE_wr_o,
        dataIM_wr_o => dataIM_wr_o,
        
        log2w_axi_i => log2w_axi_i,
        width_axi_i => width_axi_i,
        log2h_axi_i => log2h_axi_i,
        height_axi_i => height_axi_i,
        cmd_axi_i => cmd_axi_i,
        status_axi_i => status_axi_i,
        addr_axi_i => addr_axi_i,
        dataRE_axi_i => dataRE_axi_i,
        dataIM_axi_i => dataIM_axi_i,
        
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
	 reset_s <= not s00_axi_aresetn;
	 
	 -- mem_addr_i <= mem_addr_o(mem_addr_o'high) & mem_addr_o(log2c(FFT_SIZE*FFT_SIZE)- 1 downto 0);
	
mem_subsystem_inst: entity work.mem_subsystem(struct)
    generic map(
        DATA_WIDTH => DATA_WIDTH,
        FFT_SIZE => FFT_SIZE
    )
    port map(
        clk => s00_axi_aclk,
        reset => reset_s,
        
        -- Interface to the AXI controllers
        reg_data_i => reg_data_o,
        log2w_wr_i => log2w_wr_o,
        width_wr_i => width_wr_o,
        log2h_wr_i => log2h_wr_o,
        height_wr_i => height_wr_o,
        cmd_wr_i => cmd_wr_o,
        addr_wr_i => addr_wr_o,
        dataRE_wr_i => dataRE_wr_o,
        dataIM_wr_i => dataIM_wr_o,
        
        log2w_axi_o => log2w_axi_i,
        width_axi_o => width_axi_i,
        log2h_axi_o => log2h_axi_i,
        height_axi_o => height_axi_i,
        cmd_axi_o => cmd_axi_i,
        status_axi_o => status_axi_i,
        addr_axi_o => addr_axi_i,
        dataRE_axi_o => dataRE_axi_i,
        dataIM_axi_o => dataIM_axi_i,
        
--        mem_addr_i =>  mem_addr_i,--(mem_addr_o(log2c(FFT_SIZE*FFT_SIZE), mem_addr_o(log2c(FFT_SIZE*FFT_SIZE)- 1 downto 0)),
--        mem_data_i => mem_data_o,
--        mem_wr_i => mem_wr_o,
        
--        mem_re_axi_data_o => mem_re_axi_data_i,
--        mem_im_axi_data_o => mem_im_axi_data_i,
        
        -- Interface to the matrix multiply module
        log2w_o => log2w,
        width_o => width,
        log2h_o => log2h,
        height_o => height,
        start_o => start,
        ready_i => ready,
        
        mem_data_wr_addr_i => data_o_addr_o,
        mem_data_wr_i => data_wr_o,
        mem_data_wr_o => data_wr_i,
        mem_dataRE_i => dataRE_o,
        mem_dataIM_i => dataIM_o,
        
        mem_data_rd_addr_i => data_i_addr_o,
        mem_data_rd_i => data_rd_o,
        mem_data_rd_o => data_rd_i,
        mem_dataRE_o => dataRE_i,
        mem_dataIM_o => dataIM_i
    );
    
fft2_inst: entity work.fft2(Behavioral)
    generic map ( 
           DATA_WIDTH => DATA_WIDTH,
           FFT_SIZE => FFT_SIZE,
           FIXED_POINT_WIDTH => FIXED_POINT_WIDTH
    )
    port map ( 
           clk => s00_axi_aclk,
           rst => reset_s,
           
           data_i_addr_o => data_i_addr_o,
           dataRE_i => dataRE_i,
           dataIM_i => dataIM_i,
           data_rd_o => data_rd_o,
           data_rd_i => data_rd_i,

           data_o_addr_o => data_o_addr_o,
           dataRE_o => dataRE_o,
           dataIM_o => dataIM_o,
           data_wr_o => data_wr_o,
           data_wr_i => data_wr_i,
           
           log2w => log2w,
           width => width,
           
           log2h => log2h,
           height => height,
           
           start => start,
           ready => ready);
	-- User logic ends


end arch_imp;
