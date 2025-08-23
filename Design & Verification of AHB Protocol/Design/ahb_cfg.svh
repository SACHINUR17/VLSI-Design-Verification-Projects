class ahb_cfg extends uvm_object;
  `uvm_object_utils(ahb_cfg)
  
  bit tr_print = TRUE; // default: monitor prints rcvd items
  
  bit is_slave = FALSE; // default: master mode
  
  uvm_active_passive_enum is_active = UVM_ACTIVE; // default: active mode, mirrored value of agent's attribute

  
  // master busy or slave latency attributes
  rand uint32_t min_rd_busy;
  rand uint32_t max_rd_busy;
  rand uint32_t min_wr_busy;
  rand uint32_t max_wr_busy;

  function new(string name = "ahb_mst_cfg");
    super.new(name);
  endfunction // new


  constraint slv_latencies_c {
    min_rd_busy dist { 0 :/ 50, [1:5]  :/ 50 };
    min_wr_busy dist { 0 :/ 50, [1:5]  :/ 50 };
    max_rd_busy dist { 0 :/ 25, [1:5]  :/ 25, [6:10] :/ 50 };
    max_wr_busy dist { 0 :/ 25, [1:5]  :/ 25, [6:10] :/ 50 };
    max_rd_busy >= min_rd_busy;
    max_wr_busy >= min_wr_busy;
  }

  function string convert2string();
    return $sformatf("AHB_CFG: Slave=%b, Active=%s, Busy: RD => [%0d : %0d], WR => [%0d : %0d]", is_slave, is_active.name(), min_rd_busy, max_rd_busy, min_wr_busy, max_wr_busy);
  endfunction // convert2string
  
endclass // ahb_cfg
