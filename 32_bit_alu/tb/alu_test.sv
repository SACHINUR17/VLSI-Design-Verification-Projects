
class alu_test extends uvm_test;
    `uvm_component_utils(alu_test)

    alu_env env;
    alu_seq seq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = alu_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq = alu_seq::type_id::create("seq");
        seq.start(env.agent.drv);
        phase.drop_objection(this);
    endtask
endclass
