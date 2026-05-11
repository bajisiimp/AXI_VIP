class m_axi_agent extends uvm_agent;

`uvm_component_utils(m_axi_agent)

m_axi_drv drvh;
m_axi_mon monh;
m_axi_seqr seqrh;

m_axi_agent_config m_cfg;

function new(string name="m_axi_agent", uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);

if(!uvm_config_db#(m_axi_agent_config)::get(this,"","m_axi_agent_config",m_cfg))
   `uvm_fatal("CONFIG","cannot get() apb_cfg from m_config. have you  set() it?")
super.build_phase(phase);

monh=m_axi_mon::type_id::create("monh",this);

if(m_cfg.is_active==UVM_ACTIVE)

drvh=m_axi_drv::type_id::create("drvh",this);
seqrh=m_axi_seqr::type_id::create("seqrh",this);
endfunction

function void connect_phase(uvm_phase phase);
if(m_cfg.is_active==UVM_ACTIVE)
	begin
	  drvh.seq_item_port.connect(seqrh.seq_item_export);
	end
endfunction

endclass
