

class scoreboard extends uvm_scoreboard;

  `uvm_component_utils (scoreboard);
   uvm_tlm_analysis_fifo #(w_seq_item) w_scb_af;
   uvm_tlm_analysis_fifo #(r_seq_item) r_scb_af;
   uvm_tlm_analysis_fifo #(c_seq_item) c_scb_af;
   w_seq_item                          w_scb_txn;
   r_seq_item                          r_scb_txn;
   c_seq_item                          c_scb_txn;

   w_seq_item                          w_command_packet  , w_data_packet  , w_resp_packet;
   w_seq_item                          w_command_packet1 , w_data_packet1 , w_resp_packet1;
   w_seq_item                          w_data_packet2;
   w_seq_item                          w_command_queue[$], w_data_queue[$], w_resp_queue[$];
   w_seq_item                          w_command_queue1[$];
   w_seq_item                          w_data_queue1[$];
   w_seq_item                          w_data_addr_queue[$];
   w_seq_item                          expected_packet,expected_packet1;
   r_seq_item                          r_command_packet   , r_data_packet;
   r_seq_item                          r_command_packet1  , r_data_packet1;
   r_seq_item                          r_command_packet2  , r_data_packet2 , rid_packet;
   r_seq_item                          r_command_queue[$] , r_data_queue[$] , r_queue[$];
   r_seq_item                          r_data_queue1[16][$] , rid_queue[$];
   r_seq_item                          expected_r_packet;
   w_seq_item       w_addr_data_queue[$];
   w_seq_item       packet1;
   bit [31:0] w_start_address , r_start_address;
   bit [31:0] w_last_address ,  r_last_address;
   bit [0:63] data[int];
   int        num_slave=3; 
   int offset;
  int offset1;
  int awaddr1;
  int araddr1;
  //bit[0:63] wdata1;
   int        w_command_count,w_data_count,w_resp_count,r_command_count,r_resp_count,queue_size;   

   function new (string name = "scoreboard" , uvm_component parent);
      super.new (name,parent);
   endfunction
   
   extern function void build_phase (uvm_phase phase);
   extern function void check_phase (uvm_phase phase);
   extern task run_phase            (uvm_phase phase);
   extern task write_protocol_check();
   extern task read_protocol_check ();

endclass : scoreboard

   function void scoreboard :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("scoreboard" , "build_phase" , UVM_MEDIUM)
      w_scb_af = new ("w_scb_af" , this);
      r_scb_af = new ("r_scb_af" , this);
      c_scb_af = new ("c_scb_af" , this);
      c_scb_txn = c_seq_item :: type_id :: create ("c_scb_txn");

      w_scb_txn = w_seq_item :: type_id :: create ("w_scb_txn");
      w_command_packet1 = w_seq_item :: type_id :: create ("w_command_packet1");
      w_data_packet1    = w_seq_item :: type_id :: create ("w_data_packet1");
      w_data_packet2    = w_seq_item :: type_id :: create ("w_data_packet2");
      w_resp_packet1    = w_seq_item :: type_id :: create ("w_resp_packet1");
      packet1           = w_seq_item :: type_id :: create ("packet1");
      expected_packet   = w_seq_item :: type_id :: create ("expected_packet");

      r_scb_txn = r_seq_item :: type_id :: create ("r_scb_txn");
      r_command_packet1 = r_seq_item :: type_id :: create ("r_command_packet1");
      r_command_packet2 = r_seq_item :: type_id :: create ("r_command_packet2");
      r_data_packet1    = r_seq_item :: type_id :: create ("r_data_packet1");
      r_data_packet2    = r_seq_item :: type_id :: create ("r_data_packet2");
      expected_r_packet = r_seq_item :: type_id :: create ("expected_r_packet");
      rid_packet        = r_seq_item :: type_id :: create ("rid_packet");
   endfunction : build_phase

   function void scoreboard :: check_phase (uvm_phase phase);
      super.check_phase (phase);
     `uvm_info ("scoreboard" , "check_phase" , UVM_MEDIUM)
     `uvm_info ("End of test checkers" , $sformatf("\n w_command_count=%0d , w_response_count=%0d , r_command_count=%0d , r_response_count=%0d",w_scb_txn.w_command_count,w_scb_txn.w_response_count,r_scb_txn.r_command_count,r_scb_txn.r_response_count) , UVM_MEDIUM)
   endfunction : check_phase

   task scoreboard :: run_phase (uvm_phase phase);
     `uvm_info ("scoreboard" , "run_phase" , UVM_MEDIUM)
      c_scb_af.get (c_scb_txn);
      num_slave = c_scb_txn.num_slave;
      fork
         write_protocol_check ();
         #200;
         read_protocol_check ();
      join
   endtask : run_phase

   task scoreboard :: write_protocol_check ();
     `uvm_info ("scoreboard" , "run_phase : write_protocol_check" , UVM_MEDIUM)
        packet1=new();
      forever begin 
        w_scb_af.get(w_scb_txn);//Addr request
        offset=0;
        awaddr1=w_scb_txn.awaddr;
        $display("awaddr1 %d",awaddr1);
        w_scb_af.get(w_scb_txn);//Data request
        foreach(w_scb_txn.wdata[i])
          begin
            data[awaddr1+offset]=w_scb_txn.wdata[i];
            $display("Updating DATA %h index %d",data[awaddr1+offset],(awaddr1+offset));
            offset=offset+1;
          end
      end

endtask : write_protocol_check


task scoreboard :: read_protocol_check ();
     `uvm_info ("scoreboard" , "run_phase : read_protocol_check" , UVM_MEDIUM)
      forever begin 
        r_scb_af.get(r_scb_txn);//Addr Request
        offset1=0;
        araddr1=r_scb_txn.araddr;
        $display("araddr1 %d",araddr1);
        r_scb_af.get(r_scb_txn);//Data Request
        if(data.exists(araddr1))
          begin
            
        foreach(r_scb_txn.rdata[i])
          begin       
   if(r_scb_txn.rdata[i]==data[araddr1+offset1])
     begin
     //  `uvm_info("", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_NONE)
       // `uvm_info("", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_LOW)
       `uvm_info("UVM_MEDIUM", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_MEDIUM)
       `uvm_info("UVM_HIGH", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_HIGH)
       `uvm_info("UVM_LOW", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_LOW)  
       `uvm_info("UVM_DEBUG", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_DEBUG)  
       `uvm_info("UVM_NONE", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_NONE)
        //`uvm_info("", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_HIGH)
        //`uvm_info("", $sformatf("\n matched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1]) , UVM_DEBUG)
      // uvm_report_info("",$sformatf("NONE LEVEL MESSAGE") , UVM_NONE);
     // `uvm_fatal("CFG_ERROR", "Configuration Randomization Failed"); 
           end
           else begin
             `uvm_error( $sformatf("\n mismatched : data=%0h,exp_data=%0h",r_scb_txn.rdata[i],data[araddr1+offset1] ), UVM_NONE)
           end  
                        offset1=offset1+1;

         end
          end//foreach
        
       end//forever
 
    
   endtask : read_protocol_check
