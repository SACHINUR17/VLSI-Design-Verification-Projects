

class r_seqr extends uvm_sequencer #(r_seq_item , r_seq_item);

  `uvm_component_utils (r_seqr)

   function new (string name = "r_seqr" , uvm_component parent);
      super.new (name,parent);
   endfunction

endclass : r_seqr
