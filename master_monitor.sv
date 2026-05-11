class m_axi_mon extends uvm_monitor;

`uvm_component_utils(m_axi_mon);
virtual axi_intf.MASTER_MON_MP axi_if;

uvm_analysis_port #(m_axi_txn) monitor_port;

m_axi_agent_config m_cfg;

//seprate transaction
m_axi_txn w_xtn,r_xtn;

//queues
m_axi_txn w_q[$];
m_axi_txn w_b[$];
m_axi_txn r_q[$];

//semaphores
semaphore sem_aw;
semaphore sem_ar;
semaphore sem_aw_to_w;
semaphore sem_w_to_b;
semaphore sem_ar_to_r;
semaphore sem_w;
semaphore sem_r;
semaphore sem_wresp;

function new(string name="m_axi_mon", uvm_component parent);
super.new(name,parent);
monitor_port=new("monitor_port",this);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(m_axi_agent_config)::get(this,"","m_axi_agent_config",m_cfg))
`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 

	sem_aw		 	= new(1);
	sem_ar		 	= new(1);
	sem_aw_to_w 		= new();
	sem_ar_to_r 		= new();
 	sem_w_to_b 		= new(); 
	sem_w 			= new(1); 
	sem_wresp 		= new(1); 
	sem_r 			= new(1);
endfunction

function void connect_phase(uvm_phase phase);
  axi_if = m_cfg.axi_if;
endfunction

task run_phase(uvm_phase phase);

  forever begin
      fork
		begin
	      	sem_aw.get(1);  
		drive_aw();
	        sem_aw_to_w.put(1);
		sem_aw.put(1);
		end

		begin
 	        sem_aw_to_w.get(1); 
		sem_w.get(1);
		drive_w(w_q.pop_front());
		sem_w_to_b.put(1);
		sem_w.put(1);
		end

		begin
		sem_w_to_b.get(1);
		sem_wresp.get(1);
		wait_b(w_b.pop_front());
		sem_wresp.put(1);
		end

		begin
		sem_ar.get(1);
		drive_ar();
 		sem_ar_to_r.put(1);
		sem_ar.put(1);
		end

		begin
	        sem_ar_to_r.get(1);
		sem_r.get(1);
      		drive_r(r_q.pop_front());
		sem_r.put(1);
		end
      join_any
  end

endtask

task drive_aw();
	
	//forever begin

//	@(axi_if.master_mon_cb)

	`uvm_info(get_type_name()," write address channel started",UVM_LOW);

//	@(axi_if.master_mon_cb)
	wait(axi_if.master_mon_cb.AWVALID && axi_if.master_mon_cb.AWREADY);

	w_xtn=m_axi_txn::type_id::create("w_xtn");

 	w_xtn.AWID=axi_if.master_mon_cb.AWID;
	w_xtn.AWADDR=axi_if.master_mon_cb.AWADDR;
	w_xtn.AWLEN=axi_if.master_mon_cb.AWLEN;
	w_xtn.AWSIZE=axi_if.master_mon_cb.AWSIZE;
	w_xtn.AWBURST=axi_if.master_mon_cb.AWBURST;
	w_xtn.AWVALID=axi_if.master_mon_cb.AWVALID;
	w_xtn.AWREADY=axi_if.master_mon_cb.AWREADY;


//	repeat($urandom_range(1,5))
	@(axi_if.master_mon_cb);

        w_q.push_back(w_xtn);
	//monitor_port.write(w_xtn);

	//end
	`uvm_info(get_type_name()," write address channel ended",UVM_LOW);

endtask
	int mem[int];

task drive_w(m_axi_txn xtn);
	`uvm_info(get_type_name()," write data channel started",UVM_LOW);
	xtn.cal_addr;
	xtn.strb_cal;

	//forever begin

	//@(axi_if.master_mon_cb);
            
		
		xtn.WDATA = new[xtn.AWLEN +1];
		xtn.WSTRB = new[xtn.AWLEN +1];

		
 		for(int i=0;i<=xtn.AWLEN;i++)
		  begin
			@(axi_if.master_mon_cb);
	  		wait(axi_if.master_mon_cb.WVALID && axi_if.master_mon_cb.WREADY);

			xtn.WID=axi_if.master_mon_cb.WID;
			xtn.WSTRB[i]=axi_if.master_mon_cb.WSTRB;
			
			if(axi_if.master_mon_cb.WSTRB == 15)
			xtn.WDATA[i] = axi_if.master_mon_cb.WDATA;

			if(axi_if.master_mon_cb.WSTRB == 8)
			xtn.WDATA[i] = axi_if.master_mon_cb.WDATA[31:24];

			if(axi_if.master_mon_cb.WSTRB == 4)
			xtn.WDATA[i] = axi_if.master_mon_cb.WDATA[23:16];

			if(axi_if.master_mon_cb.WSTRB == 2)
			xtn.WDATA[i] = axi_if.master_mon_cb.WDATA[15:8];

			if(axi_if.master_mon_cb.WSTRB == 1)
			xtn.WDATA[i] = axi_if.master_mon_cb.WDATA[7:0];

			if(axi_if.master_mon_cb.WSTRB == 3)
			xtn.WDATA[i] = axi_if.master_mon_cb.WDATA[15:0];

			if(axi_if.master_mon_cb.WSTRB == 12)
			xtn.WDATA[i] = axi_if.master_mon_cb.WDATA[31:16];

			xtn.WVALID=axi_if.master_mon_cb.WVALID;
			xtn.WREADY=axi_if.master_mon_cb.WREADY;

			
			//xtn.WDATA[i] = axi_if.master_mon_cb.WDATA;
			//$display(" data fetched from the interface (what master is sending)  WDATA = %0p --- i == %0d  \n ",xtn.addr,i);

		   	if( i == xtn.AWLEN)
			xtn.WLAST=axi_if.master_mon_cb.WLAST;
			//@(axi_if.master_mon_cb);

		  end

		w_b.push_back(xtn);
		//monitor_port.write(xtn);
	
	// end
	//@(axi_if.master_mon_cb);
	`uvm_info(get_type_name()," write data channel ended",UVM_LOW);
endtask

task wait_b(m_axi_txn xtn);
	`uvm_info(get_type_name()," write response channel started",UVM_LOW);
     //forever begin

	//@(axi_if.master_mon_cb);

	wait(axi_if.master_mon_cb.BVALID && axi_if.master_mon_cb.BREADY);

        xtn.BID=axi_if.master_mon_cb.BID;
	xtn.BRESP=axi_if.master_mon_cb.BRESP;    
	xtn.BVALID=axi_if.master_mon_cb.BVALID;   
	xtn.BREADY=axi_if.master_mon_cb.BREADY; 
	@(axi_if.master_mon_cb);

	monitor_port.write(xtn);

	`uvm_info(get_type_name(),$sformatf("printing from master monitor write response method \n %s",xtn.sprint()),UVM_LOW);

	//repeat($urandom_range(1,5))
//	@(axi_if.master_mon_cb);

     //end  
	// @(axi_if.master_mon_cb);   
	`uvm_info(get_type_name()," write reponse channel ended",UVM_LOW);

endtask

task drive_ar();
	`uvm_info(get_type_name()," read address channel started",UVM_LOW);

	//forever begin
//	@(axi_if.master_mon_cb)

	wait(axi_if.master_mon_cb.ARVALID && axi_if.master_mon_cb.ARREADY);

	r_xtn=m_axi_txn::type_id::create("r_xtn");

 	r_xtn.ARID = axi_if.master_mon_cb.ARID;
	r_xtn.ARADDR = axi_if.master_mon_cb.ARADDR;
	r_xtn.ARLEN = axi_if.master_mon_cb.ARLEN;
	r_xtn.ARSIZE = axi_if.master_mon_cb.ARSIZE;
	r_xtn.ARBURST = axi_if.master_mon_cb.ARBURST;
	r_xtn.ARVALID = axi_if.master_mon_cb.ARVALID;
	r_xtn.ARREADY = axi_if.master_mon_cb.ARREADY;
	
	r_q.push_back(r_xtn);
	//monitor_port.write(r_xtn);

	//repeat($urandom_range(1,5))
	@(axi_if.master_mon_cb);

    // end
	//@(axi_if.master_mon_cb);
 	`uvm_info(get_type_name()," read address channel ended",UVM_LOW);

endtask
       int mem1[int];

task drive_r(m_axi_txn xtn);

	`uvm_info(get_type_name()," read data channel started",UVM_LOW);
	xtn.cal_raddr();
	xtn.rstrb_cal();

	//forever begin

//	@(axi_if.master_mon_cb);

         xtn.RDATA = new[xtn.ARLEN+1];
      	 xtn.RRESP = new[xtn.ARLEN +1];

	 xtn.RID = axi_if.master_mon_cb.RID;


         for(int i=0;i<=xtn.ARLEN;i++)
                 begin
		     @(axi_if.master_mon_cb);
		      wait(axi_if.master_mon_cb.RREADY && axi_if.master_mon_cb.RVALID);
		//$display(" RSTRB ==kkkkkkkkkkkkkkkkkkk");
		      //if(xtn.RSTRB[i] == 15)
                      xtn.RDATA[i] = axi_if.master_mon_cb.RDATA;
		      xtn.RRESP[i] = axi_if.master_mon_cb.RRESP;
		 
		      /*if(xtn.RSTRB[i] == 8)
                      xtn.RDATA[i] = axi_if.master_mon_cb.RDATA[31:24];

		      if(xtn.RSTRB[i] == 4)
                      xtn.RDATA[i] = axi_if.master_mon_cb.RDATA[23:16];

		      if(xtn.RSTRB[i] == 2)
                      xtn.RDATA[i] = axi_if.master_mon_cb.RDATA[15:8];

		      if(xtn.RSTRB[i] == 1)
                      xtn.RDATA[i] = axi_if.master_mon_cb.RDATA[7:0];

		      if(xtn.RSTRB[i] == 3)
                      xtn.RDATA[i] = axi_if.master_mon_cb.RDATA[15:0];
 
		      if(xtn.RSTRB[i] == 12)
                      xtn.RDATA[i] = axi_if.master_mon_cb.RDATA[31:16];*/

		      xtn.RREADY = axi_if.master_mon_cb.RREADY;
	   	      xtn.RVALID = axi_if.master_mon_cb.RVALID;

		     //repeat($urandom_range(1,5))
		     //@(axi_if.master_mon_cb);
		     if(i == xtn.ARLEN)
		     xtn.RLAST = axi_if.master_mon_cb.RLAST;
	   	     //@(axi_if.master_mon_cb);

			
		end
	
	monitor_port.write(xtn);

	`uvm_info(get_type_name(),$sformatf("printing from master monitor read data method \n %s",xtn.sprint()),UVM_LOW);

	//end
	`uvm_info(get_type_name(),"read data channel ended",UVM_LOW);
	  
endtask


function void report_phase(uvm_phase phase);
//`uvm_info(get_type_name(),$sformatf("Report: APB driver sent %0d transactions",apb_cfg.apb_drv_dut_cnt),UVM_LOW)
endfunction

endclass


