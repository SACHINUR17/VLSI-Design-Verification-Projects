
class config_obj extends uvm_object;

  `uvm_object_utils (config_obj) 
   uvm_active_passive_enum   is_active = UVM_ACTIVE;
   virtual axi_intf                    _if;

   function new (string name = "config_obj");
      super.new (name);
   endfunction 

endclass : config_obj

