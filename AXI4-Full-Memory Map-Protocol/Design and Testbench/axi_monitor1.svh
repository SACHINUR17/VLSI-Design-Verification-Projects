
class c_monitor extends uvm_monitor;

  `uvm_component_utils (c_monitor)
   virtual axi_intf.C_MON_MOD      c_mon_if;
   c_seq_item                      c_mon_txn;
   uvm_analysis_port #(c_seq_item) c_mon_ap;
   function new (string name = "c_monitor" , uvm_component parent);
      super.new (name,parent);
   endfunction

   extern function void build_phase (uvm_phase phase);
   extern task run_phase            (uvm_phase phase);

endclass : c_monitor

   function void c_monitor :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("c_monitor" , "build_phase" , UVM_MEDIUM)
      c_mon_txn = c_seq_item :: type_id :: create ("c_mon_txn");
      c_mon_ap = new ("c_mon_ap",this);
   endfunction : build_phase

   task c_monitor :: run_phase (uvm_phase phase);
     `uvm_info ("c_monitor" , "run_phase" , UVM_MEDIUM)
         wait (c_mon_if.reset_n == 1'b1);
         @(c_mon_if.c_mon_cb);
         @(c_mon_if.c_mon_cb);
         c_mon_txn.min_req_delay    =  c_mon_if.c_mon_cb.min_req_delay;
         c_mon_txn.max_req_delay    =  c_mon_if.c_mon_cb.max_req_delay;
         c_mon_txn.min_rsp_delay    =  c_mon_if.c_mon_cb.min_rsp_delay;
         c_mon_txn.max_rsp_delay    =  c_mon_if.c_mon_cb.max_rsp_delay;
         c_mon_txn.min_data_delay   =  c_mon_if.c_mon_cb.min_data_delay;
         c_mon_txn.max_data_delay   =  c_mon_if.c_mon_cb.max_data_delay;
         c_mon_txn.interleaving_en  =  c_mon_if.c_mon_cb.interleaving_en;
         c_mon_txn.out_of_order_en  =  c_mon_if.c_mon_cb.out_of_order_en;
         c_mon_txn.num_slave        =  c_mon_if.c_mon_cb.num_slave;
         c_mon_ap.write (c_mon_txn); 
   endtask : run_phase
