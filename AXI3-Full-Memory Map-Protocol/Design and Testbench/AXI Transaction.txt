/* AXI Transaction                                  */

//typedef enum {OKAY,EXOKAY, SLVERR, DECERR} axi_resp_e;
//typedef enum {FIXED, INCR, WRAP, RESERVED} burst_type_e;
//typedef enum {1BYTE,2BYTE, 4BYTE, 8BYTE, 16BYTE, 32BYTE, 64BYTE, 128BYTE} burst_size_e;
//typedef enum {1TFR=1,2TFRS, 3TRFS, 4TRFS, 5TFRS, 6TFRS, 7TFRS, 8TFRS, 9TFRS, 10TFRS, 11TFRS, 12TFRS, 13TFRS, 14TFRS, 15TFRS } burst_len_e;
//typedef enum {NORMAL, EXCLUSIVE, LOCKED, RESERVED} lock_type_e;
typedef enum {READ, WRITE, READ_WRITE} wr_rd_e;
//Above Enum can be defined for cache, prot

class axi_transaction; //Signals in transaction need not be same as interface signals
  rand time tx_delay; //Tx0 = 0ns, Tx1 = 10ns, Tx2 = 25ns
  rand wr_rd_e       wr_rd;	
  rand bit [3:0]   awid;
  rand bit [31:0]  awaddr;
  rand bit [3:0]   awlen;      //logic [3:0]   awlen;
  rand bit [2:0]  awsize;     //logic [2:0]   awsize;
  rand bit [1:0]  awburst;    //logic [1:0]   awburst;
  rand bit [1:0]   awlock;     //logic [1:0]   awlock;
  rand bit [3:0]   awcache;
  rand bit [2:0]   awprot;

  rand bit [3:0]   wid;
  //rand bit [31:0]   wdata []; //It need to be of size of awlen, queue
  rand bit [31:0] wdata [$:16];
  rand bit [3:0]   wstrb [$:16];
       bit [1:0]   bresp;


  rand bit [3:0]   arid;
  rand bit [31:0]  araddr;
  rand bit [3:0]   arlen;      //logic [3:0]   arlen;
  rand bit [2:0]  arsize;     //logic [2:0]   arsize;
  rand bit [1:0]  arburst;    //logic [1:0]   arburst;
  rand bit [1:0]   arlock;     //logic [1:0]   arlock;
  randc bit [3:0]   arcache; //if I generate axi_tx 16 times, It will generate all 16 patterns(randc ensures that)
  rand bit [2:0]   arprot;
       bit [3:0]   rid;
       bit [1:0]   rresp[$:16];
  //rand    bit [31:0]   rdata []; //It need to be of size of awlen
  rand    bit [31:0]   rdata [$:16]; //It need to be of size of awlen

  function new();
    $display("axi_transaction : new");
  endfunction

  function void copy(output axi_transaction tx);
	  tx = new();
  	  tx.wr_rd = this.wr_rd;	
  	  tx.awid = this.awid;	
  	  tx.awaddr = this.awaddr;	
  	  tx.awlen = this.awlen;	
  	  tx.awsize = this.awsize;	
  	  tx.awburst = this.awburst;	
  	  tx.awlock = this.awlock;	
  	  tx.awcache = this.awcache;	
  	  tx.awprot = this.awprot;	
  	  tx.wid = this.wid;	
	  //tx.wdata = new[this.wdata.size()];
	  tx.wdata = this.wdata;
	  //tx.wstrb = new[this.wstrb.size()];
	  tx.wstrb = this.wstrb;
  	  tx.bresp = this.bresp;	
  	  tx.arid = this.arid;	
  	  tx.araddr = this.araddr;	
  	  tx.arlen = this.arlen;	
  	  tx.arsize = this.arsize;	
  	  tx.arburst = this.arburst;	
  	  tx.arlock = this.arlock;	
  	  tx.arcache = this.arcache;	
  	  tx.arprot = this.arprot;	
  	  tx.rid = this.rid;	
	  tx.rresp = new[this.rresp.size()];
	  tx.rresp = this.rresp;
	  //tx.rdata = new[this.rdata.size()];
	  tx.rdata = this.rdata;
  endfunction

  function void print();
	  $display("Printing axi_tx contents");
	  $display("tx_delay = %h", tx_delay);
	  $display("wr_rd = %h", wr_rd);
	  if (wr_rd == 1'b1) begin
	  	$display("awaddr = %h", awaddr);
	  	$display("awid = %h", awid);
	  	$display("awlen = %h", awlen);
	  	$display("awburst = %h", awburst);
	  	$display("awsize = %h", awsize);
	  	foreach (wdata[i]) $display("wdata[%d] = %h", i, wdata[i]);
	  	foreach (wstrb[i]) $display("wstrb[%d] = %h", i, wstrb[i]);
  	  end
	  else begin
	  	$display("araddr = %h", araddr);
	  	$display("arid = %h", arid);
	  	$display("arlen = %h", arlen);
	  	$display("arburst = %h", arburst);
	  	$display("arsize = %h", arsize);
	  	foreach (rdata[i]) $display("rdata[%d] = %h", i, rdata[i]);
	  	foreach (rresp[i]) $display("rresp[%d] = %h", i, rresp[i]);
	  end
  endfunction

  constraint wr_rd_c {
	  //wr_rd == WRITE;
	  //wr_rd inside { READ};
	  //wr_rd inside { WRITE, READ, WRITE_READ};
	  wr_rd inside { WRITE, READ};
  };

  constraint tx_delay_c {
	  tx_delay < 10; tx_delay > 2;
  };

  constraint wstrb_size_c {
	  wstrb.size() == awlen+1;
  };

  constraint wdata_size_c {
	  wdata.size() == awlen+1;
  };
  constraint rdata_size_c {
	  rdata.size() == arlen+1;
  };

 /* constraint id_c {
	  awid == 1;
	  wid == 1;
	  arid == 1;
  }; */
  constraint id_c1 {
	  awid <= 10;
	  wid <= 10;
	  arid <= 10;
	  wid == awid;
  };
  constraint burst_type_c {
	  awburst == 2'b00; //inside {INCR, FIXED, WRAP};
	  arburst == 2'b00; //inside {INCR, FIXED, WRAP};
  };
  constraint lock_type_c {
	  awlock == 2'b00; //NORMAL;
	  arlock == 2'b00; //NORMAL;
  };
endclass
