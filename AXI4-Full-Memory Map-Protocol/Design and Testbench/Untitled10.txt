

package env_pkg;

   parameter ID_WIDTH   = 4;
   parameter ADDR_WIDTH = 32;
   parameter LEN_WIDTH  = 8;
   parameter SIZE_WIDTH = 3;
   parameter DATA_WIDTH = 64; 

    import  uvm_pkg :: *;
   `include "uvm_macros.svh"
   `include "config_obj.sv"
   `include "w_seq_item.sv"
   `include "r_seq_item.sv"
   `include "c_seq_item.sv"
   `include "w_driver.sv"
   `include "r_driver.sv"
   `include "c_driver.sv"
   `include "w_monitor.sv"
   `include "r_monitor.sv"
   `include "c_monitor.sv"
   `include "w_seqr.sv"
   `include "r_seqr.sv"
   `include "c_seqr.sv"
   `include "virtual_seqr.sv"
   `include "w_agent.sv"
   `include "r_agent.sv"
   `include "c_agent.sv"
   `include "scoreboard.sv"
   `include "coverage.sv"
   `include "write_sequence_lib.sv"
   `include "read_sequence_lib.sv"
   `include "control_sequence_lib.sv"
   `include "virtual_seq.sv"
   `include "env.sv"
   `include "test.sv"

endpackage : env_pkg
