
class c_agent extends uvm_agent;

  `uvm_component_utils (c_agent);
   config_obj cfg;
   c_driver   c_drv;
   c_monitor  c_mon;
   c_seqr     c_sqr;
   
   function new (string name = "c_agent" , uvm_component parent);
      super.new(name,parent);
   endfunction  
   
   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);

endclass : c_agent

   function void c_agent :: build_phase (uvm_phase phase);
      if(!uvm_config_db #(config_obj) :: get (this , "" , "config_obj" , cfg))begin
         `uvm_fatal ("c_agent" , "PLEASE SET THE CONFIG OBJECT")
      end 
      super.build_phase (phase);
     `uvm_info ("c_agent" , "build_phase" , UVM_MEDIUM)
      if (cfg.is_active == UVM_ACTIVE) begin
         c_drv = c_driver :: type_id :: create ("c_drv" , this);
         c_sqr = c_seqr   :: type_id :: create ("c_sqr" , this);
      end
      c_mon = c_monitor :: type_id :: create ("c_mon" , this);
   endfunction : build_phase

   function void c_agent :: connect_phase (uvm_phase phase);
      super.connect_phase (phase);
     `uvm_info ("c_agent" , "connect_phase" , UVM_MEDIUM)
       if (cfg.is_active == UVM_ACTIVE)  begin
          c_drv.c_drv_if  = cfg._if;
          c_drv.seq_item_port.connect (c_sqr.seq_item_export);
       end
       c_mon.c_mon_if = cfg._if;
   endfunction : connect_phase

