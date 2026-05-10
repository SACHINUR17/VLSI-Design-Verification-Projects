program axi_tb(axi_if axi_if_inst_1);
	axi_env env_inst;
	int testname;
	initial begin //This will get exectured by default
		$value$plusargs("testname=%d", testname);
		env_inst = new(axi_if_inst_1);
		env_inst.run(testname);
	end
	final begin //called just at the end of simulation
		$display("Test completed");
	end
endprogram
