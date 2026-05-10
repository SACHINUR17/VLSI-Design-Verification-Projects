
class c_driver extends uvm_driver #(c_seq_item , c_seq_item);

  `uvm_component_utils (c_driver)
   virtual axi_intf.C_DRV_MOD c_drv_if;

   c_seq_item   c_drv_txn;

   function new (string name = "c_driver" , uvm_component parent);
      super.new (name,parent);
   endfunction

   extern function void build_phase  (uvm_phase phase); 
   extern task run_phase             (uvm_phase phase);

endclass : c_driver

   function void c_driver :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("c_driver" , "build_phase" , UVM_MEDIUM) 
      c_drv_txn = c_seq_item :: type_id :: create ("c_drv_txn");
   endfunction : build_phase

   task c_driver :: run_phase (uvm_phase phase);
     `uvm_info ("c_driver" , "run_phase" , UVM_MEDIUM)
      wait (c_drv_if.reset_n == 1'b1);
      @(c_drv_if.c_drv_cb);
      seq_item_port.get_next_item (req);
      c_drv_if.c_drv_cb.min_req_delay    <= req.min_req_delay;
      c_drv_if.c_drv_cb.max_req_delay    <= req.max_req_delay;
      c_drv_if.c_drv_cb.min_rsp_delay    <= req.min_rsp_delay;
      c_drv_if.c_drv_cb.max_rsp_delay    <= req.max_rsp_delay;
      c_drv_if.c_drv_cb.min_data_delay   <= req.min_data_delay;
      c_drv_if.c_drv_cb.max_data_delay   <= req.max_data_delay;
      c_drv_if.c_drv_cb.interleaving_en  <= req.interleaving_en;
      c_drv_if.c_drv_cb.out_of_order_en  <= req.out_of_order_en;
      c_drv_if.c_drv_cb.num_slave        <= req.num_slave;
      seq_item_port.item_done (rsp);
   endtask : run_phase      
