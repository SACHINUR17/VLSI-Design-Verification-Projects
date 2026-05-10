
class r_agent extends uvm_agent;

  `uvm_component_utils (r_agent);
   config_obj cfg;
   r_driver   r_drv;
   r_monitor  r_mon;
   r_seqr     r_sqr;
   
   function new (string name = "r_agent" , uvm_component parent);
      super.new(name,parent);
   endfunction  
   
   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);

endclass : r_agent

   function void r_agent :: build_phase (uvm_phase phase);
      if(!uvm_config_db #(config_obj) :: get (this , "" , "config_obj" , cfg))begin
         `uvm_fatal ("r_agent" , "PLEASE SET THE CONFIG OBJECT")
      end 
      super.build_phase (phase);
     `uvm_info ("r_agent" , "build_phase" , UVM_MEDIUM)
      if (cfg.is_active == UVM_ACTIVE) begin
         r_drv = r_driver :: type_id :: create ("r_drv" , this);
         r_sqr = r_seqr   :: type_id :: create ("r_sqr" , this);
      end
      r_mon = r_monitor :: type_id :: create ("r_mon" , this);
   endfunction : build_phase

   function void r_agent :: connect_phase (uvm_phase phase);
      super.connect_phase (phase);
     `uvm_info ("r_agent" , "connect_phase" , UVM_MEDIUM)
       if (cfg.is_active == UVM_ACTIVE)  begin
          r_drv.r_drv_if  = cfg._if;
          r_drv.seq_item_port.connect (r_sqr.seq_item_export);
       end
       r_mon.r_mon_if = cfg._if;
   endfunction : connect_phase

