`include "ahb_macros.svh"

interface ahb_if(input logic hclk, input logic hreset_n);
  
  // master signals
  logic [`AHB_AWIDTH -1 : 0] haddr;  // system address bus
  logic [2:0] hburst;  // burst type
  logic hmastlock;     // locked transfer
  logic [3:0] hprot;   // protection control
  logic [2:0] hsize;   // transfer size
  logic [1:0] htrans;  // transfer type
  logic [`AHB_DWIDTH -1 : 0] hwdata; // write data bus
  logic hwrite;

  // slave signals
  logic [`AHB_DWIDTH -1 : 0] hrdata; // read data bus
  logic hready;        // ready
  logic hresp;         // transfer status
  
  // decoder signals
  logic hsel;          // slave select
  
  // master driver modport
  modport mst (
    input  hclk, hreset_n,
    output haddr, hburst, hmastlock,
           hprot, hsize, htrans, 
           hwdata, hwrite,
    output hsel, // TODO: from master for now
    input  hrdata, hready, hresp
  );
  
  // slave driver modport
  modport slv (
    input  hclk, hreset_n,
    input  haddr, hburst, hmastlock,
           hprot, hsize, htrans, 
           hwdata, hwrite,
    input  hsel,
    output hrdata, hready, hresp
  );

  // monitor modport 
  modport mon (
    input  hclk, hreset_n,
    input  haddr, hburst, hmastlock,
           hprot, hsize, htrans, 
           hwdata, hwrite,
    input  hsel,
    input  hrdata, hready, hresp
  );

endinterface // ahb_if
