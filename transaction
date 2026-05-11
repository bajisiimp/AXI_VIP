class m_axi_txn extends uvm_sequence_item;

`uvm_object_utils(m_axi_txn)

//global signals
bit ACLK;
bit ARESETn;

//write address channel signals
rand bit [3:0] AWID;
rand bit [31:0] AWADDR;
rand bit [3:0] AWLEN;
rand bit [2:0] AWSIZE;
rand bit [1:0] AWBURST;
bit AWVALID;
bit AWREADY;

//write data channel signals
rand bit [3:0]WID;
rand bit [31:0] WDATA[];
rand bit [3:0] WSTRB[];
rand bit WLAST;
bit WVALID;
bit WREADY;

//write response channel signals

rand bit [3:0] BID;
bit [1:0] BRESP;
bit BVALID;
bit BREADY;

//read address channel signals
rand bit [3:0] ARID;
rand bit [31:0] ARADDR;
rand bit [3:0] ARLEN;
rand bit [2:0] ARSIZE;
rand bit [1:0] ARBURST;
bit ARVALID;
bit ARREADY;

//read data channel signals
rand bit [3:0] RID;
rand bit [31:0] RDATA[];
bit [1:0] RRESP [];
bit RLAST;
bit RVALID;
bit RREADY;

bit [31:0]addr[];
int no_bytes;
int aligned_addr;
int start_addr;

//===========read=============//
bit [3:0]RSTRB[];
bit [31:0] raddr[];
int no_rbytes;
int aligned_raddr;
int start_raddr;
//==========================


rand bit[1:0]write_slave;
rand bit[1:0]read_slave;

///******************************************************    CONSTRAINTS   ********************************************************************//
//===============================================================================================================================================
//***********************************************************************************************************************************************//

constraint wdata_c    		{WDATA.size()==(AWLEN+1);}
constraint arata_c    		{RDATA.size()==(ARLEN+1);}

constraint awb    		{AWBURST dist{0:=10,1:=10,2:=10};}
constraint arb    		{ARBURST dist{0:=10,1:=10,2:=10};}

constraint write_id_c    	{AWID==WID;BID==AWID;}
constraint read_id_c    	{RID==ARID;}

constraint aws_c    		{AWSIZE dist{0:=10,1:=10,2:=10};}
constraint ars_c    		{ARSIZE dist{0:=10,1:=10,2:=10};}

constraint awl_c    		{if(AWBURST ==2 || AWBURST == 0)  (AWLEN+1) inside {2,4,8,16};}
constraint arl_c    		{if(ARBURST ==2 || ARBURST == 0)  (ARLEN+1) inside {2,4,8,16};}

constraint write_alignment_c1 	{(AWBURST == 2'b10 && AWSIZE == 1) -> AWADDR%2 == 0;} //alignment for wrap
constraint write_alignment_c2 	{(AWBURST == 2'b10 && AWSIZE == 2) -> AWADDR%4 == 0;}

constraint read_alignment_c1 	{(ARBURST == 2'b10 && ARSIZE == 1) -> ARADDR%2 == 0;} //alignment for wrap
constraint read_alignment_c2 	{(ARBURST == 2'b10 && ARSIZE == 2) -> ARADDR%4 == 0;}

constraint max_boundary_c    	{(2**AWSIZE)*(AWLEN+1)<4096;}
constraint max_boundary_cr    	{(2**ARSIZE)*(ARLEN+1)<4096;}

constraint awlent_c          	{AWLEN inside {[1:15]};}
constraint arlent_c          	{ARLEN inside {[1:15]};}

function new(string name="m_axi_txn");
super.new(name);
endfunction

//-----------------  do_print method  -------------------//
//Use printer.print_field for integral variables
//Use printer.print_generic for enum variables
   function void do_print (uvm_printer printer);
    super.do_print(printer);

    //                   srting name   		bitstream value     size       radix for printing
    printer.print_field( "AWID", 		this.AWID, 	    4,		 UVM_DEC		);
    printer.print_field( "AWADDR", 		this.AWADDR, 	    32,		 UVM_DEC		);
    printer.print_field( "AWSIZE", 		this.AWSIZE, 	    3,		 UVM_DEC		);
    printer.print_field( "AWLEN", 		this.AWLEN,         4,		 UVM_DEC		);
    printer.print_field( "AWBURST", 		this.AWBURST,       2,		 UVM_DEC		); 
    printer.print_field( "AWVALID", 		this.AWVALID,       1,		 UVM_DEC		);
    printer.print_field( "AWREADY", 		this.AWREADY,       1,		 UVM_DEC		);
///////================================write data================================//////
    printer.print_field( "WID", 		this.WID,           4,		 UVM_DEC		);

    foreach(WDATA[i])
    printer.print_field( $sformatf("WDATA[%0d]",i), 		this.WDATA[i],        32,		 UVM_DEC		);
    foreach(WSTRB[i])
    printer.print_field( $sformatf("WSTRB[%0d]",i), 		this.WSTRB[i],         4,		 UVM_BIN		);
    printer.print_field( "WLAST", 		this.WLAST,         1,		 UVM_DEC		);
    printer.print_field( "WVALID", 		this.WVALID,        1,		 UVM_DEC		);
    printer.print_field( "WREADY", 		this.WREADY,        1,		 UVM_DEC		);
///================================= write response ================================/////
    printer.print_field( "BID", 		this.BID,     	4,		 UVM_DEC		);
    printer.print_field( "BRESP", 		this.BRESP,     2,		 UVM_DEC		);
    printer.print_field( "BVALID", 		this.BVALID,     1,		 UVM_DEC		);
    printer.print_field( "BREADY", 		this.BREADY,     1,		 UVM_DEC		);
///================================ read addres =====================================//
    printer.print_field( "ARID", 		this.ARID, 	    4,		 UVM_DEC		);
    printer.print_field( "ARADDR", 		this.ARADDR, 	    32,		 UVM_DEC		);
    printer.print_field( "ARSIZE", 		this.ARSIZE, 	    3,		 UVM_DEC		);
    printer.print_field( "ARLEN", 		this.ARLEN,         4,		 UVM_DEC		);
    printer.print_field( "ARBURST", 		this.ARBURST,     2,		 UVM_DEC		);
    printer.print_field( "ARVALID", 		this.ARVALID,     1,		 UVM_DEC		);
    printer.print_field( "ARREADY", 		this.ARREADY,     1,		 UVM_DEC		);
/////===========================  read data ======================================///////
    printer.print_field( "RID", 		this.RID,     4,		 UVM_DEC		);

    foreach(RDATA[i])
    printer.print_field( $sformatf("RDATA[%0d]",i), 		this.RDATA[i],     32,		 UVM_DEC		);

    foreach(RRESP[i])
    printer.print_field( $sformatf("RRESP[%0d]",i), 		this.RRESP[i],     2,		 UVM_DEC		);

    printer.print_field( "RLAST", 		this.RLAST,     1,		 UVM_DEC		);   
    printer.print_field( "RVALID", 		this.RVALID,     1,		 UVM_DEC		);
    printer.print_field( "RREADY", 		this.RREADY,     1,		 UVM_DEC		);
   
  endfunction:do_print

function void post_randomize();

	no_bytes=2**AWSIZE;
	aligned_addr=(int'(AWADDR/no_bytes))*no_bytes;
	start_addr=AWADDR;
	WSTRB=new[AWLEN+1];
	RRESP=new[ARLEN+1];
	//=================for read ===================
	no_rbytes=2**ARSIZE;
	aligned_raddr=(int'(ARADDR/no_rbytes))*no_rbytes;
	start_raddr=ARADDR;
	RSTRB=new[ARLEN+1];
	//=======================//

	cal_addr();
	strb_cal();
	cal_raddr();
	rstrb_cal();

	$display("////////////////////////write_addr///////////////\n wr_addr=%0p",addr);
	$display("////////////////////////write_addr_AWADDR//////////////\n AWADDR=%0p",AWADDR);

	$display("///////////////////////read_addr///////////////\n rd_addr=%0p",raddr);
	$display("////////////////////////read_addr_ARADDR///////////////\n ARADDR=%0p",ARADDR);

    	endfunction

	function void cal_addr();

	bit wb;
	int burst_len=AWLEN+1;
	int N=burst_len;
	int wrap_boundary=(int'(AWADDR/(no_bytes*burst_len)))*(no_bytes*burst_len);
	//last address
	int addr_n=wrap_boundary+(no_bytes*burst_len);
	addr=new[AWLEN+1];
	addr[0]=AWADDR;

	//************************//
	for(int i=2;i<(burst_len+1);i++)
	    begin
		if(AWBURST==0)
			addr[i-1]=AWADDR;
		if(AWBURST==1)
			begin
 			   addr[i-1]=aligned_addr+(i-1)*no_bytes;
			end
		if(AWBURST==2)
			begin
			   if(wb==0)
			       begin
				addr[i-1]=aligned_addr+(i-1)*no_bytes;
				if(addr[i-1]==(wrap_boundary+(no_bytes*burst_len)))
				begin
				    addr[i-1]=wrap_boundary;
				    wb++;
				end
			     end
			   else
			       addr[i-1]=start_addr+((i-1)*no_bytes)-(no_bytes*burst_len);
			end
		end


	$display("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
	$display("burst len = %0d", burst_len);
	$display("ADDRES N = %0d", addr_n);
	$display(" wrap boaundary = %0d",wrap_boundary);
	foreach(addr[i])

	$display(" addr[%0d] = %0d  \n",i ,addr[i]);

	$display("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");

	endfunction

	function void strb_cal();

	int data_bus_bytes=4;
	int lower_byte_lane,upper_byte_lane;

	int lower_byte_lane_0=start_addr-(int'(start_addr/data_bus_bytes))*data_bus_bytes;
	int upper_byte_lane_0=aligned_addr+(no_bytes-1)-(int'(start_addr/data_bus_bytes))*data_bus_bytes;

	for(int i=0; i<(AWLEN+1);i++)
		for(int j=0;j<4;j++)
			WSTRB[i][j]=0;
	
	for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
	  begin
		WSTRB[0][j]=1;
	   end

	for(int i=1;i<(AWLEN+1);i++)
	  begin
		    lower_byte_lane=addr[i]-(int'(addr[i]/data_bus_bytes))*data_bus_bytes;
		      upper_byte_lane=lower_byte_lane+no_bytes-1;
			for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
			     WSTRB[i][j]=1;
	end
	endfunction

	function void cal_raddr();

	bit wb;
	int burst_len=ARLEN+1;
	int N=burst_len;
	int wrap_boundary=(int'(ARADDR/(no_rbytes*burst_len)))*(no_rbytes*burst_len);
	int raddr_n=wrap_boundary+(no_rbytes*burst_len);
	raddr=new[ARLEN+1];
	raddr[0]=ARADDR;

	//************************//
	for(int i=2;i<(burst_len+1);i++)
	    begin
		if(ARBURST==0)
			raddr[i-1]=ARADDR;
		if(ARBURST==1)
			begin
 			   raddr[i-1]=aligned_raddr+(i-1)*no_rbytes;
			end
		if(ARBURST==2)
			begin
			   if(wb==0)
			       begin
				raddr[i-1]=aligned_raddr+(i-1)*no_rbytes;
				if(raddr[i-1]==(wrap_boundary+(no_rbytes*burst_len)))
				begin
				    raddr[i-1]=wrap_boundary;
				    wb++;
				end
			     end
			   else
			       raddr[i-1]=start_raddr+((i-1)*no_rbytes)-(no_rbytes*burst_len);
			end
		end
	endfunction

	function void rstrb_cal();

	int data_bus_bytes=4;
	int lower_byte_lane,upper_byte_lane;

	int lower_byte_lane_0=start_raddr-((int'(start_raddr/data_bus_bytes))*data_bus_bytes);
	int upper_byte_lane_0=(aligned_raddr+(no_bytes-1))-((int'(start_raddr/data_bus_bytes))*data_bus_bytes);
	
	for(int j=lower_byte_lane_0;j<=upper_byte_lane_0;j++)
	  begin
		RSTRB[0][j]=1;
	   end

	for(int i=1;i<(ARLEN+1);i++)
	  begin
		    lower_byte_lane=raddr[i]-(int'(raddr[i]/data_bus_bytes))*data_bus_bytes;
		      upper_byte_lane=lower_byte_lane+no_bytes-1;
			for(int j=lower_byte_lane;j<=upper_byte_lane;j++)
			     RSTRB[i][j]=1;
	end
	endfunction



//-----------------  do_compare method -------------------//
//Add code for do_compare() to compare 
  function bit  do_compare (uvm_object rhs,uvm_comparer comparer);

 // handle for overriding the variable
    m_axi_txn rhs_;

    if(!$cast(rhs_,rhs)) begin
    `uvm_fatal("do_compare","cast of the rhs object failed")
    return 0;
    end

  // Compare the data members:
  // <var_name> == rhs_.<var_name>;

    return super.do_compare(rhs,comparer) &&
    AWID== rhs_.AWID &&
    AWADDR== rhs_.AWADDR &&
    AWSIZE== rhs_.AWSIZE &&
    AWLEN== rhs_.AWLEN &&
    AWBURST== rhs_.AWBURST &&
    AWVALID== rhs_.AWVALID &&
    AWREADY==rhs_.AWREADY  &&

    WID==rhs_.WID  &&
    WDATA==rhs_.WDATA  &&
    WSTRB==rhs_.WSTRB  &&
    WLAST==rhs_.WLAST  &&
    WVALID==rhs_.WVALID  &&
    WREADY==rhs_.WREADY  &&

    BID==rhs_.BID  &&
    BRESP==rhs_.BRESP  &&
    BVALID==rhs_.BVALID  &&
    BREADY==rhs_.BREADY  &&

    ARID== rhs_.ARID &&
    ARADDR== rhs_.ARADDR &&
    ARSIZE== rhs_.ARSIZE &&
    ARLEN== rhs_.ARLEN &&
    ARBURST== rhs_.ARBURST &&
    ARVALID== rhs_.ARVALID &&
    ARREADY==rhs_.ARREADY  &&

    RID==rhs_.RID  &&
    RDATA==rhs_.RDATA  &&
    RRESP==rhs_.RRESP  &&
    RLAST==rhs_.RLAST  &&
    RVALID==rhs_.RVALID  &&
    RREADY==rhs_.RREADY 

   ;

 endfunction:do_compare 


endclass
