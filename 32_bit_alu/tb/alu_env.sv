
class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)

    alu_agent agent;
    alu_scoreboard sb;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = alu_agent::type_id::create("agent", this);
        sb = alu_scoreboard::type_id::create("sb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.ap.connect(sb.ap);
    endfunction
endclass
