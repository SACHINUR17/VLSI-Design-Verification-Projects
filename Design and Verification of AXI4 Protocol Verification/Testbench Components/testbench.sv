import uvm_pkg::*;
`include "uvm_macros.svh"
`include "include_files.sv"

module tb_top;
bit clk;
//bit reset;

axi_interface intf(.clk(clk));

axi_dut inst(

   //GLOBAL CLOCK AND RESET
   .clk(clk),
   .rst(intf.reset),
   
   //WRITE ADDRESS BUS
   .s_axi_awid(intf.awid),
   .s_axi_awaddr(intf.awaddr),
   .s_axi_awlen(intf.awlen),
   .s_axi_awsize(intf.awsize),
   .s_axi_awburst(intf.awburst),
   .s_axi_awlock(intf.awlock),
   .s_axi_awcache(intf.awcache),
   .s_axi_awprot(intf.awprot),
   .s_axi_awvalid(intf.awvalid),
   .s_axi_awready(intf.awready),
   
   //WRITE DATA BUS
   .s_axi_wdata(intf.wdata),
   .s_axi_wstrb(intf.wstrb),
   .s_axi_wlast(intf.wlast),
   .s_axi_wvalid(intf.wvalid),
   .s_axi_wready(intf.wready),
   
   //WRITE RESPONSE BUS
   .s_axi_bid(intf.bid),
   .s_axi_bresp(intf.bresp),
   .s_axi_bvalid(intf.bvalid),
   .s_axi_bready(intf.bready),
   
   //READ ADDRESS BUS
   .s_axi_arid(intf.arid),
   .s_axi_araddr(intf.araddr),
   .s_axi_arlen(intf.arlen),
   .s_axi_arsize(intf.arsize),
   .s_axi_arburst(intf.arburst),
   .s_axi_arlock(intf.arlock),
   .s_axi_arcache(intf.arcache),
   .s_axi_arprot(intf.arprot),
   .s_axi_arvalid(intf.arvalid),
   .s_axi_arready(intf.arready),
   
   //READ DATA BUS
   .s_axi_rid(intf.rid),
   .s_axi_rdata(intf.rdata),
   .s_axi_rresp(intf.rresp),
   .s_axi_rlast(intf.rlast),
   .s_axi_rvalid(intf.rvalid),
   .s_axi_rready(intf.rready)
);

initial begin
   uvm_config_db#(virtual axi_interface)::set(null,"*","DATA",intf);
end

initial begin
   clk=0;
   forever #5 clk=~clk;
end

initial begin
   run_test("test_case_1");
   //run_test("test_case_2");
   //run_test("test_case_3");
   //run_test("test_case_4");
   //run_test("test_case_5");
end

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end
  
endmodule
