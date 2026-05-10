
class base_test extends uvm_test;

  `uvm_component_utils (base_test)
   env               en;
   virtual_seqr      v_sqr;
   int    total_transaction;

   function new (string name = "base_test" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern function void build_phase               (uvm_phase phase);
   extern function void connect_phase             (uvm_phase phase);
   extern function void end_of_elaboration_phase  (uvm_phase phase);
   extern task run_phase                          (uvm_phase phase);

endclass : base_test

   function void base_test :: build_phase (uvm_phase phase);
      if(!uvm_config_db #(int) :: get (this , "" , "str" , total_transaction))begin
        `uvm_fatal("base_test" , "set total transaction")
      end
      super.build_phase (phase);
     `uvm_info ("base_test" , "build_phase" , UVM_MEDIUM) 
      en    = env          :: type_id :: create ("en" , this);
      v_sqr = virtual_seqr :: type_id :: create ("v_sqr",null);
   endfunction : build_phase

   function void base_test :: connect_phase (uvm_phase phase);
      super.connect_phase (phase);
     `uvm_info ("base_test" , "connect_phase", UVM_MEDIUM)
      v_sqr.w_sqr = en.w_agt.w_sqr;
      v_sqr.r_sqr = en.r_agt.r_sqr;
      v_sqr.c_sqr = en.c_agt.c_sqr;
   endfunction : connect_phase

   function void base_test :: end_of_elaboration_phase (uvm_phase phase);
      super.end_of_elaboration_phase (phase);
     `uvm_info ("base_test" , "end_of_elaboration_phase" , UVM_MEDIUM)
      uvm_top.print_topology();
   endfunction : end_of_elaboration_phase

   task base_test :: run_phase (uvm_phase phase);
     `uvm_info ("base_test" , "run_phase" , UVM_MEDIUM)
   endtask : run_phase

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class random_wr_test extends base_test;
  `uvm_component_utils (random_wr_test)
   vseq_random_wr vsq;

   function new (string name ="random_wr_test" , uvm_component parent);
      super.new(name,parent);
   endfunction

   task run_phase (uvm_phase phase);
     `uvm_info ("random_wr_test" , "run_phase" , UVM_MEDIUM)
      vsq = vseq_random_wr :: type_id :: create("vsq");
      vsq.total_transaction = total_transaction;
      vsq.v_sqr = v_sqr;
      phase.raise_objection(this);
      vsq.start(null);
      #5000;
      phase.drop_objection(this);
   endtask : run_phase
endclass : random_wr_test

class single_wr_test extends base_test;
  `uvm_component_utils (single_wr_test)
   vseq_single_wr vsq;

   function new (string name ="single_wr_test" , uvm_component parent);
      super.new(name,parent);
   endfunction

   task run_phase (uvm_phase phase);
     `uvm_info ("single_wr_test" , "run_phase" , UVM_MEDIUM)
      vsq = vseq_single_wr :: type_id :: create("vsq");
      vsq.total_transaction = total_transaction;
      vsq.v_sqr = v_sqr;
      phase.raise_objection(this);
      vsq.start(null);
      #5000;
      phase.drop_objection(this);
   endtask : run_phase
endclass : single_wr_test

class burst_wr_test extends base_test;
  `uvm_component_utils (burst_wr_test)
   vseq_burst_wr vsq;

   function new (string name ="burst_wr_test" , uvm_component parent);
      super.new(name,parent);
   endfunction

   task run_phase (uvm_phase phase);
     `uvm_info ("burst_wr_test" , "run_phase" , UVM_MEDIUM)
      vsq = vseq_burst_wr :: type_id :: create("vsq");
      vsq.total_transaction = total_transaction;
      vsq.v_sqr = v_sqr;
      phase.raise_objection(this);
      vsq.start(null);
      #5000;     
      phase.drop_objection(this);
   endtask : run_phase
endclass : burst_wr_test
