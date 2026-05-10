
class c_seq extends uvm_sequence #(c_seq_item);
  `uvm_object_utils (c_seq)
   c_seq_item txn_h;
   int total_transaction = 10;

   function new (string name = "c_seq");
      super.new(name);
   endfunction

   task body();
      txn_h = c_seq_item :: type_id :: create("txn_h");
      repeat(1)begin
         start_item(txn_h);
         assert (txn_h.randomize() with { min_req_delay   == 1; 
                                          max_req_delay   == 5; 
                                          min_rsp_delay   == 1; 
                                          max_rsp_delay   == 5; 
                                          min_data_delay  == 1; 
                                          max_data_delay  == 5; 
                                          interleaving_en == 0;
                                          out_of_order_en == 0;
                                          num_slave       == 3; });     
         finish_item(txn_h);               
      end                                  
   endtask                                 
endclass : c_seq                           
