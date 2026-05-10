interface axi_intf#(int WIDTH=32,SIZE=3)(input bit clk,RESET);
  // WRITE ADDRESS CHANNEL
  logic		            AWREADY;
  logic		            AWVALID;
  logic	[SIZE-2:0]	    AWBURST;
  logic	[SIZE-1:0]	    AWSIZE;
  logic	[(WIDTH/8)-1:0]	AWLEN;
  logic	[WIDTH-1:0]	    AWADDR;
  logic	[(WIDTH/8)-1:0]	AWID;
  //logic [SIZE:0]        AWCACHE;
  //logic [SIZE:0]        AWQOS;
  //logic [SIZE-2:0]      AWLOCK;
  //logic [SIZE:0]        AWREG;
  //logic [SIZE-1:0]      AWPROT;

  // DATA WRITE CHANNEL
  logic		            WREADY;
  logic		            WVALID;
  logic		            WLAST;
  logic	[(WIDTH/8)-1:0]	WSTRB;
  logic	[WIDTH-1:0]	    WDATA;
  logic	[(WIDTH/8)-1:0]	WID;

  // WRITE RESPONSE CHANNEL
  logic	[(WIDTH/8)-1:0]	BID;
  logic	[SIZE-2:0]	    BRESP;
  logic		            BVALID;
  logic		            BREADY;

  // READ ADDRESS CHANNEL
  logic		            ARVALID;
  logic		            ARREADY;
  logic	[(WIDTH/8)-1:0]	ARID;
  logic	[WIDTH-1:0]	    ARADDR;
  logic	[(WIDTH/8)-1:0]	ARLEN;
  logic	[SIZE-1:0]	    ARSIZE;
  logic	[SIZE-2:0]	    ARBURST;
  //logic [SIZE:0]        ARCACHE;
  //logic [SIZE:0]        ARQOS;
  //logic [SIZE-2:0]      ARLOCK;
  //logic [SIZE:0]        ARREG;
  //logic [SIZE-1:0]      ARPROT;


  // READ DATA CHANNEL
  logic	[(WIDTH/8)-1:0]	RID;
  logic	[WIDTH-1:0]	    RDATA;
  logic	[SIZE-2:0]	    RRESP;
  logic		            RLAST;
  logic		            RVALID;
  logic		            RREADY;

  int i,j,r_counter, w_counter,que_WLEN [$],que_RLEN [$];

//################ ADDRESS WRITE CHANNEL##############//
   
  property AXI_AWVALID_AWREADY;  //When AWVALID is asserted then it remains asserted until AWREADY is HIGH
    @(posedge clk) AWVALID |-> (AWVALID throughout (AWREADY[->1]));
  //  @(posedge clk) $rose(AWVALID)|->(AWVALID throughout (AWREADY[->1])) |=> (AWVALID && AWREADY);
  //  @(posedge clk) ($onehot(AWVALID) && $onehot(AWREADY)) |=> ($onehot(AWVALID) && $onehot(AWREADY));
  endproperty

  property w_burst_boundary;  //BURST can not cross a 4KB Boundary
    @(posedge clk) (AWVALID&&AWREADY) |-> (((2**AWSIZE)*(AWLEN+1)) < 4096) ;
  endproperty 

  property AXI_AWVALID_STABLE;  //AW channels var are stable
    @(posedge clk) AWVALID throughout (AWREADY[->1]) |-> ($stable(AWADDR) && $stable(AWBURST) && $stable(AWLEN) && $stable(AWID) && $stable(AWSIZE));
    //@(posedge clk) (AWVALID && AWREADY) |-> ($stable(AWADDR) && $stable(AWBURST) && $stable(AWLEN) && $stable(AWID) && $stable(AWSIZE)); 
    //@(posedge clk) (AWVALID && AWREADY) |-> ($past(AWADDR,1)==AWADDR && $past(AWBURST,1)==AWBURST && $past(AWLEN,1)==AWLEN && $past(AWID,1)==AWID && $past(AWSIZE,1)==AWSIZE); 
  endproperty

  property AWLEN_WRAP_BURST; //AWLEN value is 1,3,7,15 for Wrapping type Burst
    @(posedge clk) disable iff (!RESET) (AWBURST==2'b10) |-> (AWLEN==1 || AWLEN==3 || AWLEN==7 || AWLEN==15);
  endproperty

  property AWBURST_CANT_2b11; //AWBURST val cant be 2'b11
    @(posedge clk) (AWVALID&&AWREADY) |-> (AWBURST != 2'b11);
  endproperty

  awvalid_and_awready:assert property (AXI_AWVALID_AWREADY) que_WLEN.push_back(AWLEN); 
     else `uvm_error("ASSERTION","Failure AXI_AWVALID_AWREADY");

  write_burst_boundary:assert property (w_burst_boundary)
     else  `uvm_error("ASSERTION","Failure w_burst_boundary");

  awvar_are_stable:assert property (AXI_AWVALID_STABLE)
     else  `uvm_error("ASSERTION","Failure AXI_AWVALID_STABLE");

  wlen_val_for_wrapping_burst:assert property (AWLEN_WRAP_BURST)
     else  `uvm_error("ASSERTION","Failure AWLEN_WRAP_BURST");

  awburst_val_cant_be_2b11:assert property (AWBURST_CANT_2b11)
     else  `uvm_error("ASSERTION","Failure AWBURST_CANT_2b11");

//################ DATA WRITE CHANNEL##############//

  property AXI_WVALID_WREADY;
  @(posedge clk) WVALID |-> (WVALID throughout (WREADY[->1])) ;
  endproperty

  property AXI_WVALID_STABLE;  //W channels var are stable
    @(posedge clk) WVALID throughout (WREADY[->1]) |-> ($stable(WSTRB) && $stable(WDATA) && $stable(WID) ); 
  endproperty

 /* property detect_WLAST(int value);
    int counter=0;
    @(posedge clk) (((WVALID && WREADY),counter=value) |-> (counter==que_WLEN[i])? WLAST : !WLAST);
    //@(posedge clk) ((AWVALID && AWREADY)[=que_WLEN[i]]) |-> WLAST ;
  endproperty
*/
  wvalid_and_wready:assert property (AXI_WVALID_WREADY)  
     else `uvm_error("ASSERTION","Failure AXI_WVALID_WREADY");

  wvar_are_stable:assert property (AXI_WVALID_STABLE)
     else  `uvm_error("ASSERTION","Failure AXI_WVALID_STABLE");

/*  detect_wlast:assert property (detect_WLAST(w_counter)) begin if (w_counter==que_WLEN[i]) begin i=i+2; w_counter=0; end else w_counter++; end
     else  `uvm_error("ASSERTION","Failure detect_WLAST ");
*/
//################ RESPONSE WRITE CHANNEL##############//

  property AXI_BVALID_BREADY;
  @(posedge clk) BVALID|-> (BVALID throughout (BREADY[->1])) ;
  endproperty

  property AXI_BVALID_STABLE;  //B channels var are stable
    @(posedge clk) (BVALID throughout (BREADY[->1])) |-> ($stable(BRESP) && $stable(BID) ); 
  endproperty

  bvalid_and_bready:assert property (AXI_BVALID_BREADY)  
     else `uvm_error("ASSERTION","Failure AXI_BVALID_BREADY");

  bvar_are_stable:assert property (AXI_BVALID_STABLE)
     else  `uvm_error("ASSERTION","Failure AXI_BVALID_STABLE");

//################ ADDRESS READ CHANNEL##############//

  property AXI_ARVALID_ARREADY;
  @(posedge clk) ARVALID |-> (ARVALID throughout (ARREADY[->1])) ;
  endproperty

  property r_burst_boubadary;  //BURST can not cross a 4KB Boundary
  @(posedge clk) (ARVALID&&ARREADY) |-> (((2**ARSIZE)*(ARLEN+1)) < 4096);
  endproperty

  property ARLEN_WRAP_BURST; //ARLEN value is 1,3,7,15 for Wrapping type Burst
    @(posedge clk) disable iff (!RESET) (ARBURST==2'b10) |-> (ARLEN==1 || ARLEN==3 || ARLEN==7 || ARLEN==15);
  endproperty

  property ARBURST_CANT_2b11; //ARBURST val cant be 2'b11
    @(posedge clk) (ARVALID&&ARREADY) |-> (ARBURST != 2'b11);
  endproperty

  property AXI_ARVALID_STABLE;  //AR channels var are stable
    @(posedge clk) (ARVALID throughout (ARREADY[->1])) |-> ($stable(ARADDR) && $stable(ARBURST) && $stable(ARLEN) && $stable(ARID) && $stable(ARSIZE)); 
  endproperty

  arvalid_and_arready:assert property (AXI_ARVALID_ARREADY) que_RLEN.push_back(ARLEN); 
     else `uvm_error("ASSERTION","Failure AXI_ARVALID_ARREADY");

  read_burst_boundary:assert property (r_burst_boubadary)
     else  `uvm_error("ASSERTION","Failure r_burst_boubadary");

  rlen_val_for_wrapping_burst:assert property (ARLEN_WRAP_BURST)
     else  `uvm_error("ASSERTION","Failure ARLEN_WRAP_BURST");

  arburst_val_cant_be_2b11:assert property (ARBURST_CANT_2b11)
     else  `uvm_error("ASSERTION","Failure ARBURST_CANT_2b11");

  arvar_are_stable:assert property (AXI_ARVALID_STABLE)
     else  `uvm_error("ASSERTION","Failure AXI_ARVALID_STABLE");

//################ DATA READ CHANNEL##############//

  property AXI_RVALID_RREADY;
  @(posedge clk) RVALID |-> (RVALID throughout (RREADY[->1])); 
  endproperty

  property AXI_RVALID_STABLE;  //R channels var are stable
    @(posedge clk) (RVALID throughout (RREADY[->1])) |-> ($stable(RRESP) && $stable(RDATA) && $stable(RID) ); 
  endproperty

/*  property detect_RLAST(int value);
    int counter=0;
    @(posedge clk) (((RVALID && RREADY),counter=value) |-> (counter==que_RLEN[j])? RLAST : !RLAST);
  endproperty
*/
  rvalid_and_rready:assert property (AXI_RVALID_RREADY)  
     else `uvm_error("ASSERTION","Failure AXI_RVALID_RREADY");

  rvar_are_stable:assert property (AXI_RVALID_STABLE)
     else  `uvm_error("ASSERTION","Failure AXI_RVALID_STABLE");

/*  detect_rlast:assert property (detect_RLAST(r_counter)) begin if (r_counter==que_RLEN[j]) begin j=j+1; r_counter=0; end else r_counter++; end
     else  `uvm_error("ASSERTION","Failure detect_RLAST ");
*/
endinterface
