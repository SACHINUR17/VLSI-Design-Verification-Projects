class axi_cov;
	event tx_mon2cov_e;
	mailbox #(axi_transaction) mbox_mon2cov;
	axi_transaction tx;
	event sample_cg;
  function new (mailbox #(axi_transaction) mbox_mon2cov, event tx_mon2cov_e);
	  this.mbox_mon2cov = mbox_mon2cov;
	  this.tx_mon2cov_e = tx_mon2cov_e;
  endfunction

  task run();
  while (1) begin
	  //wait (tx_mon2cov_e.triggered());
	  tx = new();
	  mbox_mon2cov.get(tx); //mailbox get is a blocking method
	  axi_cg.sample(); //sample is SV keyword to trigger one time covering of covergroup
	  //-> sample_cg;
  end
  endtask

  covergroup axi_cg@(sample_cg);
	  AWBURST_CP : coverpoint tx.awburst {
		  bins fixed_b : [FIXED]; //3 //50%
		  bins incr_b : [INCR]; //1 //16.6%
		  bins wrap_b : [WRAP]; //2 //33.3%
	  };
	  AWLEN_CP : coverpoint tx.awlen { //16 bins
	  	bins len_0 : [0];
	  	bins len_low : [1:5]; //min hit = 2
	  	bins len_mid : [6:10];
	  	bins len_up : [11:14];
	  	bins len_high : [15];
	  };
	  //cross coverage
	  cross AWBURST_CP, AWLEN_CP; //15 bins
  endgroup
/*	covergroup axi_if_cg @(posedge axi_if_inst.aclk);
		//coverpoint
		AWADDR_CP : coverpoint axi_if_inst.awaddr {
			bins LOW_R : [0 : 1000];
			bins MED_R: [1001 : 2000];
			bins HIGH_R : [2001 : 3000];
			bins VHIGH_R : [3001 : 4000];
		} iff (axi_if_inst.awvalid == 1'b1 && axi_if_inst.awready == 1'b1);
		AWBURST_CP : coverpoint axi_if_inst.awburst {
			bins FIXED : [2'b00];
			bins INCR: [2'b01];
			bins WRAP : [2'b1];
			illegal_bins RESV : [2'b11]; //If bins is illegal_bins then if this case happens then simulation to stopped
			//ignore_bins RESV : [2'b11]; //If bins is illegal_bins then if this case happens then simulation to stopped
			//if ignore_bins is declared then this won't be covered, does not go into coverage calculation, simulation will proceed
		} iff (axi_if_inst.awvalid == 1'b1 && axi_if_inst.awready == 1'b1) ;
		cross AWADDR_CP, AWBURST_CP; //12 bins
		//transition coverage can also be implented
	endgroup */
endclass
