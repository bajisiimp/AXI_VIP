class s_axi_drv extends uvm_driver #(m_axi_txn);

`uvm_component_utils(s_axi_drv)

virtual axi_intf.SLAVE_DRV_MP axi_if;

s_axi_agent_config m_cfg;

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

function new(string name="s_axi_drv", uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
if(!uvm_config_db#(s_axi_agent_config)::get(this,"","s_axi_agent_config",m_cfg))
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
	

//	@(axi_if.slave_drv_cb)

	w_xtn=m_axi_txn::type_id::create("w_xtn");

	`uvm_info(get_type_name()," write address channel started",UVM_LOW);

	axi_if.slave_drv_cb.AWREADY<=1;
	@(axi_if.slave_drv_cb)
	wait(axi_if.slave_drv_cb.AWVALID);

 	w_xtn.AWID=axi_if.slave_drv_cb.AWID;
	w_xtn.AWADDR=axi_if.slave_drv_cb.AWADDR;
	w_xtn.AWLEN=axi_if.slave_drv_cb.AWLEN;
	w_xtn.AWSIZE=axi_if.slave_drv_cb.AWSIZE;
	w_xtn.AWBURST=axi_if.slave_drv_cb.AWBURST;

	axi_if.slave_drv_cb.AWREADY <= 0;

	repeat($urandom_range(1,5))
	@(axi_if.slave_drv_cb);

        w_q.push_back(w_xtn);

     //`uvm_info("AXI_SLAVE_DRIVER",$sformatf("printing from slave driver write address method \n %s", w_xtn.sprint()),UVM_LOW) 
	`uvm_info(get_type_name()," write address channel ended",UVM_LOW);

endtask
	
task drive_w(m_axi_txn xtn);
int mem[int];

	`uvm_info(get_type_name()," write data channel started",UVM_LOW);
	//xtn.cal_addr;
	//xtn.strb_cal;

	//@(axi_if.slave_drv_cb);
            
		
		xtn.WDATA = new[xtn.AWLEN +1];
		xtn.WSTRB = new[xtn.AWLEN +1];

		
 		for(int i=0;i<=xtn.AWLEN;i++)
		  begin
		//	@(axi_if.slave_drv_cb);
			axi_if.slave_drv_cb.WREADY <= 1;
			@(axi_if.slave_drv_cb);
	  		wait(axi_if.slave_drv_cb.WVALID)

			//xtn.WDATA[i] = axi_if.slave_drv_cb.WDATA;
	  		//xtn.WSTRB[i] = axi_if.slave_drv_cb.WSTRB;

	  		//if(axi_if.slave_drv_cb.WLAST)
			//break;
			$display(" data fetched from the interface (what master is sending)  WDATA = %p --- i == %0d ",xtn.WDATA,i);

			axi_if.slave_drv_cb.WREADY <= 0;
			repeat($urandom_range(1,5))
			@(axi_if.slave_drv_cb);
		   end

		w_b.push_back(xtn);
		
	//@(axi_if.slave_drv_cb);
     //`uvm_info("AXI_SLAVE_DRIVER",$sformatf("printing from slave driver write data method \n %s", xtn.sprint()),UVM_LOW) 

	`uvm_info(get_type_name()," write data channel ended",UVM_LOW);
endtask

task wait_b(m_axi_txn xtn);
	`uvm_info(get_type_name()," write response channel started",UVM_LOW);

		//repeat($urandom_range(1,5))
	
        axi_if.slave_drv_cb.BID <= xtn.AWID;
	axi_if.slave_drv_cb.BRESP <= '0;
	axi_if.slave_drv_cb.BVALID <= 1;
      
	@(axi_if.slave_drv_cb);

	 wait(axi_if.slave_drv_cb.BREADY);

	 // @(axi_if.slave_drv_cb);

	axi_if.slave_drv_cb.BVALID <=0;
	axi_if.slave_drv_cb.BRESP <= 'hx;

	   repeat($urandom_range(1,5))
	 @(axi_if.slave_drv_cb);   
     `uvm_info("AXI_SLAVE_DRIVER",$sformatf("printing from slave driver write response method \n %s", xtn.sprint()),UVM_LOW) 

	`uvm_info(get_type_name()," write reponse channel ended",UVM_LOW);

endtask

task drive_ar();
	`uvm_info(get_type_name()," read address channel started",UVM_LOW);
	r_xtn=m_axi_txn::type_id::create("r_xtn");

	//@(axi_if.slave_drv_cb)
	axi_if.slave_drv_cb.ARREADY <= 1;
@(axi_if.slave_drv_cb)

	wait(axi_if.slave_drv_cb.ARVALID);

	//smapling read address data
 	r_xtn.ARID = axi_if.slave_drv_cb.ARID;
	r_xtn.ARADDR = axi_if.slave_drv_cb.ARADDR;
	r_xtn.ARLEN = axi_if.slave_drv_cb.ARLEN;
	r_xtn.ARSIZE = axi_if.slave_drv_cb.ARSIZE;
	r_xtn.ARBURST = axi_if.slave_drv_cb.ARBURST;


	r_q.push_back(r_xtn);

	axi_if.slave_drv_cb.ARREADY <= 0;

 	repeat($urandom_range(1,5))
	@(axi_if.slave_drv_cb);


	//@(axi_if.slave_drv_cb);
     //`uvm_info("AXI_SLAVE_DRIVER",$sformatf("printing from slave driver read address method \n %s", r_xtn.sprint()),UVM_LOW) 

 	`uvm_info(get_type_name()," read address channel ended",UVM_LOW);

endtask

task drive_r(m_axi_txn xtn);

	`uvm_info(get_type_name()," read data channel started",UVM_LOW);

         xtn.RDATA=new[xtn.ARLEN+1];
      
           for(int i=0;i<=xtn.ARLEN;i++)
                 begin
		      
		      //@(axi_if.slave_drv_cb);
                     axi_if.slave_drv_cb.RVALID <= 1;
                      axi_if.slave_drv_cb.RID <= xtn.ARID;
                      axi_if.slave_drv_cb.RDATA <= $urandom;
                      axi_if.slave_drv_cb.RRESP <= 0;
                     if(i == xtn.ARLEN)
			axi_if.slave_drv_cb.RLAST <= 1;
	             else
			axi_if.slave_drv_cb.RLAST <= 0;
		
			@(axi_if.slave_drv_cb);
                      wait(axi_if.slave_drv_cb.RREADY);

		      //@(axi_if.slave_drv_cb);
        
                        axi_if.slave_drv_cb.RVALID <= 0;
			axi_if.slave_drv_cb.RLAST <= 0;
 			axi_if.slave_drv_cb.RRESP <= 'hx;

			//sampling rdata
			xtn.RDATA[i]=axi_if.slave_drv_cb.RDATA;

                         repeat($urandom_range(1,5))
                          @(axi_if.slave_drv_cb);

                   end
     `uvm_info("AXI_SLAVE_DRIVER",$sformatf("printing from slave driver read data method \n %s", xtn.sprint()),UVM_LOW) 

	`uvm_info(get_type_name(),"read data channel ended",UVM_LOW);
	  
endtask


function void report_phase(uvm_phase phase);
//`uvm_info(get_type_name(),$sformatf("Report: APB driver sent %0d transactions",apb_cfg.apb_drv_dut_cnt),UVM_LOW)
endfunction

endclass

