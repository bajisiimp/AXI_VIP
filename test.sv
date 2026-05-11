class base_test extends uvm_test;

`uvm_component_utils(base_test)

axi_env envh;
axi_env_config axi_tb_cfg;


bit has_master_agnt=1;
bit has_slave_agnt=1;
int no_of_master_agent=1;
int no_of_slave_agent=1;

s_axi_agent_config s_agnt_cfg[];
m_axi_agent_config m_agnt_cfg[];

function new(string name="base_test",uvm_component parent);
super.new(name,parent);
endfunction
function void build_phase(uvm_phase phase);
  
       axi_tb_cfg=axi_env_config::type_id::create("axi_tb_config");
       if(has_slave_agnt) 
	   begin
             axi_tb_cfg.s_cfg=new[no_of_slave_agent];
             s_agnt_cfg=new[no_of_slave_agent];

	foreach(s_agnt_cfg[i])
          begin
	      s_agnt_cfg[i]=s_axi_agent_config::type_id::create($sformatf("s_axi_agnt_cfg[%0d]",i));
	      if(!uvm_config_db#(virtual axi_intf)::get(this,"","axi_if",s_agnt_cfg[i].axi_if))
	       `uvm_fatal("VIF CONFIG","cannot get() interface spi_if from uvm_config_db.have you set() it?")
    	
             s_agnt_cfg[i].is_active=UVM_ACTIVE;
  	     axi_tb_cfg.s_cfg[i]=s_agnt_cfg[i];
           end
	end

       if(has_master_agnt) 
	   begin
        	axi_tb_cfg.m_cfg=new[no_of_master_agent];
        	m_agnt_cfg=new[no_of_master_agent];
	foreach(m_agnt_cfg[i])
          begin
	      m_agnt_cfg[i]=m_axi_agent_config::type_id::create($sformatf("m_axi_agnt_cfg[%0d]",i));
	      if(!uvm_config_db#(virtual axi_intf)::get(this,"","axi_if",m_agnt_cfg[i].axi_if))
	        `uvm_fatal("VIF CONFIG","cannot get() interface axi_if from uvm_config_db.have you set() it?")
    	
             m_agnt_cfg[i].is_active=UVM_ACTIVE;
  	     axi_tb_cfg.m_cfg[i]=m_agnt_cfg[i];
           end
	end

	axi_tb_cfg.has_slave_agnt=has_slave_agnt;
	axi_tb_cfg.has_master_agnt=has_master_agnt;
	axi_tb_cfg.no_of_master_agent=no_of_master_agent;
	axi_tb_cfg.no_of_slave_agent=no_of_slave_agent;


        uvm_config_db#(axi_env_config)::set(null,"*","axi_env_config",axi_tb_cfg);

        super.build_phase(phase);

        envh=axi_env::type_id::create("envh",this);

endfunction

function void end_of_elaboration();
uvm_top.print_topology;
endfunction


endclass

class fixed_trans extends base_test;

`uvm_component_utils(fixed_trans);

m_axi_fixed_seq m_seq;
//s_axi_base_seq s_seq;

function new(string name="fixed_tranfer", uvm_component parent);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);

phase.raise_objection(this);
begin
m_seq=m_axi_fixed_seq::type_id::create("m_seq");
//s_seq=s_axi_base_seq::type_id::create("s_seq");

m_seq.start(envh.magt_top.agnth[0].seqrh);
//s_seq.start(envh.sagt_top.agnth[0].seqrh);
#2500;
//#10000;
end
phase.drop_objection(this);
endtask

endclass

class incr_trans extends base_test;

`uvm_component_utils(incr_trans);

m_axi_INCR_seq m_seq;
//s_axi_base_seq s_seq;

function new(string name="incr_tranfer", uvm_component parent);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);

phase.raise_objection(this);
m_seq=m_axi_INCR_seq::type_id::create("m_seq");
//s_seq=s_axi_base_seq::type_id::create("s_seq");
fork
m_seq.start(envh.magt_top.agnth[0].seqrh);
//s_seq.start(envh.sagt_top.agnth[0].seqrh);
join
#10000;
phase.drop_objection(this);
endtask

endclass

class wrap_trans extends base_test;

`uvm_component_utils(wrap_trans);

m_axi_wrap_seq m_seq;
//s_axi_base_seq s_seq;

function new(string name="wrap_tranfer", uvm_component parent);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);

phase.raise_objection(this);

m_seq=m_axi_wrap_seq::type_id::create("m_seq");
//s_seq=s_axi_base_seq::type_id::create("s_seq");
begin
m_seq.start(envh.magt_top.agnth[0].seqrh);
//s_seq.start(envh.sagt_top.agnth[0].seqrh);
#3000;
end
phase.drop_objection(this);
endtask

endclass

class size_trans extends base_test;

`uvm_component_utils(size_trans);

m_axi_size_seq m_seq;
//s_axi_base_seq s_seq;

function new(string name="size_tranfer", uvm_component parent);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);

phase.raise_objection(this);

m_seq=m_axi_size_seq::type_id::create("m_seq");
//s_seq=s_axi_base_seq::type_id::create("s_seq");
begin
m_seq.start(envh.magt_top.agnth[0].seqrh);
//s_seq.start(envh.sagt_top.agnth[0].seqrh);
#3000;
end
phase.drop_objection(this);
endtask

endclass

class strb_trans extends base_test;

`uvm_component_utils(strb_trans);

m_axi_strb_seq m_seq;
//s_axi_base_seq s_seq;

function new(string name="strb_tranfer", uvm_component parent);
super.new(name,parent);
endfunction

task run_phase(uvm_phase phase);
super.run_phase(phase);

phase.raise_objection(this);

m_seq=m_axi_strb_seq::type_id::create("m_seq");
//s_seq=s_axi_base_seq::type_id::create("s_seq");
begin
m_seq.start(envh.magt_top.agnth[0].seqrh);
//s_seq.start(envh.sagt_top.agnth[0].seqrh);
#5000;
end
phase.drop_objection(this);
endtask

endclass

