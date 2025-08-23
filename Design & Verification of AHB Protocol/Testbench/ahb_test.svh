`include "ahb_env.svh"

class ahb_test extends uvm_test;
  `uvm_component_utils(ahb_test)
  
  ahb_env env;

  // constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new
    
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ahb_env::type_id::create("env", this);
  endfunction // build_phase
  
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction // connect_phase

  virtual task run_phase(uvm_phase phase);
    ahb_pkg::ahb_mst_rand_seq mst_seq;
    
    phase.raise_objection(this);
    mst_seq = ahb_pkg::ahb_mst_rand_seq::type_id::create();
    `check_rand(mst_seq.randomize())
    mst_seq.start(env.mst_agent.sqr);
    phase.drop_objection(this);
  endtask // run_phase
  
endclass // ahb_test
