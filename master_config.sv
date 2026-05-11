class m_axi_agent_config extends uvm_object;

`uvm_object_utils(m_axi_agent_config)

virtual axi_intf axi_if;

uvm_active_passive_enum is_active=UVM_ACTIVE;

static int master_mon_rcvd_cnt=0;
static int master_drv_dut_cnt=0;

function new(string name="m_axi_agent_config");
super.new(name);
endfunction

endclass
