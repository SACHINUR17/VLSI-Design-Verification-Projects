`ifndef AXI_SEQUENCER
`define AXI_SEQUENCER

class sequencer extends uvm_sequencer#(transaction);
   `uvm_component_utils(sequencer)

   function new(string name="sequencer",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction

endclass

`endif
