class axi_env extends uvm_env;

`uvm_component_utils(axi_env)

m_axi_agent_top magt_top;
s_axi_agent_top sagt_top;

 	//axi_virtual_sequencer v_sequencer;
	axi_scoreboard axi_sb;
	axi_env_config axi_env_cfg;

function new(string name="axi_env",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);

if(!uvm_config_db#(axi_env_config)::get(this,"","axi_env_config",axi_env_cfg))
	`uvm_fatal("CONFIG","cannot get() axi_env_cfg from uvm_config_db. have youo set it?")

//slave top agent creation
	sagt_top=s_axi_agent_top::type_id::create("sagt_top",this);

//master agent top creation
	magt_top=m_axi_agent_top::type_id::create("magt_top",this);

	super.build_phase(phase);

//virtual and scoreboard creation

	/*if(axi_env_cfg.has_virtual_sequencer)
 	   v_sequencer=axi_virtual_sequencer::type_id::create("v_sequencer",this);*/
	if(axi_env_cfg.has_scoreboard)
 	   axi_sb=axi_scoreboard::type_id::create("scoreboard",this);

endfunction

function void connect_phase(uvm_phase phase);
     
    /*if(axi_env_cfg.has_virtual_sequencer)begin
    if(axi_env_cfg.has_master_agent)
     foreach(agnth[i])
     v_sequencer.m_seqrh=magt_top.agnth[i].seqrh;
    if(axi_env_cfg.has_slave_agnt)
       foreach(agnth[i])
      v_sequencer.s_seqrh=sagt_top.agnth[i].seqrh;*/

	if(axi_env_cfg.has_scoreboard) 
	begin
	foreach(sagt_top.agnth[i])
	sagt_top.agnth[i].monh.monitor_port.connect(axi_sb.fifo_slave[i].analysis_export);
	foreach(magt_top.agnth[i])
	//connecting scorboard to apb by analysis  port
	magt_top.agnth[i].monh.monitor_port.connect(axi_sb.fifo_master[i].analysis_export);
	end

endfunction

endclass	
