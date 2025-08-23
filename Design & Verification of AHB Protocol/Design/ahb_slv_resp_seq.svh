class ahb_slv_resp_seq extends ahb_base_seq;
  `uvm_object_utils(ahb_slv_resp_seq)
  
  // slave response latencies - request to first beat response delay
  rand uint32_t rd_rsp_latency;
  rand uint32_t wr_rsp_latency;
  
  virtual task body();
    ahb_seq_item req;
    ahb_seq_item rsp;
    
    `info($sformatf("Latencies: RD => %0d, WR => %0d", rd_rsp_latency, wr_rsp_latency))
    forever begin
      // wait for cmd from monitor and generate response transaction
      p_sequencer.cmd_fifo.get(req);
      `info_high($sformatf("Rcvd cmd: %s", req.cmd2string()))
      
      rsp = ahb_seq_item::type_id::create("slv_rsp");
      start_item(rsp);
      
      rsp.set_cmd_attr(req);
      `check_rand(rsp.randomize())
      rsp.add_latency(req.kind == READ ? rd_rsp_latency : wr_rsp_latency);
      finish_item(rsp);
    end // forever
   
  endtask // body

  constraint rsp_latency_c {
    rd_rsp_latency dist { 0 :/ 50, [1:5] :/ 50 };
    wr_rsp_latency dist { 0 :/ 50, [1:5] :/ 50 };
  }
  
endclass // ahb_slv_resp_seq
