// Code your testbench here
// or browse Examples

`include "axi_interface.sv"
`include "axi_common.sv"
`include "axi_slave.sv"
`include "axi_tx.sv"
`include "axi_assertion.sv"
`include "axi_gen.sv"
`include "axi_bfm.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_env.sv"


module top;
  reg clk,rst;
  
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
  
  initial begin
    #2000 $finish;
  end
  
  //axi_intf pif(clk,rst);
  axi_assertion axi_assert();//;axi_assert_i//assertion block
  axi_slave dut(
	 .aclk(pif.aclk),
	 .arst(pif.arst),
	 .awid(pif.awid),
	 .awaddr(pif.awaddr),
	 .awlen(pif.awlen),
	 .awsize(pif.awsize),
	 .awbrust(pif.awbrust),
	 .awlock(pif.awlock),
	 .awcache(pif.awcache),
	 .awprot(pif.awprot),
	 .awqos(pif.awqos),
	 .awregion(pif.awregion),
	 .awuser(pif.awuser),
	 .awvalid(pif.awvalid),
	 .awready(pif.awready),
	 .wid(pif.wid),
	 .wdata(pif.wdata),
	 .wstrb(pif.wstrb),
	 .wlast(pif.wlast),
	 .wuser(pif.wuser),
	 .wvalid(pif.wvalid),
	 .wready(pif.wready),
	 .bid(pif.bid),
	 .bresp(pif.bresp),
	 .buser(pif.buser),
	 .bvalid(pif.bvalid),
	 .bready(pif.bready),
	 .arid(pif.arid),
	 .araddr(pif.araddr),
	 .arlen(pif.arlen),
	 .arsize(pif.arsize),
	 .arbrust(pif.arbrust),
	 .arlock(pif.arlock),
	 .arcache(pif.arcache),
	 .arprot(pif.arprot),
	 .arqos(pif.arqos),
	 .arregion(pif.arregion),
	 .aruser(pif.aruser),
	 .arvalid(pif.arvalid),
	 .arready(pif.arready),
	 .rid(pif.rid),
	 .rdata(pif.rdata),
	 .rlast(pif.rlast),
	 .ruser(pif.ruser),
	 .rvalid(pif.rvalid),
	 .rready(pif.rready),
	 .rresp(pif.rresp)
  ); //slave model.
  
  axi_intf pif(clk, rst);
  axi_env env;
  initial $value$plusargs("testname=%s",axi_common::testname);
  initial begin
	axi_common::vif = pif;  
    rst = 1;
    reset_design_inputs();
    @(posedge clk);
    rst = 0;
    
    env = new();
    env.run();
  end

  task reset_design_inputs();
 	pif.awid=0;
 	pif.awaddr =0;
 	pif.awlen =0;
 	pif.awsize =0;
 	pif.awbrust =0;
 	pif.awlock =0;
 	pif.awcache =0;
 	pif.awprot =0;
 	pif.awqos =0;
 	pif.awregion =0;
 	pif.awuser =0;
 	pif.awvalid =0;
 	pif.wid =0;
 	pif.wdata =0;
 	pif.wstrb =0;
 	pif.wlast =0;
 	pif.wuser =0;
 	pif.wvalid =0;
 	pif.bready =0;
 	pif.arid =0;
 	pif.araddr =0;
 	pif.arlen =0;
 	pif.arsize =0;
 	pif.arbrust =0;
 	pif.arlock =0;
 	pif.arcache =0;
 	pif.arprot =0;
 	pif.arqos =0;
 	pif.arregion =0;
 	pif.aruser =0;
 	pif.arvalid =0;
 	pif.rready =0;
  
  endtask

endmodule
