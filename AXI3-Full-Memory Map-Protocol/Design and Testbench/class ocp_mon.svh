class ocp_mon; //understand OCP interface signals, how to validate OCP wr/rd transfer , figure out when to populate transfer item
	ocp_transaction tx_wr_arr[int]; //associative array
	ocp_transaction tx_rd_arr[int]; //associative array
	ocp_transaction tx_inst;
        virtual ocp_if if_inst;
	int tx_wr_data_size;
	int tx_rd_data_size;
        mailbox#(ocp_transaction) mbox_mon_ref;

	function new(virtual ocp_if if_inst_1, mailbox #(ocp_transaction) mbox_mon_ref);
		this.if_inst = if_inst_1;
		this.mbox_mon_ref = mbox_mon_ref;

	ocp_transaction tx_wr_arr[int]; //associative array
	ocp_transaction tx_rd_arr[int]; //associative array
	ocp_transaction tx_inst;
        virtual ocp_if if_inst;
	int tx_wr_data_size;
	int tx_rd_data_size;
        mailbox#(ocp_transaction) mbox_mon_ref;

	function new(virtual ocp_if if_inst_1, mailbox #(ocp_transaction) mbox_mon_ref);
		this.if_inst = if_inst_1;
		this.mbox_mon_ref = mbox_mon_ref;
	endfunction
endclass

