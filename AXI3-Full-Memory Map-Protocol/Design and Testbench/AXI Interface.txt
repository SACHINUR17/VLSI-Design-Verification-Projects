/* AXI Interface                                                    */

`timescale 1ns/1ps
typedef enum {OKAY,EXOKAY, SLVERR, DECERR} axi_resp_e;
typedef enum {FIXED, INCR, WRAP, RESERVED} burst_type_e;
typedef enum {BYTE1,BYTE2, BYTE4, BYTE8, BYTE16, BYTE32, BYTE64, BYTE128} burst_size_e;
typedef enum {TFR1=1,TFRS2, TRFS3, TRFS4, TFRS5, TFRS6, TFRS7, TFRS8, TFRS9, TFRS10, TFRS11, TFRS12, TFRS13, TFRS14, TFRS15 } burst_len_e;
typedef enum {NORMAL, EXCLUSIVE, LOCKED, RESERVED_LOCK} lock_type_e;
//Above Enum can be defined for cache, prot

interface axi_if(input logic aclk, input logic aresetn);
  logic [3:0]   awid;
  logic [31:0]  awaddr;
  burst_len_e   awlen;      //logic [3:0]   awlen;
  burst_size_e  awsize;     //logic [2:0]   awsize;
  burst_type_e  awburst;    //logic [1:0]   awburst;
  lock_type_e   awlock;     //logic [1:0]   awlock;
  logic [3:0]   awcache;
  logic [2:0]   awprot;
  logic         awvalid;
  logic         awready;

  logic [3:0]   wid;
  logic [31:0]   wdata;
  logic [3:0]   wstrb;
  logic         wlast;
  logic         wvalid;
  logic         wready;

  logic [3:0]   bid;
  logic [1:0]    bresp;    //logic [1:0]   bresp;
  logic         bvalid;
  logic         bready;

  logic [3:0]   arid;
  logic [31:0]  araddr;
  burst_len_e   arlen;      //logic [3:0]   arlen;
  burst_size_e  arsize;     //logic [2:0]   arsize;
  burst_type_e  arburst;    //logic [1:0]   arburst;
  lock_type_e   arlock;     //logic [1:0]   arlock;
  logic [3:0]   arcache;
  logic [2:0]   arprot;
  logic         arvalid;
  logic         arready;

  logic [3:0]   rid;
  logic [31:0]  rdata;
  logic         rlast;
  logic         rvalid;
  logic         rready;
  logic [1:0]    rresp;    //logic [1:0]   rresp;

  modport bfm (
  output  awid,
  output  awaddr,
  output  awlen,
  output  awsize,
  output  awburst,
  output  awlock,
  output  awcache,
  output  awprot,
  output  awvalid,
  input   awready,

  output  wid,
  output  wdata,
  output  wstrb,
  output  wlast,
  output  wvalid,
  input   wready,

  input   bid,
  input   bresp,
  input   bvalid,
  output  bready,

  output  arid,
  output  araddr,
  output  arlen,
  output  arsize,
  output  arburst,
  output  arlock,
  output  arcache,
  output  arprot,
  output  arvalid,
  input   arready,

  input  rid,
  input   rdata,
  input   rlast,
  input   rvalid,
  output  rready,
  input   rresp
  );

  modport dut (
  input  awid,
  input  awaddr,
  input  awlen,
  input  awsize,
  input  awburst,
  input  awlock,
  input  awcache,
  input  awprot,
  input  awvalid,
  output awready,

  input  wid,
  input  wdata,
  input  wstrb,
  input  wlast,
  input  wvalid,
  output   wready,

  output   bid,
  output   bresp,
  output   bvalid,
  input   bready,

  input   arid,
  input   araddr,
  input   arlen,
  input   arsize,
  input   arburst,
  input   arlock,
  input   arcache,
  input   arprot,
  input   arvalid,
  output   arready,

  output  rid,
  output   rdata,
  output   rlast,
  output   rvalid,
  input   rready,
  output   rresp
  );

  modport mon (
    input  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awvalid, awready, wid, wdata, wstrb, wlast, wvalid, wready, bid, bresp, bvalid, bready, arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arvalid, arready, rid, rdata, rlast, rvalid, rready, rresp
  );

  clocking axi_cb @(posedge aclk);
    default input #2 output #4ps;
    //output negedge awid;
    //output #10 awaddr;
    //output ##1Step awaddr, araddr;

  output  awid, awaddr, awlen, awsize, awburst, awlock, awcache, awprot, awvalid;
  input   awready;
  output  wid, wdata, wstrb, wlast, wvalid;
  input   wready;

  input   bid, bresp, bvalid;
  output  bready;

  output  arid, araddr, arlen, arsize, arburst, arlock, arcache, arprot, arvalid;
  input   arready;

  input  rid;
  input   rdata;
  input   rlast;
  input   rvalid;
  output  rready;
  input   rresp;
  endclocking
endinterface: axi_if
