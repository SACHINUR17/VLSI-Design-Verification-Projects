
class alu_scoreboard extends uvm_component;
    `uvm_component_utils(alu_scoreboard)
    uvm_analysis_imp #(alu_txn, alu_scoreboard) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void write(alu_txn txn);
        bit [31:0] expected;

        case (txn.op)
            4'b0000: expected = txn.A + txn.B;
            4'b0001: expected = txn.A - txn.B;
            4'b0010: expected = txn.A * txn.B;
            4'b0011: expected = txn.B != 0 ? txn.A / txn.B : 32'd0;
            4'b0100: expected = txn.A << 1;
            4'b0101: expected = txn.A >> 1;
            4'b0110: expected = {txn.A[30:0], txn.A[31]};
            4'b0111: expected = {txn.A[0], txn.A[31:1]};
            default: expected = 32'd0;
        endcase

        if (expected !== txn.result)
            `uvm_error("SCOREBOARD", $sformatf("Mismatch! Got: %0d, Expected: %0d", txn.result, expected))
        else
            `uvm_info("SCOREBOARD", "ALU result is correct", UVM_LOW);
    endfunction
endclass
