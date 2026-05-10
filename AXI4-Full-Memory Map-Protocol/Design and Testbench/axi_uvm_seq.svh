
class base_vseq extends uvm_sequence #(uvm_sequence_item);

  `uvm_object_utils (base_vseq)

   virtual_seqr v_sqr;
   int total_transaction;

   c_seq         csq;

   w_seq         wsq;
   w_seq2        wsq2;
   w_seq3        wsq3;
  
   r_seq         rsq;
   r_seq2        rsq2;
   r_seq3        rsq3;
  

   function new (string name = "base_vseq");
      super.new (name);
   endfunction

   task body();
      csq   = c_seq   :: type_id :: create ("csq");
 
      wsq   = w_seq   :: type_id :: create ("wsq"); 
      wsq2  = w_seq2  :: type_id :: create ("wsq2"); 
      wsq3  = w_seq3  :: type_id :: create ("wsq3"); 
     
      rsq   = r_seq   :: type_id :: create ("rsq"); 
      rsq2  = r_seq2  :: type_id :: create ("rsq2"); 
      rsq3  = r_seq3  :: type_id :: create ("rsq3"); 
      

      csq.total_transaction   = total_transaction;

      wsq.total_transaction   = total_transaction;
      wsq2.total_transaction  = total_transaction;
      wsq3.total_transaction  = total_transaction;
     

      rsq.total_transaction   = total_transaction;
      rsq2.total_transaction  = total_transaction;
      rsq3.total_transaction  = total_transaction;
     
   endtask : body

endclass : base_vseq

class vseq_random_wr extends base_vseq;
  `uvm_object_utils (vseq_random_wr)

   function new (string name = "vseq_random_wr");
      super.new (name);
   endfunction

   task body ();
      super.body();
      csq.start (v_sqr.c_sqr);
     // fork
     repeat(2)
       begin
         wsq.start (v_sqr.w_sqr);
         #200;
         rsq.start (v_sqr.r_sqr);
       end
      //join
   endtask
endclass : vseq_random_wr


class vseq_single_wr extends base_vseq;
  `uvm_object_utils (vseq_single_wr)

   function new (string name = "vseq_single_wr");
      super.new (name);
   endfunction

   task body ();
      super.body();
      csq.start (v_sqr.c_sqr);
      //fork
     repeat(1)
       begin
         wsq2.start (v_sqr.w_sqr);
         #200;
         rsq2.start (v_sqr.r_sqr);
       end
     
      //join
   endtask
endclass : vseq_single_wr

class vseq_burst_wr extends base_vseq;
  `uvm_object_utils (vseq_burst_wr)

   function new (string name = "vseq_burst_wr");
      super.new (name);
   endfunction

   task body ();
      super.body();
      csq.start (v_sqr.c_sqr);
      //fork
     repeat(5)
       begin
         wsq3.start (v_sqr.w_sqr);
        #200;
        rsq3.start (v_sqr.r_sqr);
        
       end
      //join
   endtask
endclass : vseq_burst_wr
