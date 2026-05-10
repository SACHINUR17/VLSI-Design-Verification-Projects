class axi_m_wr_Sequence#(int WIDTH=32,SIZE=3) extends uvm_sequence#(axi_m_Sequence_Item#(WIDTH,SIZE));
  
  `uvm_object_param_utils(axi_m_wr_Sequence#(WIDTH,SIZE))
  
  function new(string name="axi_m_wr_Sequence");
  super.new(name);
  endfunction
  
  virtual task body();
    `uvm_create(req)
    req.ARADDR.rand_mode(0);
    req.ARID.rand_mode(0);
    req.ARLEN.rand_mode(0);
    req.ARBURST.rand_mode(0);
    req.ARSIZE.rand_mode(0);
    req.RID.rand_mode(0);
    req.RDATA.rand_mode(0);
    req.arsize.constraint_mode(0);
    req.arburst_val.constraint_mode(0);
    req.arburst.constraint_mode(0);
    req.araddress.constraint_mode(0);
    req.arlen_val.constraint_mode(0);
    `uvm_rand_send_with(req,{req.RW==0;  })  //Write sequence 
  endtask
endclass


class axi_m_rd_Sequence#(int WIDTH=32,SIZE=3) extends uvm_sequence#(axi_m_Sequence_Item#(WIDTH,SIZE));
  
  `uvm_object_param_utils(axi_m_rd_Sequence#(WIDTH,SIZE))
  
  function new(string name="axi_m_rd_Sequence");
  super.new(name);
  endfunction
  
  virtual task body();
    `uvm_create(req)
    req.AWADDR.rand_mode(0);
    req.AWID.rand_mode(0);
    req.AWLEN.rand_mode(0);
    req.AWBURST.rand_mode(0);
    req.AWSIZE.rand_mode(0);
    req.WID.rand_mode(0);
    req.WSTRB.rand_mode(0);
    req.WDATA.rand_mode(0);
    req.arr_size_wr.constraint_mode(0);
    req.same_id_wr.constraint_mode(0);
    req.order.constraint_mode(0);
    req.awsize.constraint_mode(0);
    req.awburst_val.constraint_mode(0);
    req.awlen_val.constraint_mode(0);
    req.awburst.constraint_mode(0);
    req.awaddress.constraint_mode(0);
    //req.Strobe.constraint_mode(0);
    `uvm_rand_send_with(req,{req.RW==1; })  //Read sequence 
  endtask
endclass

