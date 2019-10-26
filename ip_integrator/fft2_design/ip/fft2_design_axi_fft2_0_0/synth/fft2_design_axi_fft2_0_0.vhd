-- (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: FTN:user:axi_fft2:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fft2_design_axi_fft2_0_0 IS
  PORT (
    s00_axi_awaddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    s00_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s00_axi_awvalid : IN STD_LOGIC;
    s00_axi_awready : OUT STD_LOGIC;
    s00_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s00_axi_wvalid : IN STD_LOGIC;
    s00_axi_wready : OUT STD_LOGIC;
    s00_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s00_axi_bvalid : OUT STD_LOGIC;
    s00_axi_bready : IN STD_LOGIC;
    s00_axi_araddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    s00_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s00_axi_arvalid : IN STD_LOGIC;
    s00_axi_arready : OUT STD_LOGIC;
    s00_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s00_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s00_axi_rvalid : OUT STD_LOGIC;
    s00_axi_rready : IN STD_LOGIC;
    s00_axi_aclk : IN STD_LOGIC;
    s00_axi_aresetn : IN STD_LOGIC;
    s01_axi_awid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s01_axi_awaddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s01_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s01_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s01_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s01_axi_awlock : IN STD_LOGIC;
    s01_axi_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s01_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s01_axi_awregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s01_axi_awqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s01_axi_awvalid : IN STD_LOGIC;
    s01_axi_awready : OUT STD_LOGIC;
    s01_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s01_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s01_axi_wlast : IN STD_LOGIC;
    s01_axi_wvalid : IN STD_LOGIC;
    s01_axi_wready : OUT STD_LOGIC;
    s01_axi_bid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    s01_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s01_axi_bvalid : OUT STD_LOGIC;
    s01_axi_bready : IN STD_LOGIC;
    s01_axi_arid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s01_axi_araddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s01_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s01_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s01_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    s01_axi_arlock : IN STD_LOGIC;
    s01_axi_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s01_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    s01_axi_arregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s01_axi_arqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s01_axi_arvalid : IN STD_LOGIC;
    s01_axi_arready : OUT STD_LOGIC;
    s01_axi_rid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
    s01_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s01_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s01_axi_rlast : OUT STD_LOGIC;
    s01_axi_rvalid : OUT STD_LOGIC;
    s01_axi_rready : IN STD_LOGIC;
    s01_axi_aclk : IN STD_LOGIC;
    s01_axi_aresetn : IN STD_LOGIC
  );
END fft2_design_axi_fft2_0_0;

ARCHITECTURE fft2_design_axi_fft2_0_0_arch OF fft2_design_axi_fft2_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF fft2_design_axi_fft2_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT axi_fft2_v1_0 IS
    GENERIC (
      C_S00_AXI_DATA_WIDTH : INTEGER; -- Width of S_AXI data bus
      C_S00_AXI_ADDR_WIDTH : INTEGER; -- Width of S_AXI address bus
      C_S01_AXI_ID_WIDTH : INTEGER; -- Width of ID for for write address, write data, read address and read data
      C_S01_AXI_DATA_WIDTH : INTEGER; -- Width of S_AXI data bus
      C_S01_AXI_ADDR_WIDTH : INTEGER; -- Width of S_AXI address bus
      C_S01_AXI_AWUSER_WIDTH : INTEGER; -- Width of optional user defined signal in write address channel
      C_S01_AXI_ARUSER_WIDTH : INTEGER; -- Width of optional user defined signal in read address channel
      C_S01_AXI_WUSER_WIDTH : INTEGER; -- Width of optional user defined signal in write data channel
      C_S01_AXI_RUSER_WIDTH : INTEGER; -- Width of optional user defined signal in read data channel
      C_S01_AXI_BUSER_WIDTH : INTEGER; -- Width of optional user defined signal in write response channel
      DATA_WIDTH : INTEGER;
      FFT_SIZE : INTEGER;
      FIXED_POINT_WIDTH : INTEGER
    );
    PORT (
      s00_axi_awaddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      s00_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s00_axi_awvalid : IN STD_LOGIC;
      s00_axi_awready : OUT STD_LOGIC;
      s00_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s00_axi_wvalid : IN STD_LOGIC;
      s00_axi_wready : OUT STD_LOGIC;
      s00_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s00_axi_bvalid : OUT STD_LOGIC;
      s00_axi_bready : IN STD_LOGIC;
      s00_axi_araddr : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      s00_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s00_axi_arvalid : IN STD_LOGIC;
      s00_axi_arready : OUT STD_LOGIC;
      s00_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s00_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s00_axi_rvalid : OUT STD_LOGIC;
      s00_axi_rready : IN STD_LOGIC;
      s00_axi_aclk : IN STD_LOGIC;
      s00_axi_aresetn : IN STD_LOGIC;
      s01_axi_awid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s01_axi_awaddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s01_axi_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s01_axi_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s01_axi_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s01_axi_awlock : IN STD_LOGIC;
      s01_axi_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s01_axi_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s01_axi_awregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s01_axi_awqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s01_axi_awuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      s01_axi_awvalid : IN STD_LOGIC;
      s01_axi_awready : OUT STD_LOGIC;
      s01_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s01_axi_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s01_axi_wlast : IN STD_LOGIC;
      s01_axi_wuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      s01_axi_wvalid : IN STD_LOGIC;
      s01_axi_wready : OUT STD_LOGIC;
      s01_axi_bid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      s01_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s01_axi_buser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s01_axi_bvalid : OUT STD_LOGIC;
      s01_axi_bready : IN STD_LOGIC;
      s01_axi_arid : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s01_axi_araddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
      s01_axi_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      s01_axi_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s01_axi_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      s01_axi_arlock : IN STD_LOGIC;
      s01_axi_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s01_axi_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
      s01_axi_arregion : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s01_axi_arqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s01_axi_aruser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      s01_axi_arvalid : IN STD_LOGIC;
      s01_axi_arready : OUT STD_LOGIC;
      s01_axi_rid : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
      s01_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s01_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s01_axi_rlast : OUT STD_LOGIC;
      s01_axi_ruser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      s01_axi_rvalid : OUT STD_LOGIC;
      s01_axi_rready : IN STD_LOGIC;
      s01_axi_aclk : IN STD_LOGIC;
      s01_axi_aresetn : IN STD_LOGIC
    );
  END COMPONENT axi_fft2_v1_0;
  ATTRIBUTE X_CORE_INFO : STRING;
  ATTRIBUTE X_CORE_INFO OF fft2_design_axi_fft2_0_0_arch: ARCHITECTURE IS "axi_fft2_v1_0,Vivado 2018.3";
  ATTRIBUTE CHECK_LICENSE_TYPE : STRING;
  ATTRIBUTE CHECK_LICENSE_TYPE OF fft2_design_axi_fft2_0_0_arch : ARCHITECTURE IS "fft2_design_axi_fft2_0_0,axi_fft2_v1_0,{}";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF s01_axi_aresetn: SIGNAL IS "XIL_INTERFACENAME S01_AXI_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 S01_AXI_RST RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s01_axi_aclk: SIGNAL IS "XIL_INTERFACENAME S01_AXI_CLK, ASSOCIATED_BUSIF S01_AXI, ASSOCIATED_RESET s01_axi_aresetn, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN fft2_design_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 S01_AXI_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_rlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_rid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI RID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arqos: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARQOS";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arregion: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARREGION";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arlock: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_arid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI ARID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_bid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI BID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_wlast: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI WLAST";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awqos: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWQOS";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awregion: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWREGION";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awcache: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awlock: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awburst: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWBURST";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awsize: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awlen: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWLEN";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s01_axi_awid: SIGNAL IS "XIL_INTERFACENAME S01_AXI, WIZ_DATA_WIDTH 32, WIZ_MEMORY_SIZE 1024, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 50000000, ID_WIDTH 12, ADDR_WIDTH 12, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 16, PHASE 0.000, CLK_DOMAIN fft2_design_proces" & 
"sing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s01_axi_awid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S01_AXI AWID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s00_axi_aresetn: SIGNAL IS "XIL_INTERFACENAME S00_AXI_RST, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_aresetn: SIGNAL IS "xilinx.com:signal:reset:1.0 S00_AXI_RST RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s00_axi_aclk: SIGNAL IS "XIL_INTERFACENAME S00_AXI_CLK, ASSOCIATED_BUSIF S00_AXI, ASSOCIATED_RESET s00_axi_aresetn, FREQ_HZ 50000000, PHASE 0.000, CLK_DOMAIN fft2_design_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_aclk: SIGNAL IS "xilinx.com:signal:clock:1.0 S00_AXI_CLK CLK";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_rdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_arprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_araddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_bresp: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wstrb: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_wdata: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awready: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awvalid: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awprot: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI AWPROT";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s00_axi_awaddr: SIGNAL IS "XIL_INTERFACENAME S00_AXI, WIZ_DATA_WIDTH 32, WIZ_NUM_REG 10, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 50000000, ID_WIDTH 0, ADDR_WIDTH 6, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN fft2_design_processing_" & 
"system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF s00_axi_awaddr: SIGNAL IS "xilinx.com:interface:aximm:1.0 S00_AXI AWADDR";
BEGIN
  U0 : axi_fft2_v1_0
    GENERIC MAP (
      C_S00_AXI_DATA_WIDTH => 32,
      C_S00_AXI_ADDR_WIDTH => 6,
      C_S01_AXI_ID_WIDTH => 12,
      C_S01_AXI_DATA_WIDTH => 32,
      C_S01_AXI_ADDR_WIDTH => 12,
      C_S01_AXI_AWUSER_WIDTH => 0,
      C_S01_AXI_ARUSER_WIDTH => 0,
      C_S01_AXI_WUSER_WIDTH => 0,
      C_S01_AXI_RUSER_WIDTH => 0,
      C_S01_AXI_BUSER_WIDTH => 0,
      DATA_WIDTH => 4,
      FFT_SIZE => 8,
      FIXED_POINT_WIDTH => 16
    )
    PORT MAP (
      s00_axi_awaddr => s00_axi_awaddr,
      s00_axi_awprot => s00_axi_awprot,
      s00_axi_awvalid => s00_axi_awvalid,
      s00_axi_awready => s00_axi_awready,
      s00_axi_wdata => s00_axi_wdata,
      s00_axi_wstrb => s00_axi_wstrb,
      s00_axi_wvalid => s00_axi_wvalid,
      s00_axi_wready => s00_axi_wready,
      s00_axi_bresp => s00_axi_bresp,
      s00_axi_bvalid => s00_axi_bvalid,
      s00_axi_bready => s00_axi_bready,
      s00_axi_araddr => s00_axi_araddr,
      s00_axi_arprot => s00_axi_arprot,
      s00_axi_arvalid => s00_axi_arvalid,
      s00_axi_arready => s00_axi_arready,
      s00_axi_rdata => s00_axi_rdata,
      s00_axi_rresp => s00_axi_rresp,
      s00_axi_rvalid => s00_axi_rvalid,
      s00_axi_rready => s00_axi_rready,
      s00_axi_aclk => s00_axi_aclk,
      s00_axi_aresetn => s00_axi_aresetn,
      s01_axi_awid => s01_axi_awid,
      s01_axi_awaddr => s01_axi_awaddr,
      s01_axi_awlen => s01_axi_awlen,
      s01_axi_awsize => s01_axi_awsize,
      s01_axi_awburst => s01_axi_awburst,
      s01_axi_awlock => s01_axi_awlock,
      s01_axi_awcache => s01_axi_awcache,
      s01_axi_awprot => s01_axi_awprot,
      s01_axi_awregion => s01_axi_awregion,
      s01_axi_awqos => s01_axi_awqos,
      s01_axi_awuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      s01_axi_awvalid => s01_axi_awvalid,
      s01_axi_awready => s01_axi_awready,
      s01_axi_wdata => s01_axi_wdata,
      s01_axi_wstrb => s01_axi_wstrb,
      s01_axi_wlast => s01_axi_wlast,
      s01_axi_wuser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      s01_axi_wvalid => s01_axi_wvalid,
      s01_axi_wready => s01_axi_wready,
      s01_axi_bid => s01_axi_bid,
      s01_axi_bresp => s01_axi_bresp,
      s01_axi_bvalid => s01_axi_bvalid,
      s01_axi_bready => s01_axi_bready,
      s01_axi_arid => s01_axi_arid,
      s01_axi_araddr => s01_axi_araddr,
      s01_axi_arlen => s01_axi_arlen,
      s01_axi_arsize => s01_axi_arsize,
      s01_axi_arburst => s01_axi_arburst,
      s01_axi_arlock => s01_axi_arlock,
      s01_axi_arcache => s01_axi_arcache,
      s01_axi_arprot => s01_axi_arprot,
      s01_axi_arregion => s01_axi_arregion,
      s01_axi_arqos => s01_axi_arqos,
      s01_axi_aruser => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      s01_axi_arvalid => s01_axi_arvalid,
      s01_axi_arready => s01_axi_arready,
      s01_axi_rid => s01_axi_rid,
      s01_axi_rdata => s01_axi_rdata,
      s01_axi_rresp => s01_axi_rresp,
      s01_axi_rlast => s01_axi_rlast,
      s01_axi_rvalid => s01_axi_rvalid,
      s01_axi_rready => s01_axi_rready,
      s01_axi_aclk => s01_axi_aclk,
      s01_axi_aresetn => s01_axi_aresetn
    );
END fft2_design_axi_fft2_0_0_arch;
