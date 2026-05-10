/* AXI Transaction                                  */

`timescale 1ns/1ns
class axi_tx_resp;
  logic [3:0]   bid;
  logic [1:0]    bresp;    //logic [1:0]   bresp;
  logic [3:0]   rid;
  logic [31:0]  rdata[];
  logic [1:0]    rresp[];    //logic [1:0]   rresp;

  function print();
    $display("bid = %h", bid);
    $display("bid = %h", bresp);
    $display("bid = %h", rid);
  endfunction
endclass

