
class c_seqr extends uvm_sequencer #(c_seq_item , c_seq_item);

  `uvm_component_utils (c_seqr)

   function new (string name = "c_seqr" , uvm_component parent);
      super.new (name,parent);
   endfunction

endclass : c_seqr
