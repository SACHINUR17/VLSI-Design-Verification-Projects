
class alu_txn extends uvm_sequence_item;
    rand bit [31:0] A, B;
    rand bit [3:0] op;
    bit [31:0] result;

    `uvm_object_utils(alu_txn)

    function new(string name = "alu_txn");
        super.new(name);
    endfunction
endclass
