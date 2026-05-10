class axi_Test extends uvm_test;
  
  `uvm_component_utils(axi_Test)
  
  axi_Environment#(`WIDTH,`SIZE)    env;
  axi_m_wr_Sequence#(`WIDTH,`SIZE)  seq_m_write;
  axi_m_rd_Sequence#(`WIDTH,`SIZE)  seq_m_read;
  
  function new(string name="axi_Test",uvm_component parent);
    super.new(name,parent);
  endfunction : new 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_Environment#(`WIDTH,`SIZE)::type_id::create("env", this);
    seq_m_write   = axi_m_wr_Sequence#(`WIDTH,`SIZE)::type_id::create("seq_m_write", this);
    seq_m_read    = axi_m_rd_Sequence#(`WIDTH,`SIZE)::type_id::create("seq_m_read", this);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
      repeat(5) seq_m_write.start(env.agent_m.seq);
      repeat(4) seq_m_read.start(env.agent_m.seq);
      repeat(4) seq_m_write.start(env.agent_m.seq);
      repeat(4) seq_m_read.start(env.agent_m.seq);
      repeat(3) seq_m_write.start(env.agent_m.seq);
      repeat(3) seq_m_read.start(env.agent_m.seq);
    phase.drop_objection(this);
  endtask

endclass
