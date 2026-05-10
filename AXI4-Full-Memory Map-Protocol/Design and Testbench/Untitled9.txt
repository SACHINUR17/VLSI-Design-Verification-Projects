
//.........................random read transaction...............................//

class r_seq extends uvm_sequence #(r_seq_item);
  `uvm_object_utils (r_seq)
   r_seq_item txn_h;
   int total_transaction = 10;

   function new (string name = "r_seq");
      super.new(name);
   endfunction

   task body();
      txn_h = r_seq_item :: type_id :: create("txn_h");
      repeat(total_transaction)begin
         start_item(txn_h);
        assert (txn_h.randomize() with {araddr < 16; arlen<5; cmd2cmd_delay == 1; });
         finish_item(txn_h);
      end
   endtask
endclass : r_seq 

////////////////////////////////////////////////////////////////////////////////////


//.........................single read transaction...............................//

class r_seq2 extends uvm_sequence #(r_seq_item);
  `uvm_object_utils (r_seq2)
   r_seq_item txn_h;
   int total_transaction = 10;

   function new (string name = "r_seq2");
     super.new(name);
   endfunction

   task body();
      txn_h = r_seq_item :: type_id :: create("txn_h");
     repeat(1)begin
         start_item(txn_h);
       assert (txn_h.randomize() with { araddr==6; arlen==2; cmd2cmd_delay == 1; } );
         finish_item(txn_h);
      end
   endtask
endclass : r_seq2 

////////////////////////////////////////////////////////////////////////////////////

//.........................burst of read transaction...............................//

class r_seq3 extends uvm_sequence #(r_seq_item);
  `uvm_object_utils (r_seq3)
   r_seq_item txn_h;
   int total_transaction = 10;

   function new (string name = "r_seq3");
      super.new(name);
   endfunction

   task body();
      txn_h = r_seq_item :: type_id :: create("txn_h");
      repeat(total_transaction)begin
         start_item(txn_h);
        assert (txn_h.randomize() with { araddr<31; arlen<6; cmd2cmd_delay == 1; } );
         finish_item(txn_h);
      end
   endtask
endclass : r_seq3 

////////////////////////////////////////////////////////////////////////////////////
