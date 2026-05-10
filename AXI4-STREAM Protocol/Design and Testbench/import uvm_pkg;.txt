import uvm_pkg::*;

class axi_streaming_transaction_c#(parameter DATA_WIDTH = 64) extends uvm_sequence_item;

typedef enum {NO_DEALY, MIN_DELAY, MID_DELAY, MAX_DELAY, RAND_DEALY} mode;

bit [(DATA_WIDTH - 1):0] tdata[];
int unsigned tvalid_delay ;
int unsigned tready_delay ;
rand bit [7:0] tid_v;
rand mode Mode;

constraint delay {
                  if (Mode == NO_DEALY)
                    {
                      tvalid_delay == 0;
                      tready_delay == 0;
                    }
                  if (Mode == MIN_DELAY)
                    {
                      tvalid_delay inside {[1:7]};
                      tready_delay inside {[1:7]};
                    }
                  if (Mode == MID_DELAY) // Mid delay
                    {
                      tvalid_delay inside {[8:20]};
                      tready_delay inside {[8:20]};
                    }
                  if (Mode == MAX_DELAY) // Max delay
                    {
                      tvalid_delay inside {[21:32]};
                      tready_delay inside {[21:32]};
                    }
                  if (Mode == RAND_DEALY) // Random delay
                    {
                      tvalid_delay inside {[33:100]};
                      tready_delay inside {[33:100]};
                    }
                 }

`uvm_object_param_utils_begin(axi_streaming_transaction_c)
  `uvm_field_array_int(tdata,UVM_ALL_ON)
  `uvm_field_enum(mode,Mode,UVM_ALL_ON)
  `uvm_field_int(tvalid_delay,UVM_ALL_ON)
  `uvm_field_int(tready_delay,UVM_ALL_ON)
  `uvm_field_int(tid_v,UVM_ALL_ON)
`uvm_object_utils_end
                    
function new(string name = "axi_streaming_transaction_c");
  super.new(name);
endfunction
  
endclass
