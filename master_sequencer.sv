class m_axi_seqr extends uvm_sequencer #(m_axi_txn);

`uvm_component_utils(m_axi_seqr)

function new(string name="m_axi_seqr", uvm_component parent);
super.new(name,parent);
endfunction

endclass
