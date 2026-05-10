class axi_tx;
  rand bit [31:0]addr;
  rand bit [31:0]dataQ[$];
  rand bit [3:0]len;
  rand wr_rd_t wr_rd;
  rand brust_size_t brust_size;
  rand bit [3:0] id;
  rand brust_type_t brust_type;
  rand lock_t lock;
  rand bit [2:0] prot;
  rand bit [3:0] cashe;
  rand resp_t resp;
  

  
  constraint dataq_c{dataQ.size()==len+1;}

  constraint rsvd_c {
	  brust_type != RSVD_BRUSTT;
	  lock != RSVD_LOCKT;
  }
  constraint soft_c {
	  soft resp == OKAY;
	  soft brust_size == 2;
	  soft brust_type == INCR;
	  soft prot == 3'b0;
	  soft cashe == 4'b0;
	  soft lock == NORMAL;
  }
  
  function void print();
    $display("###############################");
    $display("####     axi_tx::print     ####");
    $display("###############################");
    $display("addr=%h",addr);
    $display("data=%p",dataQ);
    $display("len=%d",len);
    $display("wr_rd=%s",wr_rd);
    $display("size=%s",brust_size);
    $display("id=%b",id);
    $display("brust=%s",brust_type);   
    $display("lock=%s",lock);   
    $display("prot=%b",prot);
    $display("cashe=%b",cashe);
    $display("resp=%s",resp);  
endfunction
endclass
