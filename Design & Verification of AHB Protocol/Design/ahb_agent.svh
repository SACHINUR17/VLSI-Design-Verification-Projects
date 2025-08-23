
typedef class ahb_slv_resp_seq; // forward class declaration


class ahb_agent extends uvm_agent;
  `uvm_component_utils(ahb_agent)
  
  ahb_sequencer sqr;
  ahb_driver    drv;
  ahb_monitor   mon;
  ahb_cfg       cfg;
  uvm_analysis_port #(ahb_seq_item) mon_ap;
  
  // constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new
    
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(ahb_cfg)::get(this, "", "cfg", cfg)) begin
      // create default config when not set
      `info("creating default cfg ...")
      cfg = ahb_cfg::type_id::create("cfg");
      `check_rand(cfg.randomize())
    end // if
    void'(uvm_config_db#(bit)::get(this, "", "is_slave", cfg.is_slave));
    
    uvm_config_db#(ahb_cfg)::set(this, "*", "cfg", cfg); // set cfg to childs
    if(is_active == UVM_ACTIVE) begin
      sqr = ahb_sequencer::type_id::create("sqr", this);
      drv = ahb_driver::type_id::create("drv", this);
    end // if
    mon = ahb_monitor::type_id::create("mon", this);
    mon_ap = new("mon_ap", this);
  endfunction // build_phase
  

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export);
        // active slave, connect cmd_fifo for response seq
        if(cfg.is_slave) mon.cmd_ap.connect(sqr.cmd_fifo.analysis_export);
    end // if
    mon.mon_ap.connect( mon_ap ); // hierarchical ap connect
  endfunction // connect_phase

  virtual function void start_of_simulation_phase(uvm_phase phase);
    `info(cfg.convert2string())
    cfg.is_active = is_active; // copy mirrored value in cfg
  endfunction // start_of_simulation_phase
  
  
  virtual task run_phase(uvm_phase phase);
    if(cfg.is_slave) begin
      // start the default slave response seq without raising objection
      ahb_slv_resp_seq rsp_seq;
      rsp_seq = ahb_slv_resp_seq::type_id::create("rsp_seq");
      `check_rand(rsp_seq.randomize())
      rsp_seq.start(sqr);
    end // if
  endtask // run_phase

  // set cfg tr_print helper method
  function void set_tr_print(bit tr_print = TRUE);
    cfg.tr_print = tr_print;
    `info($sformatf("set tr_print = %b", tr_print))
  endfunction // set_tr_print
  
  // set cfg busy helper method - maybe used to override randomzied config
  //   if wr_rd[0] = 1, set read busy attributes
  //   if wr_rd[1] = 1, set write busy attributes
  function void set_busy(int min, int max = -1, bit [1:0] wr_rd = {TRUE, TRUE});
    
    max = max >= min ? max : min;
    if(wr_rd[0]) begin
      cfg.min_rd_busy = min;
      cfg.max_rd_busy = max;
      `info($sformatf("set RD busy = [%0d : %0d]", min, max))
    end // if
    if(wr_rd[1]) begin
      cfg.min_wr_busy = min;
      cfg.max_wr_busy = max;
      `info($sformatf("set WR busy = [%0d : %0d]", min, max))
    end // if  endfunction // set_busy
  endfunction // set_busy
  
endclass // ahb_agent
