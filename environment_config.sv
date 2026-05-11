class axi_env_config extends uvm_object;

`uvm_object_utils(axi_env_config)

//properties

bit has_function_coverage=0;
bit has_virtual_sequencer=1;
bit has_scoreboard=1;
bit has_master_agnt=1;
bit has_slave_agnt=1;
int no_of_master_agent;
int no_of_slave_agent;

m_axi_agent_config m_cfg[];
s_axi_agent_config s_cfg[];

//RAL implemenation
//spi_reg_block spi_rb;

function new(string name="axi_env_config");
super.new(name);
endfunction

endclass


