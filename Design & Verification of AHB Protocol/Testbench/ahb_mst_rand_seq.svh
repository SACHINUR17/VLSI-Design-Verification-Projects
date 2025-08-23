class ahb_mst_rand_seq extends ahb_base_seq;
  `uvm_object_utils(ahb_mst_rand_seq)
  
  rand int item_count;

  
  virtual task body();
    ahb_seq_item rsp;
    
    `info($sformatf("item_count = %0d", item_count))
    fork
      // send requests process
      for(int ii = 0; ii < item_count; ii++) begin
        req = ahb_seq_item::type_id::create();
        start_item(req);
        `check_rand(req.randomize())
        finish_item(req);
        `info_high($sformatf("#%0d req - %s", ii, req.cmd2string()))
      end // for
      
      // get responses process
      for(int ii = 0; ii < item_count; ii++) begin
        get_response(rsp);
        `info_high($sformatf("#%0d rsp - %s", ii, rsp.rsp2string()))
      end // for
    join

    #100ns;
  endtask // body

  constraint item_count_c {
    item_count inside { [10 : 20] };
  }
endclass // ahb_mst_rand_seq
