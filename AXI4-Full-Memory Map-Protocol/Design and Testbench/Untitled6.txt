
class w_agent extends uvm_agent;

  `uvm_component_utils (w_agent);
   config_obj cfg;
   w_driver   w_drv;
   w_monitor  w_mon;
   w_seqr     w_sqr;
   
   function new (string name = "w_agent" , uvm_component parent);
      super.new(name,parent);
   endfunction  
   
   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);

endclass : w_agent

   function void w_agent :: build_phase (uvm_phase phase);
      if(!uvm_config_db #(config_obj) :: get (this , "" , "config_obj" , cfg))begin
         `uvm_fatal ("w_agent" , "PLEASE SET THE CONFIG OBJECT")
      end 
      super.build_phase (phase);
     `uvm_info ("w_agent" , "build_phase" , UVM_MEDIUM)
      if (cfg.is_active == UVM_ACTIVE) begin
         w_drv = w_driver :: type_id :: create ("w_drv" , this);
         w_sqr = w_seqr   :: type_id :: create ("w_sqr" , this);
      end
      w_mon = w_monitor :: type_id :: create ("w_mon" , this);
   endfunction : build_phase

   function void w_agent :: connect_phase (uvm_phase phase);
      super.connect_phase (phase);
     `uvm_info ("w_agent" , "connect_phase" , UVM_MEDIUM)
       if (cfg.is_active == UVM_ACTIVE)  begin
          w_drv.w_drv_if  = cfg._if;
          w_drv.seq_item_port.connect (w_sqr.seq_item_export);
       end
       w_mon.w_mon_if = cfg._if;
   endfunction : connect_phase

