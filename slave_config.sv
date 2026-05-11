class s_axi_agent_config extends uvm_object;

`uvm_object_utils(s_axi_agent_config)

virtual axi_intf axi_if;

uvm_active_passive_enum is_active=UVM_ACTIVE;

static int slave_mon_rcvd_cnt=0;
static int slave_drv_dut_cnt=0;

function new(string name="s_axi_agent_config");
super.new(name);
endfunction

endclass

