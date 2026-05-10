  `timescale 1 ps/ 1 ps  

  `include "env_pkg.sv"
   import env_pkg :: *;
  `include "axi_slave_write.sv"
  `include "axi_slave_read.sv"
  `include "interface.sv"
  //`include "binding_assertion.sv"  
  `include "binding_assertion_write.sv"
 // `include "binding_module.sv"
  `include "binding_assertion_read.sv"


module axi_top;

   import uvm_pkg :: *;
  `include "uvm_macros.svh"

   bit    clk;
   bit    reset_n;
   int    total_transaction;

   initial begin
      clk = 1;
     _if.awid=0;
     _if.awaddr=0;          
       _if.awlen=0;    
      _if.awburst=0;         
      _if.awsize=0;          
      _if.awvalid=0;         
      _if.bready=0;
       _if.wdata=0;
       _if.wstrb=0;
        _if.wlast=0;
        _if.wvalid=0;
        
     
     
     _if.arid=0;   
     _if.araddr=0;          
     _if.arlen=0;           
     _if.arburst=0;         
     _if.arsize=0;        
     _if.arvalid=0;        
    // _if.rdata=0;
     _if.rready=0;
     
     
     
      forever #5 clk = ~clk;
   end

   initial begin
      @(posedge clk) reset_n = 0;
     repeat(1) @(posedge clk);
     #5;
      reset_n = 1;
   end
  
   axi_intf _if ( .clk(clk), .reset_n(reset_n) );
   // -----------------------------------------------------
   bind axi_slave_write axi_assertion_write assert_wr (
     .clk(clk) , 
     .reset_n(reset_n),
     .awid(awid),
     .awaddr(awaddr),
     .awlen(awlen),
     .awburst(awburst),
     .awsize(awsize),
     .awvalid(awvalid),
     .awready(awready),
     .wvalid(wvalid),
     .wready(wready),
     .wdata(wdata),
     .wlast(wlast)
     
  );
   // -----------------------------------------------------
   bind axi_slave_read axi_assertion_read assert_rd (
     .clk(clk) , 
     .reset_n(reset_n),
     .arid(arid),
     .araddr(araddr),
     .arlen(arlen),
     .arburst(arburst),
     .arsize(arsize),
     .arvalid(arvalid),
     .arready(arready),
     .rvalid(rvalid),
     .rready(rready),
     .rdata(rdata),
     .rlast(rlast)
     
  );
     
  // -----------------------------------------------------

   axi_slave_write rtlw ( .clk            (clk),
                          .reset_n        (reset_n), 
                          .awid           (_if.awid),   
                          .awaddr         (_if.awaddr),          
                          .awlen          (_if.awlen),           
                          .awburst        (_if.awburst),         
                          .awsize         (_if.awsize),          
                          .awvalid        (_if.awvalid),         
                          .awready        (_if.awready),         
                          .bid            (_if.bid),
                          .bresp          (_if.bresp),
                          .bvalid         (_if.bvalid),
                          .bready         (_if.bready),
                          .wdata          (_if.wdata),
                          .wstrobe        (_if.wstrb),
                          .wlast          (_if.wlast),
                          .wvalid         (_if.wvalid),
                          .wready         (_if.wready),
                          .min_rsp_delay  (_if.min_rsp_delay), 
                          .min_req_delay  (_if.min_req_delay),
                          .max_rsp_delay  (_if.max_rsp_delay),
                          .max_req_delay  (_if.max_req_delay),
                          .min_data_delay (_if.min_data_delay),
                          .max_data_delay (_if.max_data_delay),
                          .num_slave      (_if.num_slave)
                        ); 

   axi_slave_read  rtlr ( .clk            (clk),
                          .reset_n        (reset_n), 
                          .arid           (_if.arid),   
                          .araddr         (_if.araddr),          
                          .arlen          (_if.arlen),           
                          .arburst        (_if.arburst),         
                          .arsize         (_if.arsize),          
                          .arvalid        (_if.arvalid),         
                          .arready        (_if.arready),         
                          .rid            (_if.rid),
                          .rresp          (_if.rresp),
                          .rdata          (_if.rdata),
                          .rstrobe        (_if.rstrb),
                          .rlast          (_if.rlast),
                          .rvalid         (_if.rvalid),
                          .rready         (_if.rready),
                          .min_rsp_delay  (_if.min_rsp_delay), 
                          .min_req_delay  (_if.min_req_delay),
                          .max_rsp_delay  (_if.max_rsp_delay),
                          .max_req_delay  (_if.max_req_delay),
                          .interleaving_en(_if.interleaving_en),
                          .out_of_order_en(_if.out_of_order_en),
                          .num_slave      (_if.num_slave)
                        ); 
  // axi_write_bind dut (clk,reset_n,awid,awaddr,awlen,awburst,awsize,awvalid,awready);
   config_obj obj;

   initial begin
      obj = config_obj :: type_id :: create ("obj");
      obj.is_active   = UVM_ACTIVE;
      obj._if         = _if;
      total_transaction     = 10;
      uvm_config_db #(config_obj) :: set (null , "*" , "config_obj" , obj);
     uvm_config_db #(int)        :: set (null , "*" , "str" , total_transaction);
      $dumpfile("dump.vcd"); 
      $dumpvars;
     // run_test ("random_wr_test");
        //run_test ("single_wr_test");
run_test("burst_wr_test");

     
   end

endmodule : axi_top
