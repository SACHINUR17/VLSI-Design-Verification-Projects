
class alu_seq extends uvm_sequence #(alu_txn);
    `uvm_object_utils(alu_seq)

    function new(string name = "alu_seq");
        super.new(name);
    endfunction

    task body();
        alu_txn txn;
        repeat (10) begin
            txn = alu_txn::type_id::create("txn");
            assert(txn.randomize());
            start_item(txn);
            finish_item(txn);
        end
    endtask
endclass
