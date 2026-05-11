class s_axi_agent_top extends uvm_env;

`uvm_component_utils(s_axi_agent_top)

s_axi_agent agnth[];

axi_env_config e_cfg;

function new (string name="s_axi_agent_top",uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
	if(!uvm_config_db#(axi_env_config)::get(this,"","axi_env_config",e_cfg))
   `uvm_fatal("CONFIG","cannot get() e_cfg from uvm_config. have you  set() it?")
agnth=new[e_cfg.no_of_slave_agent];

foreach(agnth[i])
begin
	agnth[i]=s_axi_agent::type_id::create($sformatf("agnth[%0d]",i),this);

	//seting the config class to each agent
	uvm_config_db#(s_axi_agent_config)::set(this,$sformatf("agnth[%0d]*",i),"s_axi_agent_config",e_cfg.s_cfg[i]);

end
endfunction

task run_phase(uvm_phase phase);
//uvm_top.print_topology;
endtask

endclass

