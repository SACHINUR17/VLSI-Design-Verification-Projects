//enum { };
class axi_gen;
  mailbox#(axi_transaction) mbox_req;
  mailbox#(axi_tx_resp) mbox_res;
  axi_transaction  axi_tx;
  axi_tx_resp  axi_tx_resp_inst;
  axi_transaction axi_tx_temp;
  axi_tx_resp axi_tx_res;
  axi_transaction axi_tx_sa[5];
  bit compare_f;

  function new (mailbox#(axi_transaction) mbox_req, mailbox#(axi_tx_resp) mbox_res);
    this.mbox_req = mbox_req; //I am not doing new on mbox_req again, Doing new will create another memory location(which is not desired)
    this.mbox_res = mbox_res;
  endfunction

  task run(integer testname);
	  bit [31:0] temp_addr;
	  bit [31:0] t_addr;
	  bit [3:0] t_len;

	  /*for (int i = 0; i < 10; i++) begin
		  axi_tx = new();
		  assert(axi_tx.randomize()); //if the value inside () is 1, assertion success, else fail, ex: (A==B)
		  mbox_req.put(axi_tx);
		  $display("Putting axi_tx in to mailbox");
		  axi_tx.print();
	  end */
	 int burst_len_l = 0;
	 bit [1:0] burst_type_l = 0;
	  case (testname) 
		  1 : begin
	  		for (int i = 0; i < 16; i++) begin
		  		axi_tx = new(); //creation
				  assert(axi_tx.randomize() with {awlen == burst_len_l; arlen == burst_len_l;}); //if the value inside () is 1, assertion success, else fail, ex: (A==B)
				  burst_len_l++;
				  mbox_req.put(axi_tx); //Putting tx in to mailbox, BFM will see this tx
				  $display("Putting axi_tx in to mailbox");
				  //axi_tx.print();
	  		end
		  end
		  2 : begin
	  		for (int i = 0; i < 20; i++) begin
		  		axi_tx = new();
				  assert(axi_tx.randomize() with {awburst == burst_type_l; arburst == burst_type_l;});
				  burst_type_l++;
				  mbox_req.put(axi_tx);
				  $display("Putting axi_tx in to mailbox");
	  		end
		  end
		  3 : begin
		  		axi_tx = new();
				assert(axi_tx.randomize() with {awaddr == 1000; wr_rd == 1; awlen == 0;});
				mbox_req.put(axi_tx);
		  		axi_tx = new();
				assert(axi_tx.randomize() with {awaddr == 2000; wr_rd == 1; awlen == 0;});
				mbox_req.put(axi_tx);
		  		axi_tx = new();
				assert(axi_tx.randomize() with {araddr == 1000; wr_rd == 0; arlen == 0;});
				mbox_req.put(axi_tx);
		  		axi_tx = new();
				assert(axi_tx.randomize() with {araddr == 2000; wr_rd == 0; arlen == 0;});
				mbox_req.put(axi_tx);
		  end
		  4 : begin //WR_RD_SAME_ADDR_10
		   for (int i = 0; i < 10; i++) begin
		     axi_tx = new();
		     assert(axi_tx.randomize() with {wr_rd == WRITE; awburst == INCR;});
		     mbox_req.put(axi_tx);
		     temp_addr = axi_tx.awaddr;
			//READ at same addr, INCR
		     axi_tx = new();
		     assert(axi_tx.randomize() with {wr_rd == READ; arburst == FIXED; araddr == temp_addr;});
		     mbox_req.put(axi_tx);
		   end
		  end
		  5 : begin
		   for (int i = 0; i < 1; i++) begin
		     axi_tx = new();
		     assert(axi_tx.randomize() with {wr_rd == WRITE; awaddr inside {[1000:2000]};}) $display("PASSED"); 
		     else $display("FAILED");
		     mbox_req.put(axi_tx);
		     t_addr = axi_tx.awaddr;
		     t_len = axi_tx.awlen;

		     axi_tx = new();
		     assert(axi_tx.randomize() with {wr_rd == READ; araddr == t_addr; arlen == t_len;}) $display("PASSED"); 
		     else $display("FAILED");
		     mbox_req.put(axi_tx);
	     	   end
		  end
		  6 : begin //WRITE_5TX_READ_5TX_SAME_ADDR
		    for (int i = 0; i < 5; i++) begin
			    axi_tx = new();
			    axi_tx.randomize() with {wr_rd == WRITE;};
			    //In top declare array of axi_tx_sa
			    axi_tx.copy(axi_tx_sa[i]);
			    mbox_req.put(axi_tx);
		    end
		    for (int i = 0; i < 5; i++) begin
			    axi_tx = new();
			    axi_tx_temp = axi_tx_sa[i];
			    axi_tx.randomize() with {wr_rd == READ;
		                                     araddr == axi_tx_temp.awaddr; 
		                                     arlen == axi_tx_temp.awlen; 
		                                     arburst == axi_tx_temp.awburst; 
		                                     arsize == axi_tx_temp.awsize; 
		                                    };
			    mbox_req.put(axi_tx);
			    mbox_res.get(axi_tx_res); //I need to get rdata[] from BFM(it collects rdata from read tx)
			    if (axi_tx_res.rdata.size() != axi_tx_temp.wdata.size()) compare_f = 1'b0;
			    foreach (axi_tx_res.rdata[i]) begin
				    if (axi_tx_res.rdata[i] != axi_tx_temp.wdata[i]) begin
					    compare_f = 1'b0;
				    end
			    end
			    $display("Compare Status = %h", compare_f);
		    end
		  end
	  endcase
  endtask
endclass 
