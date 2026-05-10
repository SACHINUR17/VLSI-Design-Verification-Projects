class axi_gen;
  axi_tx tx;
  axi_tx txQ[$];
  task run();
    $display ("axi_gen::run");
case (axi_common::testname)
"test_5_wr" : begin
  repeat(5) begin
    tx=new();
    assert(tx.randomize() with {wr_rd == WRITE;});
    axi_common::gen2bfm.put(tx);
  end
end
"test_5_wr_5_rd" : begin
   for (int i=0; i<5;i++) begin
      tx=new();
      assert(tx.randomize() with {wr_rd == WRITE;});
      axi_common::gen2bfm.put(tx);
      txQ[i] = new tx;
    end
    for (int i=0; i<5;i++) begin
      tx=new();
      assert(tx.randomize() with {wr_rd == READ; addr == txQ[i].addr; len ==txQ[i].len; brust_size == txQ[i].brust_size;});
      axi_common::gen2bfm.put(tx);
    end
  end
endcase
endtask
endclass
