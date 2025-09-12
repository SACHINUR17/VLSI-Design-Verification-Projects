`ifndef AXI_ENVIRONMENT
`define AXI_ENVIRONMENT
class environment extends uvm_env;
   `uvm_component_utils(environment)

   agent agent_h;
   scoreboard scoreboard_h;
   subscriber subscriber_h;


   function new(string name="environment",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent_h=agent::type_id::create("agent_h",this);
      scoreboard_h=scoreboard::type_id::create("scoreboard_h",this);
      subscriber_h=subscriber::type_id::create("subscriber_h",this);
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agent_h.mon2scor.connect(scoreboard_h.mon2scor.analysis_export);
      agent_h.mon2scor.connect(subscriber_h.mon2scor.analysis_export);
   endfunction
    
endclass

`endif
