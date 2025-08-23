class ahb_env extends uvm_env;
  `uvm_component_utils(ahb_env)
  
  ahb_pkg::ahb_agent mst_agent;
  ahb_pkg::ahb_agent slv_agent;

  // constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new
    
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mst_agent = ahb_pkg::ahb_agent::type_id::create("mst_agent", this);
    slv_agent = ahb_pkg::ahb_agent::type_id::create("slv_agent", this);
    uvm_config_db#(bit)::set(this, "slv_agent", "is_slave", TRUE);
  endfunction // build_phase
  
  virtual task run_phase(uvm_phase phase);  
    // disable slave agent's monitor transactions reporting
    slv_agent.set_tr_print(FALSE);
  endtask // run_phase
  
endclass // ahb_test
