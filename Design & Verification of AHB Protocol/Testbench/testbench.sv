`define HCLK_PERIOD 10

module testbench;
  timeunit 1ns;
  timeprecision 1ps;
  
  import uvm_pkg::*;
  import vutils_pkg::*;
  
  `include "ahb_test.svh"
  
  
  // ahb global signals
  logic hclk, hreset_n;
  
  ahb_if i_ahb_if(hclk, hreset_n);
  
  
  initial begin
    hclk = FALSE;

    forever #(`HCLK_PERIOD /2) hclk = ~hclk;
  end // initial
  
  `ifdef DUMP_VCD
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end // initial
  `endif // DUMP_VCD
  
  
  //program tb_pgm;
    // assert and release reset
    initial begin
      $timeformat(-9, 3, " ns", 10);

      hreset_n = FALSE;
      repeat(5) begin
        @(posedge hclk);
      end // repeat
      @(negedge hclk);
      hreset_n = TRUE;
      `info("released reset ...", "tb")
    end // initial


    initial begin
      uvm_config_db#(virtual ahb_if)::set(null, "uvm_test_top.*", "vif", i_ahb_if);
      run_test();  // run selected UVM_TESTNAME
    end // initial
  //endprogram // tb_pgm

endmodule // testbench
  
  
