class ahb_driver extends uvm_driver #(ahb_seq_item);
  `uvm_component_utils(ahb_driver)
  
  virtual ahb_if vif;
  ahb_cfg cfg;
  uvm_tlm_fifo#(ahb_seq_item) prefetch_fifo;

  
  // address pipeline semaphore key
  semaphore addr_key = new(1);
  
  // constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ahb_if)::get(this, "", "vif", vif)) `error("vif not set!")                                     
    if(!uvm_config_db#(ahb_cfg)::get(this, "", "cfg", cfg)) `error("cfg is not set!")
    prefetch_fifo = new("pre_fifo", this, 1);  // default size = 1
  endfunction // build_phase
                                            
    
  virtual task run_phase(uvm_phase phase);
    do_init();
    
    @(posedge vif.hreset_n);
    @(posedge vif.hclk);
    
    // slave mode reactive driver does not require pipeline to drive responses
    if(cfg.is_slave == TRUE) begin
      do_slv_ahb_trans();
    end else begin
      fork
        // prefetch one seq_items to be able drive idle cycles correctly
        do_mst_prefetch(); 
        // up to 2 pipelined transfers in master mode
        do_mst_ahb_trans();
        do_mst_ahb_trans();
      join
    end // if
  endtask // run_phase

  
  // master: prefetch one seq_item ahead for the pipeline
  // to check and drive idly cycle correctly
  task do_mst_prefetch();
    forever begin
      ahb_seq_item req;
      seq_item_port.get_next_item(req);
      prefetch_fifo.put(req);
      seq_item_port.item_done();
    end // forever
  endtask // do_mst_prefetch

  
  // master: drive ahb transaction on bus
  task do_mst_ahb_trans;
    forever begin
      ahb_seq_item req;
      addr_key.get(); // lock addr pipeline
      // get next item from sqr
      prefetch_fifo.get(req);
      `info_high($sformatf("Rcvd item: %s", req.convert2string()))
      
      // drive cmd
      vif.haddr  <= req.addr;
      vif.hwrite <= req.kind;
      vif.htrans <= NONSEQ;
      vif.hsize  <= req.size;
      vif.hburst <= SINGLE;
      
      wait_ready(); // wait for addr accepted
      `info_debug($sformatf("addr done."))

      if(req.busy[0] > 0) begin
        `info_high($sformatf("insert %0d busy cycles", req.busy[0]))
        vif.htrans <= BUSY;
        repeat(req.busy[0]) wait_cycle();
      end // if
      
      // drive idle cycle on bus only when next item is not available from sequence
      // this must be done before add pipeline is unlocked to check before the other pipeline 
      // has_do_available not working probably because everything happens 
      // on same timeslot. check prefetch_fifo instead
      //if(!seq_item_port.has_do_available()) begin
      //  do_mst_idle();
      //end // if
      if(prefetch_fifo.used() == 0) do_mst_idle();
      addr_key.put(1); // unlock addr pipeline

      // drive/sample data
      if(req.kind == WRITE) begin
        vif.hwdata  <= req.data[0];
      end else begin
        req.data = new[1];
        req.data[0] = vif.hrdata;
      end // if
      
      wait_ready();  // wait for data accepted
      req.resp = hresp_e'(vif.hresp);
      seq_item_port.put(req); // return updated req as response
      `info_high($sformatf("Done item: %s", req.convert2string()))
    end // forever
  endtask // do_mst_ahb_trans

  
  // slave: drive ahb response on bus
  task do_slv_ahb_trans;
    ahb_seq_item rsp;
    forever begin
      // get next item from sqr
      seq_item_port.get_next_item(rsp);
      `info_high($sformatf("Rcvd rsp item: %s", rsp.convert2string()))
      
      if(rsp.busy[0] > 0) begin
        `info_high($sformatf("insert %0d busy cycles", rsp.busy[0]))
        vif.hready <= FALSE;
        repeat(rsp.busy[0]) wait_cycle();
      end // if

      vif.hready <= TRUE;
      vif.hresp  <= rsp.resp;
      if(rsp.kind == READ) vif.hrdata <= rsp.data[0];
      wait_cycle();
      seq_item_port.item_done();
    end // forever
  endtask // do_slv_response
  

      
  // master - drive idle cycle on the bus
  task do_mst_idle(bit init_all = FALSE);
    `info("insert idle cycle")
    vif.htrans <= IDLE;
    
    if(init_all) begin
      // static signals
      vif.haddr  <= '0;
      //vif.hwdata <= '0; // can't clear data after addr cycle
      vif.hwrite <= FALSE;
      vif.hsize  <= BYTE;
      vif.hburst <= SINGLE;
    end // if
  endtask // do_mst_idle

  
  // initialize bus
  task do_init();
    `info("initialize bus")
    if(cfg.is_slave) begin
      vif.hrdata <= '0;
      vif.hresp  <= OKAY;
      vif.hready <= TRUE;
    end else begin
      vif.hmastlock <= FALSE;
      vif.hsel      <= TRUE;
      vif.hprot     <= '0;

      vif.haddr  <= '0;
      vif.hwdata <= '0;
      vif.hwrite <= FALSE;
      vif.hsize  <= BYTE;
      vif.hburst <= SINGLE;
      vif.htrans <= IDLE;
    end // if
  endtask // do_idle


  // wait for a clock cycle
  task wait_cycle();
    @(posedge vif.hclk);
  endtask // wait_cycle
  
  // wait for hready
  task wait_ready();
    do wait_cycle(); while(vif.hready != TRUE);
  endtask // wait_ready

endclass // ahb_mst_driver
