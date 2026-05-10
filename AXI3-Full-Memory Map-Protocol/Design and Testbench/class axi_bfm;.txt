class axi_bfm;
  virtual axi_if axi_if_inst;
  mailbox#(axi_transaction) mbox_req;
  mailbox#(axi_tx_resp) mbox_res;
  axi_transaction  axi_tx;
  axi_transaction  axi_tx_drv;
  axi_tx_resp  axi_tx_resp_inst;

  semaphore smp_aw;
  semaphore smp_w;
  semaphore smp_ar;

  function new (virtual axi_if axi_if_inst,
                mailbox#(axi_transaction) mbox_req, mailbox#(axi_tx_resp) mbox_res);
    this.axi_if_inst = axi_if_inst;
    this.mbox_req = mbox_req;
    this.mbox_res = mbox_res;
    smp_aw = new(1); //semaphore of 1 key
    smp_w = new(1); //semaphore of 1 key
    smp_ar = new(1); //semaphore of 1 key
  endfunction
  
  task run();
    fork
    while(1) begin //run for 10 times
      axi_tx = new();
      mbox_req.get(axi_tx); //Get the Tx from MBOX
      axi_tx.print();
      fork
      begin
        #axi_tx.tx_delay;
        drive_request(axi_tx); //Drive Tx on to the interface
      end
      //join_none
      join
      #200ns;
    end
    while(1) begin
	    @(negedge axi_if_inst.bvalid);
	    axi_if_inst.bready <= 0;
    end
    while(1) begin
	    @(negedge axi_if_inst.rvalid);
	    axi_if_inst.rready <= 0;
    end
    join
  endtask

  task drive_request(axi_transaction axi_tx); //This is where understanding timing diagram is important
     axi_transaction  axi_tx_drv;
     axi_tx_drv = new();
     axi_tx.copy(axi_tx_drv);
     //axi_tx_drv.print();
     if (axi_tx_drv.wr_rd == WRITE) begin
	     $display("######### WRITE BEGIN  #########");
       write_addr(axi_tx_drv);
       write_data(axi_tx_drv);
       write_resp(axi_tx_drv);
	     $display("######### WRITE END  #########");
     end
     if (axi_tx_drv.wr_rd == READ) begin
	     $display("######### READ BEGIN  #########");
     //if (axi_tx_drv.wr_rd == READ) begin
       read_addr(axi_tx_drv);
       read_data(axi_tx_drv);
	     $display("######### READ END  #########");
     end
     if (axi_tx_drv.wr_rd == READ_WRITE) begin
     //if (axi_tx_drv.wr_rd == READ_WRITE) begin
	     $display("######### WRITE_READ BEGIN  #########");
       fork
         begin
         write_addr(axi_tx_drv);
         write_data(axi_tx_drv);
         write_resp(axi_tx_drv);
         end
         begin
         read_addr(axi_tx_drv);
         read_data(axi_tx_drv);
         end
       join
	     $display("######### WRITE_READ END  #########");
     end
  endtask

  task write_addr(axi_transaction axi_tx);
      smp_aw.get(1); //get 1 key
      @(axi_if_inst.axi_cb);
      axi_if_inst.awvalid = 1'b1;  //clocking block will take care of driving it appropriately
                                 //this will be sampled by DUT, it will response back by asserting awready
      axi_if_inst.awaddr = axi_tx.awaddr;
      axi_if_inst.awlen = burst_len_e'(axi_tx.awlen); //Static casting
      axi_if_inst.awburst = burst_type_e'(axi_tx.awburst); //Static casting
      axi_if_inst.awsize = burst_size_e'(axi_tx.awsize); //Static casting
      axi_if_inst.awprot = axi_tx.awprot;
      axi_if_inst.awlock = lock_type_e'(axi_tx.awlock); //Static casting
      axi_if_inst.awcache = axi_tx.awcache;
      axi_if_inst.awid = axi_tx.awid;
      wait (axi_if_inst.awready == 1'b1); //Blocking statement which will wait for awaready assertion
      @(axi_if_inst.axi_cb);
      axi_if_inst.awvalid = 1'b0;  //clocking block will take care of driving it appropriately
      smp_aw.put(1); //free the semaphore key
  endtask

  task write_data(axi_transaction axi_tx_drv);
      smp_w.get(1);
      for (int i = 0; i <= axi_tx_drv.awlen; i++) begin  //{
	@(axi_if_inst.axi_cb);
        axi_if_inst.wvalid = 1'b1;
        axi_if_inst.wid = axi_tx_drv.wid;
        axi_if_inst.wdata = axi_tx_drv.wdata[i];
        axi_if_inst.wstrb = axi_tx_drv.wstrb[i];
	if ( i == axi_tx_drv.awlen) begin
          axi_if_inst.wlast = 1'b1;
	end
	wait (axi_if_inst.wready == 1'b1);
	@(axi_if_inst.axi_cb);
	//#10;
        axi_if_inst.wvalid = 1'b0;
	axi_if_inst.wlast = 1'b0;
      end  //}
      smp_w.put(1); //free the semaphore key
  endtask

  task write_resp(axi_transaction axi_tx);
      bit resp_valid_f = 1'b0;
      axi_tx_resp_inst = new();
      while(resp_valid_f != 1'b1) begin
        @(axi_if_inst.axi_cb);
	if (axi_if_inst.bvalid == 1'b1) begin //write response comes from slave, wait for it to validate data
		$display("#####  bvalid asserted  #####");
          axi_if_inst.bready = 1'b1;
          axi_tx_resp_inst.bid = axi_if_inst.bid; //axi_tx_resp_inst will be given to scenario generator
          axi_tx_resp_inst.bresp = axi_if_inst.bresp;
          if (axi_if_inst.bresp != OKAY && axi_if_inst.bresp != EXOKAY) begin
            $display ("ERROR : DUT responded with Error, Error type = %h", axi_if_inst.bresp);	       
          end
	  resp_valid_f = 1'b1;
          //axi_if_inst.bready = 1'b0;
        end
      end
      #5;
  endtask

  task read_addr(axi_transaction axi_tx);
      smp_ar.get(1);
      @(axi_if_inst.axi_cb);
      axi_if_inst.arvalid = 1'b1;  //clocking block will take care of driving it appropriately
      axi_if_inst.araddr = axi_tx.araddr;
      axi_if_inst.arlen = burst_len_e'(axi_tx.arlen);
      axi_if_inst.arburst = burst_type_e'(axi_tx.arburst);
      axi_if_inst.arsize = burst_size_e'(axi_tx.arsize);
      axi_if_inst.arprot = axi_tx.arprot;
      axi_if_inst.arlock = lock_type_e'(axi_tx.arlock);
      axi_if_inst.arcache = axi_tx.arcache;
      axi_if_inst.arid = axi_tx.arid;
      wait (axi_if_inst.arready == 1'b1); //Blocking statement which will wait for awaready assertion
      #5;
      axi_if_inst.arvalid = 1'b0;  //clocking block will take care of driving it appropriately
      smp_ar.put(1); //put 1 key
  endtask

  task read_data(axi_transaction axi_tx_drv);
    axi_tx_resp_inst = new();
    for (int i = 0; i <= axi_tx_drv.arlen; i++) begin  //{
      @(axi_if_inst.axi_cb);
      wait (axi_if_inst.rvalid == 1'b1); //write response comes from slave, wait for it to validate data
      axi_if_inst.rready = 1'b1;
      axi_tx_resp_inst.rid = axi_if_inst.rid; //axi_tx_resp_inst will be given to scenario generator
      axi_tx_resp_inst.rdata[i] = axi_if_inst.rdata;
      axi_tx_resp_inst.rresp[i] = axi_if_inst.rresp;
      if (axi_if_inst.rresp != OKAY && axi_if_inst.rresp != EXOKAY) begin
        $display ("ERROR : DUT responded with Error, Error type = %h", axi_if_inst.rresp);
      end
    end
  endtask

endclass

