class ahb_base_seq extends uvm_sequence#(ahb_seq_item);

  // p_sequencer required for slave response seq
  `uvm_declare_p_sequencer(ahb_sequencer)
  
  virtual task pre_start();
    `info("start seq ...")
  endtask // pre_start
  
  virtual task post_start();
    `info("end seq ...")
  endtask // post_start
  
endclass // ahb_base_seq
