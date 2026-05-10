
class c_seq_item extends uvm_sequence_item;

   rand logic [31 : 0] min_req_delay;
   rand logic [31 : 0] max_req_delay;
   rand logic [31 : 0] min_rsp_delay;
   rand logic [31 : 0] max_rsp_delay;
   rand logic [31 : 0] min_data_delay;
   rand logic [31 : 0] max_data_delay;
   rand logic [31 : 0] num_slave;
   rand logic          interleaving_en;
   rand logic          out_of_order_en;

   `uvm_object_utils_begin (c_seq_item)
       `uvm_field_int(min_req_delay  ,UVM_ALL_ON);
       `uvm_field_int(max_req_delay  ,UVM_ALL_ON);
       `uvm_field_int(min_rsp_delay  ,UVM_ALL_ON);
       `uvm_field_int(max_rsp_delay  ,UVM_ALL_ON);
       `uvm_field_int(min_data_delay ,UVM_ALL_ON);
       `uvm_field_int(max_data_delay ,UVM_ALL_ON);
       `uvm_field_int(interleaving_en,UVM_ALL_ON);
       `uvm_field_int(out_of_order_en,UVM_ALL_ON);
       `uvm_field_int(num_slave      ,UVM_ALL_ON);
   `uvm_object_utils_end

   function new(string name = "c_seq_item");
      super.new(name);
   endfunction

endclass : c_seq_item
