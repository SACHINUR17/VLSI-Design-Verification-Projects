
typedef enum {r_command,r_data} rpacket;

class r_seq_item extends uvm_sequence_item;

   rand logic [3 : 0]                arid;
   rand logic [ADDR_WIDTH - 1 : 0]   araddr;
   rand logic [7 : 0]                arlen;
   rand logic [2 : 0]                arsize;
   rand logic [1 : 0]                arburst;
   rand logic                        arvalid;
        logic                        arready;
   
        logic [3 : 0]                rid;
        logic [1 : 0]                rresp[];
        logic [DATA_WIDTH   - 1 : 0] rdata[];
        logic [DATA_WIDTH/8 - 1 : 0] rstrb[];
        logic                        rlast;
        logic                        rvalid;
   rand logic                        rready;

   rand int                          cmd2cmd_delay;
        static int                   r_command_count;
        static int                   r_response_count;
        rpacket                      r_packet;

   `uvm_object_utils_begin (r_seq_item)
       `uvm_field_int      (arid           ,UVM_ALL_ON);
       `uvm_field_int      (arlen          ,UVM_ALL_ON);
       `uvm_field_int      (arsize         ,UVM_ALL_ON);
       `uvm_field_int      (arburst        ,UVM_ALL_ON);
       `uvm_field_int      (araddr         ,UVM_ALL_ON);
       `uvm_field_int      (arvalid        ,UVM_ALL_ON);
       `uvm_field_int      (arready        ,UVM_ALL_ON);
       `uvm_field_int      (rid            ,UVM_ALL_ON);
       `uvm_field_array_int(rresp          ,UVM_ALL_ON);
       `uvm_field_array_int(rdata          ,UVM_ALL_ON);
       `uvm_field_array_int(rstrb          ,UVM_ALL_ON);
       `uvm_field_int      (rlast          ,UVM_ALL_ON);
       `uvm_field_int      (rvalid         ,UVM_ALL_ON);
       `uvm_field_int      (rready         ,UVM_ALL_ON);
       `uvm_field_int      (cmd2cmd_delay  ,UVM_ALL_ON);
       `uvm_field_enum     (rpacket,r_packet,UVM_ALL_ON);
   `uvm_object_utils_end

   function new(string name = "r_seq_item");
      super.new(name);
   endfunction

   constraint arburst_c { arburst != 2'b11 ; }

   constraint awlen_c { solve arburst before arlen;
                        if(arburst == 2'b00)
                           { arlen inside {[0:15]}; }
                        else if(arburst == 2'b01)
                           { arlen inside {[0:255]}; }
                        else if(arburst == 2'b10)
                           { arlen inside {1,3,7,15}; }
                      }

   constraint arsize_c { arsize <= 3; }


endclass : r_seq_item



