class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)
  
  virtual ahb_if vif;
  uvm_analysis_port #(ahb_seq_item) mon_ap;
  uvm_analysis_port #(ahb_seq_item) cmd_ap; // cmd requests for slave driver

  ahb_cfg cfg;

  // address pipeline semaphore key
  semaphore addr_key = new(1);
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif)) `error("vif is not set!")
    if(!uvm_config_db#(ahb_cfg)::get(this, "", "cfg", cfg)) `error("cfg is not set!")
    mon_ap = new("mon_ap", this);
    cmd_ap = new("cmd_ap", this);
  endfunction // build_phase

  
  virtual task run_phase(uvm_phase phase);
    fork  // up to 2 pipelined transfers
      do_ahb_trans();
      do_ahb_trans();
    join
  endtask // run_phase

  
  // capture ahb transaction pipeline
  task do_ahb_trans();
    ahb_seq_item req;

    forever begin
      addr_key.get(); // lock addr pipeline
      // wait for new trans addr accepted
      do wait_cycle(); while(!(vif.hsel == TRUE && vif.htrans == NONSEQ && vif.hready));
      `info_high($sformatf("Rcvd addr=0x%h", vif.haddr))
      
      req = ahb_seq_item::type_id::create("mon_item");
      init_trans(req);
      // send cmds to cmd_fifo only in active slave mode for driving responses
      if(cfg.is_active == UVM_ACTIVE && cfg.is_slave) cmd_ap.write(req);
      addr_key.put(); // unlock addr pipeline

      req.busy = new[1];
      wait_ready(req.busy[0]);  // wait for data accepted
      req.data = new[1];
      if(req.kind == WRITE) begin
        req.data[0] = vif.hwdata;
        `info_high($sformatf("Rcvd wr data=0x%h", vif.hwdata))
      end else begin
        req.data[0] = vif.hrdata;
        `info_high($sformatf("Rcvd rd data=0x%h", vif.hrdata))
      end // if
      if(cfg.tr_print) `info($sformatf("Rcvd ahb item: %s", req.convert2string()))
      mon_ap.write(req);
    end // forever
  endtask // do_ahb_trans

  
  // wait for a clock cycle and check ahb bus for X's (if xcheck=TRUE)
  task wait_cycle(bit xcheck=TRUE);
    @(posedge vif.hclk);
    if(xcheck) do_xcheck();
  endtask // wait_cycle

  
  // wait for hready
  task wait_ready(output int busy);
    busy = 0;
    // wait for data accepted
    do begin
      wait_cycle();
      busy++;
    end while(vif.hready != TRUE);
  endtask // wait_ready
  
  
  // check ahb signals for X
  function void do_xcheck();
    `check_ifx(^{vif.hsel, vif.haddr, vif.hburst, vif.hmastlock, vif.hprot, vif.hsize, vif.htrans, vif.hwrite, vif.hwdata})
    `check_ifx(^{vif.hready, vif.hresp, vif.hrdata})
  endfunction // do_xcheck

  
  // initialize transaction
  function void init_trans(ahb_seq_item req);
      req.addr = vif.haddr;
      req.kind = kind_e'(vif.hwrite);
      req.size = WORD;
      req.length = 0;
      req.wrap = FALSE;
  endfunction // init_trans

endclass // ahb_monitor
