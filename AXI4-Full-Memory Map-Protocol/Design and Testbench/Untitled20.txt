
class virtual_seqr extends uvm_sequencer;

  `uvm_component_utils (virtual_seqr)
   w_seqr  w_sqr;
   r_seqr  r_sqr;
   c_seqr  c_sqr;

   function new (string name = "virtual_seqr" , uvm_component parent);
      super.new (name,parent);
   endfunction 
 
   extern function void build_phase (uvm_phase phase);

endclass : virtual_seqr

   function void virtual_seqr :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("virtual_seqr" , "build_phase" , UVM_MEDIUM)
    //  w_sqr = w_seqr :: type_id :: create ("w_sqr" , this); 
    //  r_sqr = r_seqr :: type_id :: create ("r_sqr" , this); 
      c_sqr = c_seqr :: type_id :: create ("c_sqr" , this); 
   endfunction : build_phase

