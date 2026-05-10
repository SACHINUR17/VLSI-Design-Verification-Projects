class axi_env;
//  virtual axi_if axi_if_inst;
  mailbox#(axi_transaction) mbox_req;
  mailbox#(axi_tx_resp) mbox_res;

  mailbox#(axi_transaction) mbox_mon_rm; //creating mailbox
  mailbox#(axi_transaction) mbox_mon_fcov;
  axi_bfm  bfm_inst;
  axi_gen  gen_inst;
  axi_monitor  mon_inst;
  //axi_cov  cov_inst;
  //axi_ref  ref_inst; //This should not be part of VIP
  function new(virtual axi_if axi_if_inst);  //This new gets called from program block
 //   this.axi_if_inst = axi_if_inst;
    this.mbox_req = new();
    this.mbox_res = new();
    this.mbox_mon_rm = new();
    bfm_inst = new(axi_if_inst.bfm, mbox_req, mbox_res); //passing mailbox handle to the lower levels
    gen_inst = new(mbox_req, mbox_res);
    mon_inst = new(axi_if_inst.mon, mbox_mon_rm);
    //cov_inst = new(axi_if_inst);
    //ref_inst = new(mbox_mon_rm);
  endfunction

  task run(int testname);
	  $display("%t : In ENV run", $time);
	  fork
		  bfm_inst.run();
		  gen_inst.run(testname);
		  mon_inst.run();
		  //cov_inst.run();
	  join
	  $display("%t : In ENV run END", $time);
  endtask
endclass
