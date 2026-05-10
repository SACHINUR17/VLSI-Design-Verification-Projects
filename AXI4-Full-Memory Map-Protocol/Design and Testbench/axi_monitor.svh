
class r_monitor extends uvm_monitor;

  `uvm_component_utils (r_monitor)
   virtual axi_intf.R_MON_MOD      r_mon_if;
   r_seq_item                      r_mon_command_txn;
   r_seq_item                      r_mon_data_txn;
   uvm_analysis_port #(r_seq_item) r_mon_ap;
  
  logic [DATA_WIDTH   - 1 : 0] rdata_temp[];


   function new (string name = "r_monitor" , uvm_component parent);
      super.new (name,parent);
   endfunction

   extern function void build_phase (uvm_phase phase);
   extern task run_phase            (uvm_phase phase);

endclass : r_monitor

   function void r_monitor :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("r_monitor" , "build_phase" , UVM_MEDIUM)
      r_mon_command_txn = r_seq_item :: type_id :: create ("r_mon_command_txn");
      r_mon_data_txn    = r_seq_item :: type_id :: create ("r_mon_data_txn");
      r_mon_ap = new ("r_mon_ap",this);
   endfunction : build_phase

   task r_monitor :: run_phase (uvm_phase phase);
     `uvm_info ("r_monitor" , "run_phase" , UVM_MEDIUM)
      forever begin
         wait (r_mon_if.reset_n == 1'b1);
         @(r_mon_if.r_mon_cb);
         if(r_mon_if.r_mon_cb.arvalid == 1'b1 && r_mon_if.r_mon_cb.arready == 1'b1)begin
            r_mon_command_txn.r_packet  =  r_command;
            r_mon_command_txn.arid      =  r_mon_if.r_mon_cb.arid;
            r_mon_command_txn.araddr    =  r_mon_if.r_mon_cb.araddr;
            r_mon_command_txn.arlen     =  r_mon_if.r_mon_cb.arlen;
            r_mon_command_txn.arsize    =  r_mon_if.r_mon_cb.arsize;
            r_mon_command_txn.arburst   =  r_mon_if.r_mon_cb.arburst;
            r_mon_command_txn.r_command_count++;
          // $display("WRITING READ CMD %d",r_mon_command_txn.r_command_count);
            r_mon_ap.write (r_mon_command_txn); 
            r_mon_data_txn.rdata.delete;
         end 
      
           // wait(r_mon_if.r_mon_cb.rvalid==1);
           // $display("rvalid 1 %d",r_mon_if.r_mon_cb.rvalid);
         if(r_mon_if.r_mon_cb.rvalid == 1'b1 && r_mon_if.r_mon_cb.rready == 1'b1)begin
             repeat(r_mon_command_txn.arlen+1)
          begin
            r_mon_data_txn.r_packet  =  r_data;
           rdata_temp                = r_mon_data_txn.rdata;
           r_mon_data_txn.rdata     =  new[rdata_temp.size()+1] (rdata_temp);
            r_mon_data_txn.rstrb     =  new[1];
            r_mon_data_txn.rresp     =  new[1];
           r_mon_data_txn.rdata[r_mon_data_txn.rdata.size()-1]  =  r_mon_if.r_mon_cb.rdata;
           // r_mon_data_txn.rdata[0]  =  r_mon_if.r_mon_cb.rdata;
            r_mon_data_txn.rstrb[0]  =  r_mon_if.r_mon_cb.rstrb;
            r_mon_data_txn.rlast     =  r_mon_if.r_mon_cb.rlast;
            r_mon_data_txn.rid       =  r_mon_if.r_mon_cb.rid;
            r_mon_data_txn.rresp[0]  =  r_mon_if.r_mon_cb.rresp;
            //r_mon_ap.write (r_mon_data_txn); 
                         @(r_mon_if.r_mon_cb);

         end 
                     r_mon_ap.write (r_mon_data_txn); 
          end
        //wait(r_mon_if.r_mon_cb.rvalid==0);
       // $display("rvalid 2 %d",r_mon_if.r_mon_cb.rvalid);
         if(r_mon_if.r_mon_cb.rvalid == 1'b1 && r_mon_if.r_mon_cb.rready == 1'b1 && r_mon_if.r_mon_cb.rlast == 1'b1)begin
         //   r_mon_ap.write (r_mon_data_txn); 
            r_mon_command_txn.r_response_count++;   
         end 
      end
   endtask : run_phase
