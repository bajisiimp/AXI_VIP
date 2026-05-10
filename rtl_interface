interface axi_intf(input bit clk);

//global signals
bit ACLK;
logic ARESETn;

//write address channel signals
logic [3:0] AWID;
logic [31:0] AWADDR;
logic [3:0] AWLEN;
logic [2:0] AWSIZE;
logic [1:0] AWBURST;
bit AWVALID;
bit AWREADY;

//write data channel signals
logic [3:0]WID;
logic [31:0] WDATA;
logic [3:0] WSTRB;
logic WLAST;
bit WVALID;
bit WREADY;

//write response channel signals

logic [3:0] BID;
logic [1:0] BRESP;
bit BVALID;
bit BREADY;

//read address channel signals
logic [3:0] ARID;
logic [31:0] ARADDR;
logic [3:0] ARLEN;
logic [2:0] ARSIZE;
logic [1:0] ARBURST;
bit ARVALID;
bit ARREADY;

//read data channel signals
logic [3:0] RID;
logic [31:0] RDATA;
logic [1:0] RRESP;
logic RLAST;
bit RVALID;
bit RREADY;

//clock assigning
assign ACLK=clk;

//=============master driver clocking block ===================
clocking master_drv_cb@(posedge clk);
		default input #1 output #1;
//write address channel sig
output AWID;
output AWADDR;
output AWLEN;
output AWSIZE;
output AWBURST;
output AWVALID;
input AWREADY;

//write data channel sig
output WID;
output WDATA;
output WSTRB;
output WLAST;
output WVALID;
input WREADY;

//write response channel sig
output BREADY;
input BVALID;
input BRESP;
input BID;

//read address channel sig
output ARID;
output ARADDR;
output ARLEN;
output ARSIZE;
output ARBURST;
output ARVALID;
input ARREADY;

//read data channel sig
input RID;
input RDATA;
input RRESP;
input RLAST;
input RVALID;
output RREADY;


endclocking:master_drv_cb

//=============master mon clocking block ===================
clocking master_mon_cb@(posedge clk);
		default input #1 output #1;
//write address channel sig
input AWID;
input AWADDR;
input AWLEN;
input AWSIZE;
input AWBURST;
input AWVALID;
input AWREADY;

//write data channel sig
input WID;
input WDATA;
input WSTRB;
input WLAST;
input WVALID;
input WREADY;

//write response channel sig
input BREADY;
input BVALID;
input BRESP;
input BID;

//read address channel sig
input ARID;
input ARADDR;
input ARLEN;
input ARSIZE;
input ARBURST;
input ARVALID;
input ARREADY;

//read data channel sig
input RID;
input RDATA;
input RRESP;
input RLAST;
input RVALID;
input RREADY;

endclocking:master_mon_cb

//=============slave driver clocking block ===================
clocking slave_drv_cb@(posedge clk);

//write address channel sig
input AWID;
input AWADDR;
input AWLEN;
input AWSIZE;
input AWBURST;
input AWVALID;
output AWREADY;

//write data channel sig
input WID;
input WDATA;
input WSTRB;
input WLAST;
input WVALID;
output WREADY;

//write response channel sig
input BREADY;
output BVALID;
output BRESP;
output BID;

//read address channel sig
input ARID;
input ARADDR;
input ARLEN;
input ARSIZE;
input ARBURST;
input ARVALID;
output ARREADY;

//read data channel sig
output RID;
output RDATA;
output RRESP;
output RLAST;
output RVALID;
input RREADY;


endclocking:slave_drv_cb

//=============slave mon clocking block ===================
clocking slave_mon_cb@(posedge clk);

//write address channel sig
input AWID;
input AWADDR;
input AWLEN;
input AWSIZE;
input AWBURST;
input AWVALID;
input AWREADY;

//write data channel sig
input WID;
input WDATA;
input WSTRB;
input WLAST;
input WVALID;
input WREADY;

//write response channel sig
input BREADY;
input BVALID;
input BRESP;
input BID;

//read address channel sig
input ARID;
input ARADDR;
input ARLEN;
input ARSIZE;
input ARBURST;
input ARVALID;
input ARREADY;

//read data channel sig
input RID;
input RDATA;
input RRESP;
input RLAST;
input RVALID;
input RREADY;

endclocking:slave_mon_cb

modport SLAVE_DRV_MP(clocking slave_drv_cb);
modport SLAVE_MON_MP(clocking slave_mon_cb);
modport MASTER_DRV_MP(clocking master_drv_cb);
modport MASTER_MON_MP(clocking master_mon_cb);

//---------------------------------------------------------------------------------------------------------------------------------------------
//
//=================================================-ASSERTIONS-===================================================================================
//
//---------------------------------------------------------------------------------------------------------------------------------------------


property awdata_stable;
       @(posedge ACLK)	(AWVALID && !AWREADY) |=>  $stable({AWADDR,AWID,AWBURST,AWLEN,AWSIZE});
endproperty

property wdata_stable;
       @(posedge ACLK)	(WVALID && !WREADY) |=>  $stable({WDATA,WSTRB,WID});
endproperty

property bdata_stable;
       @(posedge ACLK)	(BVALID && !BREADY) |=>  $stable({BID,BRESP});
endproperty

property ardata_stable;
       @(posedge ACLK)	(ARVALID && !ARREADY) |=>  $stable({ARADDR,ARID,ARBURST,ARLEN,ARSIZE});
endproperty

property rdata_stable;
       @(posedge ACLK)	(RVALID && !RREADY) |=>  $stable({RDATA,RRESP,RID});
endproperty

AW_STABLE : assert property (awdata_stable)
		 $display("AW_STABLE property asserted");
		else
		$error("AW_STABLE property not asserted");

W_STABLE : assert property (wdata_stable)
		 $display("W_STABLE property asserted");
		else
		$error("W_STABLE property not asserted");

B_STABLE : assert property (bdata_stable)
		 $display("B_STABLE property asserted");
		else
		$error("B_STABLE property not asserted");


AR_STABLE : assert property (ardata_stable)
		 $display("AR_STABLE property asserted");
		else
		$error("AR_STABLE property not asserted");

R_STABLE : assert property (rdata_stable)
		 $display("R_STABLE property asserted");
		else
		$error("R_STABLE property not asserted");

endinterface


