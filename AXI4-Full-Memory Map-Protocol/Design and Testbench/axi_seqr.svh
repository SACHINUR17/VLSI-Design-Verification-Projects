

class w_seqr extends uvm_sequencer #(w_seq_item , w_seq_item);

  `uvm_component_utils (w_seqr)

   function new (string name = "w_seqr" , uvm_component parent);
      super.new (name,parent);
   endfunction

endclass : w_seqr
