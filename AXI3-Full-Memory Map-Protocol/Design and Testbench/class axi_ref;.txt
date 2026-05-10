class axi_ref;
  mailbox#(axi_transaction) mbox_mon_rm;
  //byte_tx byte_inst;
  axi_transaction tx;
  event mon_tx_valid_e;
  mailbox#(byte_tx) mbox_ref2ckr;
	function new(mailbox#(axi_transaction) mbox_mon_rm, mailbox#(byte_tx) mbox_ref2ckr, event mon_tx_valid_e);
	    this.mbox_mon_rm = mbox_mon_rm;
	    this.mon_tx_valid_e = mon_tx_valid_e;
	endfunction

	task run(); //100 txs
		//Get the transaction from mailbox mbox_mon_rm.get(tx_inst_name);
		//tx_inst_name will have lot of bytes, can be from 1byte, 64 bytes
		//to convert 1 axi_transaction to byte_tx, you need to have a function, which will understand awlen, byrst size, type, then create byte_tx, give this to checker for comparision
		/*
		wait (mbox_mon_rm.size() > 0);
		#1;
		while (mbox_mon_rm.size() > 0) begin
			//convert axi to byte level
		end  //gets over immediately after 1 st transation
		*/
       	        while (1) begin //assumption: monitor will trigger mon_tx_valid_e for each valid tx put in to mailbox
			wait (mon_tx_valid_e.triggered());
			tx = new();
			mbox_mon_rm.get(tx);
			convert_axi2bytelevel(tx); //function to convert axi to byte level
	        end
	endtask
	//Convert bigger transaction into byte level transaction
	function convert_ocp2bytelevel(axi_transaction tx);
		->compare_tx_e; //this event will tell chkr when to start comparision
	endfunction
	function convert_axi2bytelevel(axi_transaction tx);
		byte_tx tx_b;
		case (tx.awburst)
			FIXED : begin
				case (tx.wr_rd)
					WRITE : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							tx_b.wr_rd = tx.wr_rd;;
							if (tx.wstrb[0]) begin
								tx_b = new();
								tx_b.addr = tx.awaddr;
								tx_b.data = tx.wdata[i][7:0];
								mbox_ref2ckr.put(tx_b);
							end
							if (tx.wstrb[1]) begin
								tx_b = new();
								tx_b.addr = tx.awaddr;
								tx_b.data = tx.wdata[i][15:8];
								mbox_ref2ckr.put(tx_b);
							end
							if (tx.wstrb[2]) begin
								tx_b = new();
								tx_b.addr = tx.awaddr;
								tx_b.data = tx.wdata[i][23:16];
								mbox_ref2ckr.put(tx_b);
							end
							if (tx.wstrb[3]) begin
								tx_b = new();
								tx_b.addr = tx.awaddr;
								tx_b.data = tx.wdata[i][31:24];
								mbox_ref2ckr.put(tx_b);
							end
							/*
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
								//input is tx
								tx_b = new();
								tx_b.addr = tx.awaddr;
								//wstrb = b3, b2, b1, b0
								if (tx.wstrb[0]) begin
								  tx_b.data = tx.wdata[i][7:0];
								end
								else if (tx.wstrb[1]) begin
								  tx_wdata[i]>>8;
								  tx_b.data = tx.wdata[i][7:0];
								end
								else if (tx.wstrb[2]) begin
								  tx_wdata[i]>>8;
								  tx_wdata[i]>>8;
								  tx_b.data = tx.wdata[i][7:0];
								end
								else if (tx.wstrb[3]) begin
								  tx_wdata[i]>>8;
								  tx_wdata[i]>>8;
								  tx_wdata[i]>>8;
								  tx_b.data = tx.wdata[i][7:0];
								end

								tx_wdata[i]>>8;
								mbox_ref2ckr.put(tx_b);
							end */
						end
					end
					READ : begin
						for (int i = 0; i <= tx.arlen; i++) begin
							for (int j = 0; j < 2**tx.arsize; j++) begin//0 -> 1, 1-> 2
								tx_b = new();
								tx_b.addr = tx.addr;
								tx_b.wr_rd = READ;
								tx_b.data = tx.rdata[i][7:0];
								tx.rdata[i]>>8;
								mbox_ref2ckr.put(tx_b);
							end
						end
					end
					WRITE_READ : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
							end
						end
					end
				endcase
			end
			INCR : begin
				case (tx.wr_rd)
					WRITE : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
							end
						end
					end
					READ : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
							end
						end
					end
					WRITE_READ : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
							end
						end
					end
				endcase
			end
			WRAP : begin
				case (tx.wr_rd)
					WRITE : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
							end
						end
					end
					READ : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
							end
						end
					end
					WRITE_READ : begin
						for (int i = 0; i <= tx.awlen; i++) begin
							for (int j = 0; j < 2**tx.awsize; j++) begin//0 -> 1, 1-> 2
							end
						end
					end
				endcase
			end
		endcase
	endfunction
endclass
