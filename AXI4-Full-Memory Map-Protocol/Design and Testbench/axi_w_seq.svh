
typedef enum {w_command,w_data,w_resp} wpacket;

class w_seq_item extends uvm_sequence_item;

   randc logic [3 : 0]                awid;
   rand logic [ADDR_WIDTH   - 1 : 0] awaddr;
   rand logic [7 : 0]                awlen;
   rand logic [2 : 0]                awsize;
   rand logic [1 : 0]                awburst;
   rand logic                        awvalid;
        logic                        awready;
  
   rand logic [DATA_WIDTH   - 1 : 0] wdata[];
   rand logic [DATA_WIDTH/8 - 1 : 0] wstrb[];
   rand logic                        wlast;
   rand logic                        wvalid;
        logic                        wready;
  
        logic [3 : 0]                bid;
        logic [1 : 0]                bresp;
        logic                        bvalid;
   rand logic                        bready;

   rand int                          cmd2cmd_delay;
   rand int                          cmd2data_delay;
   rand int                          data2data_delay;
   rand int                          min_resp_delay;
   rand int                          max_resp_delay;
 
   static int                        w_command_count;
   static int                        w_response_count; 
   static realtime                   rtime;
   wpacket                           w_packet;

   `uvm_object_utils_begin (w_seq_item)
       `uvm_field_int      (awid           ,UVM_ALL_ON);
       `uvm_field_int      (awlen          ,UVM_ALL_ON);
       `uvm_field_int      (awsize         ,UVM_ALL_ON);
       `uvm_field_int      (awburst        ,UVM_ALL_ON);
       `uvm_field_int      (awaddr         ,UVM_ALL_ON);
       `uvm_field_int      (awvalid        ,UVM_ALL_ON);
       `uvm_field_int      (awready        ,UVM_ALL_ON);
       `uvm_field_array_int(wdata          ,UVM_ALL_ON);
       `uvm_field_array_int(wstrb          ,UVM_ALL_ON);
       `uvm_field_int      (wlast          ,UVM_ALL_ON);
       `uvm_field_int      (wvalid         ,UVM_ALL_ON);
       `uvm_field_int      (wready         ,UVM_ALL_ON);
       `uvm_field_int      (bid            ,UVM_ALL_ON);
       `uvm_field_int      (bresp          ,UVM_ALL_ON);
       `uvm_field_int      (bvalid         ,UVM_ALL_ON);
       `uvm_field_int      (bready         ,UVM_ALL_ON);
       `uvm_field_int      (cmd2cmd_delay  ,UVM_ALL_ON);
       `uvm_field_int      (cmd2data_delay ,UVM_ALL_ON);
       `uvm_field_int      (data2data_delay,UVM_ALL_ON);
       `uvm_field_int      (min_resp_delay ,UVM_ALL_ON);
       `uvm_field_int      (max_resp_delay ,UVM_ALL_ON);
       `uvm_field_enum     (wpacket,w_packet,UVM_ALL_ON);
   `uvm_object_utils_end

   function new(string name = "w_seq_item");
      super.new(name);
   endfunction

   constraint awburst_c { awburst != 2'b11 ; }

   constraint awlen_c { solve awburst before awlen;
                        if(awburst == 2'b00)
                           { awlen inside {[0:15]}; }
                        else if(awburst == 2'b01)
                           { awlen inside {[0:255]}; }
                        else if(awburst == 2'b10)
                           { awlen inside {1,3,7,15}; }
                      }

//   constraint awsize_c { awsize <= 3; }
   constraint awsize_c { (2**awsize) <= (DATA_WIDTH/8); }

   constraint wstrb_c { solve awlen before wstrb;
                        solve awsize before wstrb;
                        wstrb.size() == awlen + 1;
                        foreach(wstrb[i]) 
                          // wstrb[i] == 8'hff >> (8-(2**awsize));
                           wstrb[i] == {(DATA_WIDTH/8){1'b1}} >> ((DATA_WIDTH/8)-(2**awsize));
                      }

   constraint wdatac   { solve awlen before wdata;
                         solve awsize before wdata;
                         wdata.size() == awlen + 1; 
                         /*foreach(wdata[i])
                            {
                             if(awsize == 3'b000) 
                               wdata[i][63:8]  == '0;
                             if(awsize == 3'b001) 
                                wdata[i][63:16] == '0;
                             if(awsize == 3'b010) 
                                wdata[i][63:32] == '0;
                            }*/
                       }


endclass : w_seq_item 

