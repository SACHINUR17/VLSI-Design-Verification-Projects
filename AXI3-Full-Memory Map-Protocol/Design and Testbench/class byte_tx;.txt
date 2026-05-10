class byte_tx;
	bit [7:0] data;
	bit [31:0] addr;
	bit wr_rd;
	function print();
		$display("wr_rd = %h, addr = %h, data = %h", wr_rd, addr, data);
	endfunction
	function compare(byte_tx tx);
		if (wr_rd == tx.wr_rd && data == tx.data && addr == tx.addr) begin
		end
		else begin
			$display("ERROR : Tx comparision failed");
			this.print();
			tx.print();
		end
	endfunction
endclass
