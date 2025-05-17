
class alu_agent extends uvm_agent;
    `uvm_component_utils(alu_agent)

    alu_driver drv;
    alu_monitor mon;
    uvm_analysis_port #(alu_txn) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = alu_driver::type_id::create("drv", this);
        mon = alu_monitor::type_id::create("mon", this);
        uvm_config_db #(virtual alu_if)::set(this, "drv", "vif", vif);
        uvm_config_db #(virtual alu_if)::set(this, "mon", "vif", vif);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        mon.ap.connect(ap);
    endfunction
endclass
