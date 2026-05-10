module axi_tb_top;
  reg aclk, aresetn;
  axi_if axi_if_inst(aclk, aresetn);  //we are creating physical i/f, means allocating memory

  axi_slave axi_slave_inst(
	  aclk,
	  aresetn,
  axi_if_inst.awid,
  axi_if_inst.awaddr,
  axi_if_inst.awlen,
  axi_if_inst.awsize,
  axi_if_inst.awburst,
  axi_if_inst.awlock,
  axi_if_inst.awcache,
  axi_if_inst.awprot,
  axi_if_inst.awvalid,
  axi_if_inst.awready,

  axi_if_inst.wid,
  axi_if_inst.wdata,
  axi_if_inst.wstrb,
  axi_if_inst.wlast,
  axi_if_inst.wvalid,
  axi_if_inst.wready,

  axi_if_inst.bid,
  axi_if_inst.bresp,
  axi_if_inst.bvalid,
  axi_if_inst.bready,

  axi_if_inst.arid,
  axi_if_inst.araddr,
  axi_if_inst.arlen,
  axi_if_inst.arsize,
  axi_if_inst.arburst,
  axi_if_inst.arlock,
  axi_if_inst.arcache,
  axi_if_inst.arprot,
  axi_if_inst.arvalid,
  axi_if_inst.arready,

  axi_if_inst.rid,
  axi_if_inst.rdata,
  axi_if_inst.rlast,
  axi_if_inst.rvalid,
  axi_if_inst.rready,
  axi_if_inst.rresp
  );

  axi_tb tb_inst(axi_if_inst);

  initial begin
	  $display("axi_tb_top: Initial block");
	  aclk = 1'b0;
	  aresetn = 1'b0;
	  #5;
	  aresetn = 1'b1;
	  #10000;
	  $finish;
  end
initial
  forever begin
	  aclk = #5 ~aclk; //aclk will be of 10 ns time period
  end
endmodule
