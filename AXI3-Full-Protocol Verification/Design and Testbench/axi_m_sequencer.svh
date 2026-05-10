class axi_m_sequencer#(int WIDTH=32,SIZE=3)  extends uvm_sequencer#(axi_m_Sequence_Item#(WIDTH,SIZE));  
  `uvm_component_param_utils(axi_m_sequencer#(WIDTH,SIZE))

  function new(string name="axi_m_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction : new 
endclass

