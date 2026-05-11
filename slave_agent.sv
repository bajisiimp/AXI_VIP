class s_axi_agent extends uvm_agent;

`uvm_component_utils(s_axi_agent)

s_axi_drv drvh;
s_axi_mon monh;
s_axi_seqr seqrh;

s_axi_agent_config m_cfg;

function new(string name="s_axi_agent", uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);

if(!uvm_config_db#(s_axi_agent_config)::get(this,"","s_axi_agent_config",m_cfg))
   `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config. have you  set() it?")
super.build_phase(phase);

monh=s_axi_mon::type_id::create("monh",this);

if(m_cfg.is_active==UVM_ACTIVE)

drvh=s_axi_drv::type_id::create("drvh",this);
seqrh=s_axi_seqr::type_id::create("seqrh",this);
endfunction

function void connect_phase(uvm_phase phase);
if(m_cfg.is_active==UVM_ACTIVE)
	begin
	  drvh.seq_item_port.connect(seqrh.seq_item_export);
	end
endfunction

endclass

