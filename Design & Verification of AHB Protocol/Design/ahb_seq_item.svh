
// ahb sequence item
class ahb_seq_item extends uvm_sequence_item;
  `uvm_object_utils(ahb_seq_item)
  
  ahb_cfg cfg;
  
  rand addr_t addr;
  rand data_t data[]; // hwdata/hrdata
  rand hsize_e size; // transfer size - size of each beat
  rand uint32_t length;   // transfer length - number of beats, 0-based
  rand kind_e kind;  // write or read
  rand bit wrap;     // wrap or incr
  rand hresp_e resp;
  
  // master/slave busy cycles for each data beat
  // slave write response item uses only busy[0]
  rand int busy[];
  
  
  // TODO: full bus width size for now
  constraint size_c {
    size == WORD;
  }

  // TODO: 32-bit aligned address for now
  constraint addr_aligned_c {
    addr[1:0] == 2'b00;
  }
  
  constraint addr_dist_c {
    addr dist { [0:32'hf] :/ 20, [32'h10:32'hffffffef] :/ 60, [32'hfffffff0:32'hffffffff] :/ 20 };
  }

    
  // TODO: single beat transfers for now 
  constraint length_c {
    length == 0;
  }
  
  constraint data_size_c {
    data.size == length +1;
    busy.size == length +1;
  }
  
  // TODO: non-wrap transfers for now 
  constraint wrap_c {
    wrap == FALSE;
  }
  
  // OKAY response by default
  constraint resp_c {
    resp == OKAY;
  }
  
  // master is not permitted to perform a BUSY transfer immediately after a SINGLE burst
  constraint busy_c {
    foreach(busy[ii]) {
      kind == READ  -> {
        if(length == 0 && cfg.is_slave == FALSE) {
          busy[ii] == 0;
        } else {
          busy[ii] inside { [cfg.min_rd_busy  : cfg.max_rd_busy] };
        }
      }
      kind == WRITE -> {
        if(length == 0 && cfg.is_slave == FALSE) {
          busy[ii] == 0;
        } else {
          busy[ii] inside { [cfg.min_wr_busy : cfg.max_wr_busy] };
        }
      }
    }
  }

      
  // constructor
  function new(string name = "ahb_item");
    super.new(name);
  endfunction // new
  
  function void pre_randomize();
    if(m_sequencer != null) begin
      if(!uvm_config_db#(ahb_cfg)::get(m_sequencer, "", "cfg", cfg)) `error("cfg is not set!")
    end // if
  endfunction // pre_randomize

  function set_cfg(ahb_cfg cfg);
    this.cfg = cfg;
  endfunction // set_cfg

  
  // ahb command attributes to string method for print
  virtual function string cmd2string();
    string str;
    str = $sformatf("AHB_CMD %s: addr=0x%x, size=%s, length=%0d, wrap=%b", kind.name(), addr, size.name(), length, wrap);
    if(kind == WRITE) str = {str, $sformatf(", data=0x%x, busy=%0d", data[0], busy[0])};
    return str;
  endfunction // cmd2str
  
  // ahb response attributes to string method for print
  virtual function string rsp2string();
    string str;
    str = $sformatf("AHB_RSP %s: addr=0x%x resp=%s", kind.name(), addr, resp.name());
    if(kind == READ) str = {str, $sformatf(", data=0x%x, busy=%0d", data[0], busy[0])};
    return str;
  endfunction // cmd2str
  
  // full transaction to string method for print
  virtual function string convert2string();
    return {"\n", cmd2string(), "\n", rsp2string()};
  endfunction // convert2string
  
  // helper method to copy cmd attributes from cmd to rsp
  function void set_cmd_attr(ahb_seq_item rhs);
    `set_trans_attr(kind)
    `set_trans_attr(addr)
    `set_trans_attr(size)
    `set_trans_attr(length)
    `set_trans_attr(wrap)
  endfunction // set_cmd

  // add latency cycles to busy[0]
  function void add_latency(int latency);
    busy[0] += latency;
    `info_high($sformatf("add latency = %0d", latency))
  endfunction // add_latency
          
endclass // ahb_seq_item
