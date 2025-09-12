`ifndef AXI_INTERFACE 
`define AXI_INTERFACE


interface axi_interface(input clk);

    // Width of data bus in bits
    parameter DATA_WIDTH = 32;
    // Width of address bus in bits
    parameter ADDR_WIDTH = 16;
    // Width of wstrb (width of data bus in words)
    parameter STRB_WIDTH = (DATA_WIDTH/8);
    // Width of ID signal
    parameter ID_WIDTH = 8;
    // Extra pipeline register on output
    parameter PIPELINE_OUTPUT = 0;

    logic reset;

    //WRITE ADDRESS BUS
    logic  [ID_WIDTH-1:0]    awid;
    logic  [ADDR_WIDTH-1:0]  awaddr;
    logic  [7:0]             awlen;
    logic  [2:0]             awsize;
    logic  [1:0]             awburst;
    logic                    awlock;
    logic  [3:0]             awcache;
    logic  [2:0]             awprot;
    logic                    awvalid;
    logic                    awready;
    
    //WRITE DATA BUS
    logic  [DATA_WIDTH-1:0]  wdata;
    logic  [STRB_WIDTH-1:0]  wstrb;
    logic                    wlast;
    logic                    wvalid;
    logic                    wready;
    
    //WRITE RESPONSE BUS
    logic  [ID_WIDTH-1:0]    bid;
    logic  [1:0]             bresp;
    logic                    bvalid;
    logic                    bready;
    
    //READ ADDRESS BUS
    logic  [ID_WIDTH-1:0]    arid;
    logic  [ADDR_WIDTH-1:0]  araddr;
    logic  [7:0]             arlen;
    logic  [2:0]             arsize;
    logic  [1:0]             arburst;
    logic                    arlock;
    logic  [3:0]             arcache;
    logic  [2:0]             arprot;
    logic                    arvalid;
    logic                    arready;
    
    //READ DATA BUS
    logic  [ID_WIDTH-1:0]    rid;
    logic  [DATA_WIDTH-1:0]  rdata;
    logic  [1:0]             rresp;
    logic                    rlast;
    logic                    rvalid;
    logic                    rready;

    clocking driver_cb@(posedge clk);

       
      //WRITE ADDRESS BUS
      input awready;
      output awid,awaddr,awlen,awsize,awburst,awvalid,awcache,awprot,awlock;

      //WRITE DATA BUS
      input wready;
      output wdata,wstrb,wlast,wvalid;
       
      //WRITE RESPONSE BUS
      input bid,bresp,bvalid;
      output bready;

      //READ ADDRESS BUS
      input arready;
      output arid,araddr,arlen,arsize,arburst,arvalid,arcache,arprot,arlock;
       
      //READ DATA BUS
      input rid,rdata,rresp,rlast,rvalid;
      output rready;

    endclocking

    modport driver_mp(clocking driver_cb,input clk,reset);

   clocking monitor_cb@(posedge clk);

      //default input #9;
       
      //WRITE ADDRESS BUS
      input awready;
      input awid,awaddr,awlen,awsize,awburst,awvalid,awcache,awprot,awlock;

      //WRITE DATA BUS
      input wready;
      input wdata,wstrb,wlast,wvalid;
       
      //WRITE RESPONSE BUS
      input bid,bresp,bvalid;
      input bready;

      //READ ADDRESS BUS
      input arready;
      input arid,araddr,arlen,arsize,arburst,arvalid,arcache,arprot,arlock;
       
      //READ DATA BUS
      input rid,rdata,rresp,rlast,rvalid;
      input rready;

    endclocking

    modport monitor_mp(clocking monitor_cb,input clk,reset);



    //---------------------------------------------------------------------//
    //          ASSERTIONS --> AWREADY && AWVALID                          //
    //---------------------------------------------------------------------//
    property awready_awvalid;
       @(posedge clk) disable iff(reset==1) awvalid |-> ##[0:2]awready;
    endproperty

    assertion1:assert property (awready_awvalid) begin
               `uvm_info("*** ASSERTION PASSED *** - AWREADY && AWVALID","",UVM_HIGH);
            end 
            else begin
              `uvm_info("ASSERTION FAILED - AWREADY && AWVALID","",UVM_NONE);
            end
         
    //---------------------------------------------------------------------//
    //          ASSERTIONS --> WREADY && WVALID                            //
    //---------------------------------------------------------------------//
    property wready_wvalid;
       @(posedge clk) disable iff(reset==1) wvalid |-> ##[0:2]wready;
    endproperty

    assertion2:assert property (wready_wvalid) begin
               `uvm_info("*** ASSERTION PASSED *** - WREADY && WVALID","",UVM_HIGH);
            end 
            else begin
              `uvm_info("ASSERTION FAILED - WREADY && WVALID","",UVM_NONE);
            end
         
    //---------------------------------------------------------------------//
    //          ASSERTIONS --> BREADY && BVALD                             //
    //---------------------------------------------------------------------//
    property bready_bvalid;
       @(posedge clk) disable iff(reset==1) bvalid |-> ##[0:2]bready;
    endproperty

    assertion3:assert property (bready_bvalid) begin
               `uvm_info("*** ASSERTION PASSED *** - BREADY && BVALID","",UVM_HIGH);
            end 
            else begin
              `uvm_info("ASSERTION FAILED - BREADY && BVALID","",UVM_NONE);
            end
         
    //---------------------------------------------------------------------//
    //          ASSERTIONS --> ARREADY && ARVALD                           //
    //---------------------------------------------------------------------//
    property arready_arvalid;
       @(posedge clk) disable iff(reset==1) arvalid |-> ##[0:2]arready;
    endproperty

    assertion4:assert property (arready_arvalid) begin
               `uvm_info("*** ASSERTION PASSED *** - ARREADY && ARVALID","",UVM_HIGH);
            end 
            else begin
              `uvm_info("ASSERTION FAILED - ARREADY && ARVALID","",UVM_NONE);
            end
         
    //---------------------------------------------------------------------//
    //          ASSERTIONS --> RREADY && RVALID                            //
    //---------------------------------------------------------------------//
    property rready_rvalid;
       @(posedge clk) disable iff(reset==1) rready |-> ##[0:2]rvalid;
    endproperty

    assertion5:assert property (rready_rvalid) begin
               `uvm_info("*** ASSERTION PASSED *** - RREADY && RVALID","",UVM_HIGH);
            end 
            else begin
              `uvm_info("ASSERTION FAILED - RREADY && RVALID","",UVM_NONE);
            end
         

endinterface






`endif
