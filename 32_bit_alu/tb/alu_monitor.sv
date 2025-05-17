
class alu_monitor extends uvm_monitor;
    `uvm_component_utils(alu_monitor)
    virtual alu_if vif;
    uvm_analysis_port #(alu_txn) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            alu_txn txn = alu_txn::type_id::create("txn");
            @(posedge vif.clk);
            txn.A = vif.A;
            txn.B = vif.B;
            txn.op = vif.op;
            txn.result = vif.ALU_Out;
            ap.write(txn);
        end
    endtask
endclass
