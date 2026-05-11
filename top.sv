module top;

import axi_test_pkg::*;

import uvm_pkg::*;

bit clock;

always #10 clock=!clock;

axi_intf axi_if(clock);

initial begin
		`ifdef VCS
         	$fsdbDumpvars(0, top);
        	`endif

	uvm_config_db#(virtual axi_intf)::set(null,"*","axi_if",axi_if);
	
	run_test("base_test");
end
endmodule

