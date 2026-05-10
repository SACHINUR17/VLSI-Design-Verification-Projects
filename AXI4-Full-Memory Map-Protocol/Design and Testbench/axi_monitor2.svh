
class w_monitor extends uvm_monitor;

  `uvm_component_utils (w_monitor)
   virtual axi_intf.W_MON_MOD      w_mon_if;
   w_seq_item                      w_mon_command_txn;
   w_seq_item                      w_mon_data_txn;
   w_seq_item                      w_mon_resp_txn;
   uvm_analysis_port #(w_seq_item) w_mon_ap;

   realtime t1,t2,total_time;
   int      count;
  logic [DATA_WIDTH   - 1 : 0] wdata_temp[];
   function new (string name = "w_monitor" , uvm_component parent);
      super.new (name,parent);
   endfunction

   extern function void build_phase (uvm_phase phase);
   extern function void check_phase (uvm_phase phase);
   extern task run_phase            (uvm_phase phase);
   extern task perfomence_test ();

endclass : w_monitor

   function void w_monitor :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("w_monitor" , "build_phase" , UVM_MEDIUM)
      w_mon_command_txn = w_seq_item :: type_id :: create ("w_mon_command_txn");
      w_mon_data_txn    = w_seq_item :: type_id :: create ("w_mon_data_txn");
      w_mon_resp_txn    = w_seq_item :: type_id :: create ("w_mon_resp_txn");
      w_mon_ap = new ("w_mon_ap",this);
   endfunction : build_phase

   function void w_monitor :: check_phase (uvm_phase phase);
      super.check_phase (phase);
     `uvm_info ("w_monitor" , "check_phase" , UVM_MEDIUM)
      $display("count=%0d , t2=%0t",count,t2);
      total_time = ((count-1) * 64 * (10**8)) / (t2 - t1) ;
      `uvm_info("perfomence test" , $sformatf("total time for all burst = %0t",total_time) , UVM_MEDIUM);

   endfunction : check_phase

   task w_monitor :: run_phase (uvm_phase phase);
     `uvm_info ("w_monitor" , "run_phase" , UVM_MEDIUM)
      forever begin
         wait (w_mon_if.reset_n == 1'b1);
         @(w_mon_if.w_mon_cb);
         if(w_mon_if.w_mon_cb.awvalid == 1'b1 && w_mon_if.w_mon_cb.awready == 1'b1)begin
            w_mon_command_txn.w_packet  =  w_command;
            w_mon_command_txn.awid      =  w_mon_if.w_mon_cb.awid;
            w_mon_command_txn.awaddr    =  w_mon_if.w_mon_cb.awaddr;
            w_mon_command_txn.awlen     =  w_mon_if.w_mon_cb.awlen;
            w_mon_command_txn.awsize    =  w_mon_if.w_mon_cb.awsize;
            w_mon_command_txn.awburst   =  w_mon_if.w_mon_cb.awburst;
            w_mon_command_txn.w_command_count++;
            w_mon_ap.write (w_mon_command_txn);
            w_mon_data_txn.wdata.delete;
         end
        
         if(w_mon_if.w_mon_cb.wvalid == 1'b1 && w_mon_if.w_mon_cb.wready == 1'b1)begin
            w_mon_data_txn.w_packet  =  w_data;
            wdata_temp               =  w_mon_data_txn.wdata;
           w_mon_data_txn.wdata      =  new[wdata_temp.size()+1] (wdata_temp);
            w_mon_data_txn.wstrb     =  new[1];
           w_mon_data_txn.wdata[w_mon_data_txn.wdata.size()-1]  =  w_mon_if.w_mon_cb.wdata;
           //w_mon_data_txn.wdata[0] =  w_mon_if.w_mon_cb.wdata;
            w_mon_data_txn.wstrb[0]  =  w_mon_if.w_mon_cb.wstrb;
            w_mon_data_txn.wlast     =  w_mon_if.w_mon_cb.wlast;
            w_mon_data_txn.rtime     =  $realtime;
          //  w_mon_ap.write (w_mon_data_txn); 
           // perfomence_test(); 
         end 
         if(w_mon_if.w_mon_cb.bvalid == 1'b1 && w_mon_if.w_mon_cb.bready == 1'b1)begin
          // $display("DATA RTIME %t",w_mon_data_txn.rtime);
           //$display("MON DATA TXN %p",w_mon_data_txn);
             w_mon_ap.write (w_mon_data_txn); 
            w_mon_resp_txn.w_packet  =  w_resp;
            w_mon_resp_txn.bid       =  w_mon_if.w_mon_cb.bid;
            w_mon_resp_txn.bresp     =  w_mon_if.w_mon_cb.bresp;
            w_mon_command_txn.w_response_count++;
           //w_mon_ap.write (w_mon_resp_txn); 
         end
      end
   endtask : run_phase

   task w_monitor :: perfomence_test();
      if(count == 0)begin
         t1 = w_mon_data_txn.rtime;
      end else begin
         t2 = w_mon_data_txn.rtime;
      end
      count++;
   endtask

