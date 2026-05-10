
//.........................random write transaction...............................//

class w_seq extends uvm_sequence #(w_seq_item);
  `uvm_object_utils (w_seq)
   w_seq_item txn_h;
   int total_transaction=10;

   function new (string name = "w_seq");
      super.new(name);
   endfunction

   task body();
      txn_h = w_seq_item :: type_id :: create("txn_h");
     repeat(total_transaction)
       begin
         start_item(txn_h);
       assert (txn_h.randomize() with { awaddr<15; awlen<5 ; cmd2cmd_delay==1; cmd2data_delay==1; data2data_delay==1; } );
         finish_item(txn_h);
      end
   endtask
endclass : w_seq 

////////////////////////////////////////////////////////////////////////////////////
//.........................single write transaction...............................//

class w_seq2 extends uvm_sequence #(w_seq_item);
  `uvm_object_utils (w_seq2)
   w_seq_item txn_h;
   int total_transaction = 10;

   function new (string name = "w_seq2");
      super.new(name);
   endfunction

   task body();
      txn_h = w_seq_item :: type_id :: create("txn_h");
     repeat(1)begin
         start_item(txn_h);
       assert (txn_h.randomize() with { awaddr==6; awlen==2; cmd2cmd_delay==1; cmd2data_delay==1; data2data_delay==1; } );
         finish_item(txn_h);
      end
   endtask
endclass : w_seq2 

////////////////////////////////////////////////////////////////////////////////////

//.........................burst of write transaction...............................//

class w_seq3 extends uvm_sequence #(w_seq_item);
  `uvm_object_utils (w_seq3)
   w_seq_item txn_h;
   int total_transaction = 10;

   function new (string name = "w_seq3");
      super.new(name);
   endfunction

   task body();
      txn_h = w_seq_item :: type_id :: create("txn_h");
      repeat(total_transaction)begin
       // $display("no_of_trans %d : time %t",total_transaction,$time);
         start_item(txn_h);
        assert (txn_h.randomize() with { awaddr<31; awlen<6; cmd2cmd_delay==1; cmd2data_delay==1; data2data_delay==1; } );
         finish_item(txn_h);
      end
   endtask
endclass : w_seq3 
