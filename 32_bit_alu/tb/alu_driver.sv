
class alu_driver extends uvm_driver #(alu_txn);
    `uvm_component_utils(alu_driver)
    virtual alu_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            alu_txn txn;
            seq_item_port.get_next_item(txn);

            vif.A <= txn.A;
            vif.B <= txn.B;
            vif.op <= txn.op;

            @(posedge vif.clk);
            @(posedge vif.clk);

            txn.result = vif.ALU_Out;
            seq_item_port.item_done();
        end
    endtask
endclass
