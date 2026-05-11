class m_axi_drv extends uvm_driver #(m_axi_txn);

`uvm_component_utils(m_axi_drv)

virtual axi_intf.MASTER_DRV_MP axi_if;

m_axi_agent_config m_cfg;

m_axi_txn aw_q[$];
m_axi_txn ar_q[$];
m_axi_txn w_q[$];
m_axi_txn r_q[$];
m_axi_txn resp_q[$];

//int max_outstanding = 8;

semaphore sem_outstanding;
semaphore sem_rd_outstanding;
semaphore sem_aw_to_w;
semaphore sem_ar_to_r;
semaphore sem_w_to_b;
semaphore sem_w;
semaphore sem_wresp;
semaphore sem_r;


function new(string name="m_axi_drv", uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);

super.build_phase(phase);

if(!uvm_config_db#(m_axi_agent_config)::get(this,"","m_axi_agent_config",m_cfg))
`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?") 

  sem_outstanding    = new(1); //addr
  sem_rd_outstanding = new(1); //raddr
  sem_aw_to_w        = new();
  sem_ar_to_r        = new();
  sem_w_to_b         = new();
  sem_w		     = new(1);
  sem_wresp	     = new(1);
  sem_r   	     = new(1);

  /*aw_mb = new();
  w_mb  = new();
  b_mb  = new();*/

endfunction

function void connect_phase(uvm_phase phase);
  axi_if = m_cfg.axi_if;
endfunction

task run_phase(uvm_phase phase);

  forever 
   begin
    seq_item_port.get_next_item(req);

    //if(tr.is_write) begin
	      	aw_q.push_back(req);
      		w_q.push_back(req);
		resp_q.push_back(req);
   		ar_q.push_back(req);
	      	r_q.push_back(req);

      fork
		begin
	      	sem_outstanding.get(1);  
     		drive_aw(aw_q.pop_front());
	        sem_aw_to_w.put(1);
		sem_outstanding.put(1);
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
		wait_b(resp_q.pop_front());
		sem_wresp.put(1);
                end

		begin
		sem_rd_outstanding.get(1);
		drive_ar(ar_q.pop_front());
   		sem_ar_to_r.put(1);
		sem_rd_outstanding.put(1);
		end

		begin
	        sem_ar_to_r.get(1);
		sem_r.get(1);
		drive_r(r_q.pop_front());
		sem_r.put(1);
		end
//end
      join_any
    //end

    seq_item_port.item_done();
  end

endtask

task drive_aw(m_axi_txn xtn);
	
	`uvm_info(get_type_name()," write address channel started",UVM_LOW);
//	@(axi_if.master_drv_cb)

 	axi_if.master_drv_cb.AWID<=xtn.AWID;
	axi_if.master_drv_cb.AWADDR<=xtn.AWADDR;
	axi_if.master_drv_cb.AWLEN<=xtn.AWLEN;
	axi_if.master_drv_cb.AWSIZE<=xtn.AWSIZE;
	axi_if.master_drv_cb.AWBURST<=xtn.AWBURST;
	axi_if.master_drv_cb.AWVALID<=1;

	@(axi_if.master_drv_cb)
	wait(axi_if.master_drv_cb.AWREADY)
//	@(axi_if.master_drv_cb)

	axi_if.master_drv_cb.AWVALID<=0;

       
      //end
           repeat($urandom_range(1,5))
		@(axi_if.master_drv_cb)
	`uvm_info(get_type_name()," write address channel ended",UVM_LOW);

endtask

task drive_w(m_axi_txn xtn);
	`uvm_info(get_type_name()," write data channel started",UVM_LOW);

	//@(axi_if.master_drv_cb);


 		for(int i=0;i<=xtn.AWLEN;i++)
		  begin
		//	@(axi_if.master_drv_cb);
	  		axi_if.master_drv_cb.WID<=xtn.WID;
			axi_if.master_drv_cb.WDATA<=xtn.WDATA[i];
	  		axi_if.master_drv_cb.WSTRB<=xtn.WSTRB[i];
	                if(i==xtn.AWLEN)
                           axi_if.master_drv_cb.WLAST <= 1;
			else
                           axi_if.master_drv_cb.WLAST <= 0;
	  		axi_if.master_drv_cb.WVALID<=1;

 			   @(axi_if.master_drv_cb);
	  		wait(axi_if.master_drv_cb.WREADY);
 			axi_if.master_drv_cb.WVALID<=0;
			axi_if.master_drv_cb.WLAST <=0;
			repeat($urandom_range(1,5))
			@(axi_if.master_drv_cb);

		   end

	`uvm_info(get_type_name()," write data channel ended",UVM_LOW);
endtask
int id;

task wait_b(m_axi_txn xtn);
	`uvm_info(get_type_name()," write response channel started",UVM_LOW);

//	@(axi_if.master_drv_cb);
	axi_if.master_drv_cb.BREADY<=1;

@(axi_if.master_drv_cb);
        wait(axi_if.master_drv_cb.BVALID)

	  axi_if.master_drv_cb.BREADY <=0;

	     //xtn.BID=axi_if.master_drv_cb.BID;
	     //xtn.BRESP=axi_if.master_drv_cb.BRESP;

	     //@(axi_if.master_drv_cb);
 	repeat($urandom_range(1,5))	   
	     @(axi_if.master_drv_cb);

	`uvm_info(get_type_name()," write reponse channel ended",UVM_LOW);
	$display("==================================================================");
	$display("==================================================================");

     `uvm_info("AXI_WR_DRIVER",$sformatf("printing from driver write response \n %s", xtn.sprint()),UVM_LOW)


endtask

task drive_ar(m_axi_txn xtn);
	`uvm_info(get_type_name()," read address channel started",UVM_LOW);

        //@(axi_if.master_drv_cb)


 	axi_if.master_drv_cb.ARID<=xtn.ARID;
	axi_if.master_drv_cb.ARADDR<=xtn.ARADDR;
	axi_if.master_drv_cb.ARLEN<=xtn.ARLEN;
	axi_if.master_drv_cb.ARSIZE<=xtn.ARSIZE;
	axi_if.master_drv_cb.ARBURST<=xtn.ARBURST;
	axi_if.master_drv_cb.ARVALID<=1;

	@(axi_if.master_drv_cb)
	wait(axi_if.master_drv_cb.ARREADY)
//	@(axi_if.master_drv_cb)

	axi_if.master_drv_cb.ARVALID<=0;

repeat($urandom_range(1,5))	
	@(axi_if.master_drv_cb);
	`uvm_info(get_type_name()," read address channel ended",UVM_LOW);

endtask

task drive_r(m_axi_txn xtn);
int mem[int];

	`uvm_info(get_type_name()," read data channel started",UVM_LOW);
	

          //xtn.cal_raddr();
       	  xtn.RDATA=new[xtn.ARLEN+1];
      
           for(int i=0;i<=xtn.ARLEN;i++)
                 begin
                      axi_if.master_drv_cb.RREADY<=1;
                      @(axi_if.master_drv_cb);
                      wait(axi_if.master_drv_cb.RVALID)
		      //@(axi_if.master_drv_cb);
                                 
                                 
                       //mem[xtn.ARADDR[i]]=axi_if.master_drv_cb.RDATA;
                      	//$display("==================================================================");
                 
                       xtn.RDATA[i] =  axi_if.master_drv_cb.RDATA;
  
                       axi_if.master_drv_cb.RREADY<=0;
                         repeat($urandom_range(1,5))
                          @(axi_if.master_drv_cb);

                   end

             $displayh("master received address:%p",xtn.ARADDR);
             $displayh("memory received in master driver is %p",mem);

	`uvm_info(get_type_name(),"read data channel ended",UVM_LOW);
	$display("==================================================================");
	$display("==================================================================");

     `uvm_info("AXI_WR_DRIVER",$sformatf("printing from driver read data \n %s", xtn.sprint()),UVM_LOW)

	  
endtask

function void report_phase(uvm_phase phase);
//`uvm_info(get_type_name(),$sformatf("Report: APB driver sent %0d transactions",apb_cfg.apb_drv_dut_cnt),UVM_LOW)
endfunction

endclass



/*
class m_driver extends uvm_driver#(axi_xtn);
    `uvm_component_utils(m_driver)
int length;
    virtual axi_if.MST_DRV mif;
    master_config mst_cfg_h;

    axi_xtn xtn;
        axi_xtn q1[$], q2[$],q3[$],q4[$],q5[$];
        semaphore sem = new();
	semaphore sem1 = new();
	semaphore sem2 = new(1);
	semaphore sem3 = new(1);
	semaphore sem4 = new(1);
	
	semaphore sem5 = new(1);
	semaphore sem6 = new(1);
	semaphore sem7 = new();

    extern function new(string name = "m_driver", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
        extern task  run_phase(uvm_phase phase);
        extern task drive(axi_xtn xtn);
        extern task drive_awaddr(axi_xtn xtn);
        extern task drive_wdata(axi_xtn xtn);
        extern task drive_bresp(axi_xtn xtn);

        extern task drive_raddr(axi_xtn xtn);
        extern task drive_rdata(axi_xtn xtn);
endclass: m_driver

    function m_driver::new(string name = "m_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void m_driver::build_phase(uvm_phase phase);
        if(!uvm_config_db#(master_config)::get(this, "", "master_config", mst_cfg_h))
            `uvm_fatal("Master Driver", "getting config failed");
            super.build_phase(phase);
    endfunction

    function void m_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
     mif=mst_cfg_h.mif;
    endfunction

        task m_driver::run_phase(uvm_phase phase);
             
                forever
                begin
                        seq_item_port.get_next_item(req);
                        drive(req);
                        seq_item_port.item_done();
               		 req.print();
                end
        endtask

        task m_driver::drive(axi_xtn xtn);
        q1.push_back(xtn);
        q2.push_back(xtn);
        q3.push_back(xtn);
        q4.push_back(xtn);
	q5.push_back(xtn);
           fork
               begin
                        sem2.get(1);
                        drive_awaddr(q1.pop_front());
                        sem.put(1);
                        sem2.put(1);
                end

               begin
                        sem.get(1);
                        sem3.get(1);
                        drive_wdata(q2.pop_front());
                         sem1.put(1);
                         sem3.put(1);

                end

                begin
                        sem1.get(1);
                        sem4.get(1);
                        drive_bresp(q3.pop_front());
                        sem4.put(1);
                end

                begin
                        sem5.get(1);
                        drive_raddr(q4.pop_front());
                        sem7.put(1);
                        sem5.put(1);
                     end
                begin
                        sem7.get(1);
                        sem6.get(1);
                        drive_rdata(q5.pop_front());
                        sem6.put(1);
                end  
           join
      endtask

        task m_driver::drive_awaddr(axi_xtn xtn);
                mif.mst_drv_cb.awvalid <= 1;                               
                mif.mst_drv_cb.awaddr <= xtn.awaddr;
                mif.mst_drv_cb.awsize <= xtn.awsize;
                mif.mst_drv_cb.awid <= xtn.awid;
                mif.mst_drv_cb.awlen <= xtn.awlen;
                mif.mst_drv_cb.awburst <= xtn.awburst;

                @(mif.mst_drv_cb);
                while(!mif.mst_drv_cb.awready)
		@(mif.mst_drv_cb);
                mif.mst_drv_cb.awvalid <= 0;

                repeat($urandom_range(1,5))
                        @(mif.mst_drv_cb);

        endtask

        task m_driver::drive_wdata(axi_xtn xtn);
 $display(" The size of wdata %d",xtn.wdata.size);
 length = xtn.awlen;
  //xtn.cal_addr();
 $display(" The size of wdata %p",xtn.wdata);

        for(int i=0; i<length+1; i++)

       
   
                        begin
                                mif.mst_drv_cb.wvalid <= 1;
                                mif.mst_drv_cb.wdata <= xtn.wdata[i];
                                mif.mst_drv_cb.wstrb <= xtn.wstrb[i];
                                mif.mst_drv_cb.wid <= xtn.wid;
                                if(i==(xtn.awlen))
                                        mif.mst_drv_cb.wlast <= 1;
                                else
                                        mif.mst_drv_cb.wlast <= 0;

                                @(mif.mst_drv_cb);
                                while(!mif.mst_drv_cb.wready)
				@(mif.mst_drv_cb);
                                    mif.mst_drv_cb.wvalid <= 0;
                                    mif.mst_drv_cb.wlast <= 0;

                                repeat($urandom_range(1,5))
                                        @(mif.mst_drv_cb);
                        end

           endtask

        task m_driver::drive_bresp(axi_xtn xtn);
         

                		mif.mst_drv_cb.bready<=1;
          			@(mif.mst_drv_cb)
         			while(!mif.mst_drv_cb.bvalid)
				@(mif.mst_drv_cb);
              			mif.mst_drv_cb.bready<=0;
           			repeat($urandom_range(1,5))
                                @(mif.mst_drv_cb);
        endtask

      task m_driver:: drive_raddr(axi_xtn xtn);
            repeat($urandom_range(1,5))
                  @(mif.mst_drv_cb);
           mif.mst_drv_cb.arvalid<=1;                  
           mif.mst_drv_cb.arid<=xtn.arid;
           mif.mst_drv_cb.arlen<=xtn.arlen;
           mif.mst_drv_cb.arsize<=xtn.arsize;
           mif.mst_drv_cb.arburst<=xtn.arburst;
           mif.mst_drv_cb.araddr<=xtn.araddr;
                 @(mif.mst_drv_cb);
                  while(!mif.mst_drv_cb.arready)
		@(mif.mst_drv_cb);

                    mif.mst_drv_cb.arvalid<=0;
              repeat($urandom_range(1,5))
                    @(mif.mst_drv_cb);

           endtask

        task m_driver::drive_rdata(axi_xtn xtn);
         int mem[int];
          xtn.cal_raddr();
       xtn.rdata=new[xtn.arlen+1];
      
           for(int i=0;i<(xtn.arlen+1);i++)
                 begin
                      mif.mst_drv_cb.rready<=1;
                      @(mif.mst_drv_cb);
                      while(!mif.mst_drv_cb.rvalid)
		      @(mif.mst_drv_cb);
                                 
                                 
                                         mem[xtn.raddr[i]]=mif.mst_drv_cb.rdata[i];
                                       
                               
                                  mif.mst_drv_cb.rready<=0;
                         repeat($urandom_range(1,5))
                          @(mif.mst_drv_cb);

                   end
             $displayh("master received address:%p",xtn.raddr);
             $displayh("memory received in master driver is %p",mem);

                 endtask



*/
