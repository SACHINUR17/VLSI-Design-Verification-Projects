task start();
	axi_transaction tx_wr_arr[int]; //associative array , int will represent AWID, ARID
	axi_transaction tx_rd_arr[int]; //associative array
        axi_transaction tx = new();
  while(1) begin
	  @(if_inst.axi_cb);
	  if (if_inst.awvalid == 1'b1 && if_inst.awready == 1'b1) begin
		  tx = new();
		  tx.awid = if_inst.awid;
		  tx.awaddr = if_inst.awaddr;
		  tx.awlen = if_inst.awlen;
		  tx.awburst = if_inst.awburst; //cache, prot,.....
		  tx_wr_arr[if_inst.awid] = tx;
	  end
	  if (if_inst.wvalid == 1'b1 && if_inst.wready == 1'b1) begin //takes care of 1 transfer
		  tx = new();
		  tx = tx_wr_arr[if_inst.wid]; //tx has only valid AW information, no wdata and b phase info
		  tx.wdata.push_back(if_inst.wdata);
		  tx.wstrb.push_back(if_inst.wstrb);
		  tx_wr_arr[if_inst.wid] = tx;
	  end
	  if (if_inst.bvalid == 1'b1 && if_inst.bready == 1'b1) begin
		  tx = new();
		  tx = tx_wr_arr[if_inst.bid]; //tx has only valid AW information, no wdata and b phase info
		  tx.bresp = if_inst.bresp;
		  //tx_wr_arr[if_inst.bid] = tx;
		  tx.wr_rd = WRITE;
		  mon2ref_mb.put(tx);
		  tx_wr_arr.delete(if_inst.bid); //1. We have completely captured tx  2. put the tx to mbox  3. deleted from array
	  end
	  if (if_inst.arvalid == 1'b1 && if_inst.arready == 1'b1) begin
		  tx = new();
		  tx.arid = if_inst.arid;
		  tx.araddr = if_inst.araddr;
		  tx.arlen = if_inst.arlen;
		  tx.arburst = if_inst.arburst; //cache, prot,.....
		  tx_rd_arr[if_inst.arid] = tx;
	  end
	  if (if_inst.rvalid == 1'b1 && if_inst.rready == 1'b1) begin
		  tx = new();
		  tx = tx_rd_arr[if_inst.rid]; //tx has only valid AW information, no wdata and b phase info
		  tx.rdata.push_back(if_inst.rdata);
		  tx.rresp.push_back(if_inst.rresp);
		  tx.wr_rd = READ;
		  //tx_rd_arr[if_inst.rid] = tx;
		  mon2ref_mb.put(tx);
		  tx_rd_arr.delete(if_inst.rid); //1. We have completely captured tx  2. put the tx to mbox  3. deleted from array
	  end
  end
endtask
