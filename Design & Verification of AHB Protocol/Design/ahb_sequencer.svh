class ahb_sequencer extends uvm_sequencer#(ahb_seq_item);
  `uvm_component_utils(ahb_sequencer)
  
  // uvm_tlm_analysis_fifo: uvm_tlm_fifo with an unbounded size and a write interface.
  uvm_tlm_analysis_fifo#(ahb_seq_item) cmd_fifo;  // cmd fifo for slave agent
  
  // constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cmd_fifo = new("cmd_fifo", this);
  endfunction // build_phase
  
endclass // ahb_sequencer
