class m_axi_base_seq extends uvm_sequence #(m_axi_txn);

`uvm_object_utils(m_axi_base_seq)


function new(string name ="m_axi_base_seq");
super.new(name);
endfunction

endclass

//========================================================================================
//
//                   fixed seq for write data and read data
//
//========================================================================================
class m_axi_fixed_seq extends m_axi_base_seq;

`uvm_object_utils(m_axi_fixed_seq)

function new(string name ="m_axi_fixed_seq");
super.new(name);
endfunction

task body();
repeat(22)
begin
req=m_axi_txn::type_id::create("req");
start_item(req);
assert(req.randomize() with  {AWBURST==2'b00; ARBURST==2'b00;});
finish_item(req);
end
endtask

endclass
//========================================================================================
//
//                   incr seq for write data and read data
//
//========================================================================================

class m_axi_INCR_seq extends m_axi_base_seq;

`uvm_object_utils(m_axi_INCR_seq)

function new(string name ="m_axi_INCR_seq");
super.new(name);
endfunction

task body();
//repeat(3)
begin
req=m_axi_txn::type_id::create("req");
start_item(req);
assert(req.randomize() with  {AWBURST==2'b01; ARBURST == 2'b01;});
finish_item(req);
end
endtask

endclass
//========================================================================================
//
//                   wrap seq for write data and read data
//
//========================================================================================

class m_axi_wrap_seq extends m_axi_base_seq;

`uvm_object_utils(m_axi_wrap_seq)

function new(string name ="m_axi_wrap_seq");
super.new(name);
endfunction

task body();
//repeat(2)
begin
req=m_axi_txn::type_id::create("req");
start_item(req);
assert(req.randomize() with  {AWBURST==2'b10; ARBURST==2'b10;});
finish_item(req);
end
endtask

endclass
//========================================================================================
//
//                   wrap seq for write data and read data
//
//========================================================================================

class m_axi_size_seq extends m_axi_base_seq;

`uvm_object_utils(m_axi_size_seq)

function new(string name ="m_axi_size_seq");
super.new(name);
endfunction

task body();
repeat(1)
begin
req=m_axi_txn::type_id::create("req");
start_item(req);
assert(req.randomize() with  {AWSIZE==2'b01; ARBURST==2'b10;});
finish_item(req);
end
endtask

endclass
//========================================================================================
//
//                   wrap seq for write data and read data
//
//========================================================================================

class m_axi_strb_seq extends m_axi_base_seq;

`uvm_object_utils(m_axi_strb_seq)

function new(string name ="m_axi_strb_seq");
super.new(name);
endfunction

task body();
repeat(1)
begin
req=m_axi_txn::type_id::create("req");
start_item(req);
assert(req.randomize() with  {AWSIZE==2'b00; ARBURST==2'b10;});
finish_item(req);
end
endtask

endclass
