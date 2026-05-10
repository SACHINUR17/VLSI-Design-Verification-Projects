class axi_m_Sequence_Item#(int WIDTH=32,SIZE=3) extends uvm_sequence_item ;
  rand bit RW;
  // ADDRESS WRITE CHANNEL
  logic		AWREADY;
  logic		AWVALID;
  rand logic	[SIZE-2:0]      AWBURST;
  rand logic	[SIZE-1:0]      AWSIZE;
  rand logic	[(WIDTH/8)-1:0] AWLEN;
  rand logic	[WIDTH-1:0]	    AWADDR;
  rand logic	[(WIDTH/8)-1:0] AWID;
//  logic         [SIZE:0]      AWQOS;
//  logic         [SIZE:0]      AWCACHE;
//  logic         [SIZE-2:0]    AWLOCK;
//  logic         [SIZE:0]      AWREG;
//  logic         [SIZE-1:0]    AWPROT;


  // DATA WRITE CHANNEL
  logic		WREADY;
  logic		WVALID;
  logic		WLAST;
  rand logic	[(WIDTH/8)-1:0]  WSTRB [] ;
  rand logic 	[7:0]	         WDATA [] ;
  rand logic	[(WIDTH/8)-1:0]  WID;

  // WRITE RESPONSE CHANNEL
  logic	[(WIDTH/8)-1:0]  BID;
  logic	[SIZE-2:0]       BRESP;
  logic		BVALID;
  logic		BREADY;

  // READ ADDRESS CHANNEL
  logic		ARREADY;
  logic		ARVALID;
  rand logic	[(WIDTH/8)-1:0]  ARID;
  rand logic	[WIDTH-1:0]      ARADDR;
  rand logic	[(WIDTH/8)-1:0]  ARLEN;
  rand logic	[SIZE-1:0]       ARSIZE;
  rand logic	[SIZE-2:0]       ARBURST;

//  logic         [SIZE:0]     ARQOS;
//  logic         [SIZE:0]     ARCACHE;
//  logic         [SIZE-2:0]   ARLOCK;
//  logic         [SIZE:0]     ARREG;
//  logic         [SIZE-1:0]   ARPROT;

  // READ DATA CHANNEL
  rand logic	[(WIDTH/8)-1:0]  RID;
  rand logic	[7:0]	         RDATA [];
  logic	        [SIZE-2:0]       RRESP;
  logic	        RLAST;
  logic	        RVALID;
  logic	        RREADY;

  constraint same_id_wr  {AWID==WID;}
  constraint arr_size_wr {if (!RW && AWBURST!=2'b10) {WDATA.size() inside {[1:(16*(2**AWSIZE))]};} } //support 1 to 16 AWLEN so max size is 16*(2**AWSIZE)
  constraint awsize   {if     (WIDTH/8==1)   AWSIZE==0; //   \
                       else if(WIDTH/8==2)   AWSIZE==1; //    \
                       else if(WIDTH/8==4)   AWSIZE==2; //     \
                       else if(WIDTH/8==8)   AWSIZE==3; //      \ __  in the 2 res to format..
                       else if(WIDTH/8==16)  AWSIZE==4; //      /
                       else if(WIDTH/8==32)  AWSIZE==5; //     /
                       else if(WIDTH/8==64)  AWSIZE==6; //    /
                       else if(WIDTH/8==128) AWSIZE==7; //   /
                      }
  constraint arsize   {if     (WIDTH/8==1)   ARSIZE==0; //   \
                       else if(WIDTH/8==2)   ARSIZE==1; //    \
                       else if(WIDTH/8==4)   ARSIZE==2; //     \
                       else if(WIDTH/8==8)   ARSIZE==3; //      \ __  in the 2 res to format..
                       else if(WIDTH/8==16)  ARSIZE==4; //      /
                       else if(WIDTH/8==32)  ARSIZE==5; //     /
                       else if(WIDTH/8==64)  ARSIZE==6; //    /
                       else if(WIDTH/8==128) ARSIZE==7; //   /
                      }  
    constraint order       {solve AWSIZE before WDATA.size() ;} 
    constraint awburst_val {if (!RW && AWBURST==2'b10) {WDATA.size() inside {((2**AWSIZE)*2),((2**AWSIZE)*4),((2**AWSIZE)*8),((2**AWSIZE)*16)}; }}
  constraint arburst_val {if (ARBURST==2'b10) {ARLEN inside {1,3,7,15};}}
  //constraint awlen_val   {if (AWBURST==2'b00 || AWBURST == 2'b01) {if ((WDATA.size()%(2**AWSIZE))== 00) {AWLEN == (WDATA.size/(2**AWSIZE))-1;} 
    //                                                      else if ((WDATA.size()%(2**AWSIZE))!= 00) {AWLEN == (WDATA.size/(2**AWSIZE));}}}
  constraint awlen_val   {AWLEN==0;}                                                          
  constraint arlen_val   {ARLEN inside {[0:15]};}
  constraint awburst     {AWBURST inside {0,1,2};/*AWBURST != 2'b11;*/ AWBURST dist {2'b00:/10 , 2'b01:/60 , 2'b10:/30};}
  constraint arburst     {ARBURST inside {0,1,2};/*ARBURST != 2'b11;*/ ARBURST dist {2'b00:/10 , 2'b01:/60 , 2'b10:/30};}
  constraint awaddress   {AWADDR < 50;}
  constraint araddress   {ARADDR < 50;} 
  //constraint Strobe      {if (!RW) {WSTRB.size()==AWLEN+1;}  foreach (WSTRB[i]) {WSTRB[i] == 00;}} 
 

  `uvm_object_param_utils_begin(axi_m_Sequence_Item#(WIDTH,SIZE))
    `uvm_field_int(AWREADY,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(AWVALID,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(RW,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_int(AWBURST,UVM_ALL_ON)
    `uvm_field_int(AWSIZE,UVM_ALL_ON)
    `uvm_field_int(AWLEN,UVM_ALL_ON)
    `uvm_field_int(AWADDR,UVM_ALL_ON)
    `uvm_field_int(AWID,UVM_ALL_ON)
    `uvm_field_int(WREADY,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(WVALID,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(WLAST,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_array_int(WSTRB,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_array_int(WDATA,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_int(WID,UVM_ALL_ON)
    `uvm_field_int(BID,UVM_ALL_ON)
    `uvm_field_int(BRESP,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_int(BVALID,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(BREADY,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(ARREADY,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(ARVALID,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(ARBURST,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_int(ARSIZE,UVM_ALL_ON)
    `uvm_field_int(ARLEN,UVM_ALL_ON)
    `uvm_field_int(ARADDR,UVM_ALL_ON)
    `uvm_field_int(ARID,UVM_ALL_ON)
    `uvm_field_int(RREADY,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(RVALID,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(RLAST,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE)
    `uvm_field_int(RRESP,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_array_int(RDATA,UVM_ALL_ON|UVM_NOCOMPARE)
    `uvm_field_int(RID,UVM_ALL_ON)
  `uvm_object_utils_end 

  function new(string name = "axi_m_Sequence_Item");
    super.new(name);
  endfunction
 
endclass
