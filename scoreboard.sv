class axi_scoreboard extends uvm_scoreboard;

`uvm_component_utils(axi_scoreboard)

uvm_tlm_analysis_fifo #(m_axi_txn) fifo_slave [];
uvm_tlm_analysis_fifo #(m_axi_txn) fifo_master [];

axi_env_config axi_tb_cfg;

m_axi_txn slave_tr;
m_axi_txn master_tr;

////m_axi_txn slave_tr;
//m_axi_txn master_tr;

  covergroup write_cg;
option.per_instance=1;
       //ADDRESS
     
        WR_ADD : coverpoint master_tr.AWADDR {
					bins low = {[0:4095]};
					}
    	     	     
        //signals
        SIZE_AW : coverpoint master_tr.AWSIZE {
                   bins low[]  =  {0,1,2};
                 }
        LEN_AW : coverpoint master_tr.AWLEN {
                   bins low  =  {[0:15]};
                 }
        BURST_AW : coverpoint master_tr.AWBURST {
                   bins low[]  =  {0,1,2};
                 }
    
        // valid
       // VAL_AW : coverpoint master_tr.AWVALID {bins valid = {1};}
	//VAL_W : coverpoint master_tr.WVALID {bins valid = {1};}
      //  VAL_B : coverpoint master_tr.BVALID { bins valid = {1};}

	//ready
      //  READY_AW : coverpoint master_tr.AWREADY { bins valid = {1};}
       // READY_W : coverpoint master_tr.WREADY { bins valid = {1};}
       // READY_B : coverpoint master_tr.BREADY { bins valid = {1};}

    endgroup
  covergroup write_cg1 with function sample(int i);
option.per_instance=1;
       //ADDRESS
     
        W_data : coverpoint master_tr.WDATA[i] {bins low = {[0:32'hffff_ffff]};}
        W_strb : coverpoint master_tr.WSTRB[i] {bins s0[] = {0,3,8,15,1,2,4,12};
							/*bins s1 = {8};
							bins s2 = {15};
							bins s3 = {1};
							bins s4 = {2};
							bins s5 = {4};
							bins s6 = {12};
							bins s7 = {3};*/   }

       // w_last : coverpoint master_tr.WLAST { bins val = {1};}

	endgroup
  covergroup read_cg;
option.per_instance=1;
       //ADDRESS
     
        RD_ADD : coverpoint slave_tr.ARADDR {
					bins low = {[0:4095]};
					}
    	     	     
        //signals
        SIZE_AR : coverpoint slave_tr.ARSIZE {
                   bins low  =  {0,1,2};
                 }
        LEN_AR : coverpoint slave_tr.ARLEN {
                   bins low  =  {[0:15]};
                 }
        BURST_AR : coverpoint slave_tr.ARBURST {
                   bins low[]  =  {0,1,2};
                 }
        b_resp : coverpoint slave_tr.BRESP {bins s0 = {0};}

        // valid
        //VAL_AR : coverpoint slave_tr.ARVALID {bins valid = {1};}
	//VAL_R : coverpoint slave_tr.RVALID {bins valid = {1};}

	//ready
        //READY_AR : coverpoint slave_tr.ARREADY { bins valid = {1};}
       // READY_R : coverpoint slave_tr.RREADY { bins valid = {1};}
          
    endgroup
  covergroup read_cg1 with function sample(int i);
option.per_instance=1;
       //ADDRESS
     
        r_data : coverpoint slave_tr.RDATA[i] {bins low = {[0:32'hffff_ffff]};}
        r_resp : coverpoint slave_tr.RRESP[i] {bins s0 = {0};}
        //r_last : coverpoint slave_tr.RLAST { bins val = {1};}

	endgroup

  function new(string name="axi_scoreboard", uvm_component parent);
    super.new(name, parent);
 	write_cg  = new();
	read_cg   = new();
	write_cg1 = new();
	read_cg1  = new();
    //fifo_apb = new("fifo_apb", this);
    //fifo_spi = new("fifo_spi", this);
	
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db#(axi_env_config)::get(this,"","axi_env_config",axi_tb_cfg))
  `uvm_fatal("CONFIG","cannot get() this spi_tb_cfg from uvm_config_db, have you set it?");
	
	//RAL local reg block assigning
	//this.spi_rb=spi_tb_cfg.spi_rb;

	
	//fifo new constructor assigning
	fifo_slave=new[axi_tb_cfg.no_of_slave_agent];
	foreach(fifo_slave[i])
	   fifo_slave[i]=new($sformatf("fifo_slave[%0d]",i),this);

	fifo_master=new[axi_tb_cfg.no_of_master_agent];
	foreach(fifo_master[i])
	   fifo_master[i]=new($sformatf("fifo_master[%0d]",i),this);


  endfunction

  task run_phase(uvm_phase phase);

//	phase.raise_objection(this);
	//repeat(1) 
	forever
		begin
			 //master_tr = m_axi_txn::type_id::create("master_tr");
   			 //slave_tr  = m_axi_txn::type_id::create("slave_tr");
			
		 		fifo_master[0].get(master_tr);
				fifo_slave[0].get(slave_tr);	

			if(master_tr.compare(slave_tr))
					begin
		$display("||||||||||||||||||||||||  SCOREBOARD DATA MATCH SUCCESSFULL ||||||||||||||||||||||");
		$display("|||||||||||||||||||||||| ================================== ||||||||||||||||||||||");

	`uvm_info(get_type_name(),$sformatf("|||||||||||| printing from scorebaord MASTER TRANSACTION ||||||||||||||| \n %s",master_tr.sprint()),UVM_LOW);
	`uvm_info(get_type_name(),$sformatf("|||||||||||| printing from scorebaord SLAVE TRANSACTION |||||||||||||||| \n %s",slave_tr.sprint()),UVM_LOW);



					//master_tr = master_tr;
					//slave_tr = slave_tr;
					write_cg.sample();
					read_cg.sample();
					if(master_tr.WVALID)
						 begin
							foreach(master_tr.WDATA[i])
							  	write_cg1.sample(i);
						end
					if(slave_tr.RVALID)
						begin	
							foreach(slave_tr.RDATA[i])
								read_cg1.sample(i);
						end
					end
				else
				$display("|||||||||||||||||||||||| SCOREBOARD DATA MATCH FAILD ||||||||||||||||||||||");
				$display("|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");

	`uvm_info(get_type_name(),$sformatf("|||||||||||| printing from scorebaord MASTER TRANSACTION ||||||||||||||| \n %s",master_tr.sprint()),UVM_LOW);
	`uvm_info(get_type_name(),$sformatf("|||||||||||| printing from scorebaord SLAVE TRANSACTION |||||||||||||||| \n %s",slave_tr.sprint()),UVM_LOW);
					
		end

//	phase.drop_objection(this);
endtask

endclass
