
class env extends uvm_env;

  `uvm_component_utils (env)
   w_agent      w_agt;
   r_agent      r_agt;
   c_agent      c_agt;
   scoreboard   scb;
   coverage     cov;

   function new (string name = "env" , uvm_component parent);
      super.new(name,parent);
   endfunction

   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);

endclass : env

   function void env :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("env" , "build_phase" , UVM_MEDIUM)
      w_agt = w_agent    :: type_id :: create ("w_agt" , this);
      r_agt = r_agent    :: type_id :: create ("r_agt" , this);
      c_agt = c_agent    :: type_id :: create ("c_agt" , this);
      scb   = scoreboard :: type_id :: create ("scb"   , this);
      cov   = coverage   :: type_id :: create ("cov"   , this);
   endfunction : build_phase

   function void env :: connect_phase (uvm_phase phase);
      super.connect_phase (phase);
     `uvm_info ("env" , "connect_phase" , UVM_MEDIUM)
      w_agt.w_mon.w_mon_ap.connect (scb.w_scb_af.analysis_export);
      r_agt.r_mon.r_mon_ap.connect (scb.r_scb_af.analysis_export);
      c_agt.c_mon.c_mon_ap.connect (scb.c_scb_af.analysis_export);
      w_agt.w_mon.w_mon_ap.connect (cov.w_cov_af.analysis_export);
      r_agt.r_mon.r_mon_ap.connect (cov.r_cov_af.analysis_export);
//     c_agt.c_mon.c_mon_ap.connect (cov.c_cov_af.analysis_export);
   endfunction : connect_phase
   
