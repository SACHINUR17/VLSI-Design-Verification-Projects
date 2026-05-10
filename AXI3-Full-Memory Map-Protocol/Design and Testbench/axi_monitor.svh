class axi_monitor;
	axi_transaction tx_wr_arr[int]; //associative array
	axi_transaction tx_rd_arr[int]; //associative array
	axi_transaction tx_inst;
        virtual axi_if if_inst;
	int tx_wr_data_size;
	int tx_rd_data_size;
        mailbox#(axi_transaction) mbox_mon_ref;

	function new(virtual axi_if if_inst_1, mailbox #(axi_transaction) mbox_mon_ref);
		this.if_inst = if_inst_1;
		this.mbox_mon_ref = mbox_mon_ref;
	endfunction

	//1. Observe interface
	//2. validate transaction
	//3. convert the transaction to object level
	//4. Put the transaction in to mailbox for reference model & functional coverage
	task run();
	  $display("axi_monitor :: run");
	  while(1) begin
		  @(posedge if_inst.aclk);
		  if (if_inst.awvalid == 1'b1 && if_inst.awready == 1'b1) begin
			  $display ("axi_monitor :: write address detected");
			  tx_wr_arr[if_inst.awid] = new();
			  tx_inst = new();
			  tx_inst.wr_rd = WRITE;
			  tx_inst.awid = if_inst.awid;
			  tx_inst.awaddr = if_inst.awaddr;
			  tx_inst.awlen = if_inst.awlen;
			  tx_inst.awsize = if_inst.awsize;
			  tx_inst.awburst = if_inst.awburst;
			  tx_inst.awlock = if_inst.awlock;
			  tx_inst.awprot = if_inst.awprot;
			  tx_wr_arr[if_inst.awid] = tx_inst; //tx_inst is not complete, it is only filled for write address phase
		  end
		  if (if_inst.wvalid == 1'b1 && if_inst.wready == 1'b1) begin
			$display ("axi_monitor :: write data detected");
			tx_wr_arr[if_inst.wid].wdata.push_back(if_inst.wdata);
			tx_wr_arr[if_inst.wid].wstrb.push_back(if_inst.wstrb);
		  end
		  if (if_inst.bvalid == 1'b1 && if_inst.bready == 1'b1) begin
			  $display ("axi_monitor :: write resp detected");
			  tx_wr_arr[if_inst.bid].bresp = if_inst.bresp;
			  //At this point you are done with populating one transaction completely
			  mbox_mon_ref.put(tx_wr_arr[if_inst.bid]);
			  $display("#############   Putting Write Tx in to Mailbox  #################");
			  tx_wr_arr[if_inst.bid].print();
			  //write2refmodel_mbox(tx_wr_arr[if_inst.bid]);
		  end
		  if (if_inst.arvalid == 1'b1 && if_inst.arready == 1'b1) begin
			  $display("arid = %d", if_inst.arid);
			  tx_rd_arr[if_inst.arid] = new();
			  tx_inst = new();
			  tx_inst.wr_rd = READ;
			  tx_inst.arid = if_inst.arid;
			  tx_inst.araddr = if_inst.araddr;
			  tx_inst.arlen = if_inst.arlen;
			  tx_inst.arsize = if_inst.arsize;
			  tx_inst.arburst = if_inst.arburst;
			  tx_inst.arlock = if_inst.arlock;
			  tx_inst.arprot = if_inst.arprot;
			  tx_rd_arr[if_inst.arid] = tx_inst;
		  end
		  if (if_inst.rvalid == 1'b1 && if_inst.rready == 1'b1) begin
			$display("rid = %d", if_inst.rid);
			tx_rd_arr[if_inst.rid].rdata.push_back(if_inst.rdata);
			tx_rd_arr[if_inst.rid].rresp.push_back(if_inst.rresp);
			if (if_inst.rlast == 1'b1) begin
			  $display("#############   Putting Read Tx in to Mailbox  #################");
			  tx_rd_arr[if_inst.rid].print();
			  mbox_mon_ref.put(tx_rd_arr[if_inst.rid]);
		        end
		  end
	  end
	endtask
endclass
