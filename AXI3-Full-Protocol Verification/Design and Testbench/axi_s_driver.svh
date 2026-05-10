class axi_s_driver#(int WIDTH=32,SIZE=3) extends uvm_driver#(axi_m_Sequence_Item#(WIDTH,SIZE));
  virtual interface axi_intf#(WIDTH,SIZE)   intf;
 `uvm_component_param_utils(axi_s_driver#(WIDTH,SIZE))
  int AWID_queue[$];
  int AWADDR_queue[$];
  int ARID_queue[$];
  int ARADDR_queue[$];
  int AWSIZE_queue[$];
  bit [WIDTH-1:0] wdata;
  bit [WIDTH-1:0] rdata;
  bit [WIDTH-1:0] awaddr,araddr;
   
  byte unsigned   m_mem[1024];   //4294967296
  axi_m_Sequence_Item#(WIDTH,SIZE) tx;
  
  function new(string name="axi_s_driver",uvm_component parent);
    super.new(name,parent);
    tx=new;    
  endfunction : new 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase 

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual interface axi_intf#(WIDTH,SIZE))::get(this, "", "intf", intf))
     `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".intf"})
  endfunction : connect_phase


// UVM run() phase
  task run_phase(uvm_phase phase);
  //phase.raise_objection (phase);
    fork
      sent_addr_write_trx();
      sent_data_write_trx();
      sent_resp_write_trx();

      sent_addr_read_trx();
      sent_data_read_trx();
      reset_signals();
     // wait (intf.WLAST)repeat(4)@(posedge intf.clk);
    join_any
  //phase.drop_objection(phase);
  endtask : run_phase

// Reset all slave signals
  task reset_signals();
      forever begin
        @(negedge intf.RESET);
        `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
        intf.AWREADY <= 0;
        intf.WREADY  <= 0;
        intf.BID     <= 0;
        intf.RVALID  <= 0;
        intf.BVALID  <= 0;
      end
  endtask : reset_signals
  
  task sent_addr_write_trx();
    @(posedge intf.clk);
    forever begin
    int unsigned i=0;
      intf.AWREADY <= 1'b0;
      repeat($urandom_range(2,3)) @(posedge intf.clk);
  
      intf.AWREADY <= 1'b1;
      @(posedge intf.clk);
  
      while(!intf.AWVALID) @(posedge intf.clk);
      //tx.AWADDR = intf.AWADDR;
      //tx.AWID   = intf.AWID;
      //tx.AWSIZE = intf.AWSIZE;
      tx.AWLEN  = intf.AWLEN;
      tx.AWBURST= intf.AWBURST;
      if(intf.AWBURST==0'b00)
        begin
          repeat((intf.AWLEN+1)*(2**intf.AWSIZE))  
          AWADDR_queue.push_back(intf.AWADDR);
        end
      else if (intf.AWBURST==2'b01)
        begin
          repeat((intf.AWLEN+1)*(2**intf.AWSIZE))begin
          AWADDR_queue.push_back(intf.AWADDR+i);
          i++; end
        end
      else if (intf.AWBURST==2'b10)
        begin
          awaddr=(intf.AWADDR/(2**intf.AWSIZE))*(2**intf.AWSIZE);
          repeat((intf.AWLEN+1)*(2**intf.AWSIZE))begin
          AWADDR_queue.push_back(awaddr+i);
          i++;end
        end
      else `uvm_error("axi_s_driver","AWBURST value can't be 2'b11")
      repeat(intf.AWLEN+1) AWSIZE_queue.push_back(intf.AWSIZE);
      AWID_queue.push_back(intf.AWID);
    end
  endtask : sent_addr_write_trx
  
  task sent_data_write_trx();
    forever begin
      intf.WREADY <= 1'b0;
      repeat($urandom_range(4,6)) @(posedge intf.clk);
  
      intf.WREADY <= 1'b1;
      @(posedge intf.clk);
  
      while(!intf.WVALID ) @(posedge intf.clk);
      tx.WID  = intf.WID;
      tx.WLAST= intf.WLAST;
      
      tx.AWSIZE = AWSIZE_queue.pop_front();
      wdata=intf.WDATA;
      for(int i=0;i<(2**tx.AWSIZE);i++)
      begin
        tx.AWADDR=AWADDR_queue.pop_front();
	if(intf.WSTRB[i])
        begin
          m_mem[tx.AWADDR]=wdata[8*i +:8];
          `uvm_info ("Slave_Driver",$psprintf("AWADDR data [%h]=%h",tx.AWADDR,m_mem[tx.AWADDR]),UVM_HIGH); 
        end
      end
      
    //  intf.WREADY = 1'b1;
    //  @(negedge intf.clk);
    end
  endtask : sent_data_write_trx
  
  task sent_resp_write_trx();
    intf.BVALID = 1'b0;
    forever begin
     @(posedge intf.clk iff (intf.WVALID == 1'b1 && intf.WREADY == 1'b1 && intf.WLAST == 1'b1))
        begin
	  tx.AWID = AWID_queue.pop_front();
          @(posedge intf.clk);
          intf.BVALID <= 1'b1;
          intf.BID    <= tx.AWID;
          intf.BRESP  <= 0'b00; // OKAY
  
          while(!intf.BREADY) @(posedge intf.clk);
          intf.BVALID <= 1'b0;
          @(posedge intf.clk);
        end
    end
  endtask : sent_resp_write_trx
  
  task sent_addr_read_trx();
    forever begin
      int unsigned i=0;
      intf.ARREADY <= 1'b0;
      while(!intf.ARVALID) @(posedge intf.clk);
      repeat($urandom_range(2,3)) @(posedge intf.clk);
  
      intf.ARREADY <= 1'b1;
      @(posedge intf.clk);
  
      //while(!intf.ARVALID) @(posedge intf.clk);
      //tx.ARID    = intf.ARID;
      //tx.ARADDR  = intf.ARADDR;
      //tx.ARLEN   = intf.ARLEN;
      //tx.ARSIZE  = intf.ARSIZE;
      tx.ARBURST = intf.ARBURST;
      case(intf.ARBURST)
        2'b00 : repeat((intf.ARLEN+1)*(2**intf.ARSIZE)) ARADDR_queue.push_back(intf.ARADDR);
        2'b01 : repeat((intf.ARLEN+1)*(2**intf.ARSIZE)) begin ARADDR_queue.push_back(intf.ARADDR+i); i++; end
        2'b10 : begin 
                 // araddr=(intf.ARADDR/(2**intf.ARSIZE))*(2**intf.ARSIZE);
                  repeat((intf.ARLEN+1)*(2**intf.ARSIZE))begin
                    ARADDR_queue.push_back(((intf.ARADDR/(2**intf.ARSIZE))*(2**intf.ARSIZE))+i);
                    i++; end
                end 
        default: `uvm_error("axi_s_driver","ARBURST value can't be 2'b11")
      endcase	
      ARID_queue.push_back(intf.ARID);
      ARID_queue.push_back(intf.ARLEN);
      ARID_queue.push_back(intf.ARSIZE);
    end
  endtask : sent_addr_read_trx
  
  // sent data read trx
  task sent_data_read_trx();
    axi_m_Sequence_Item#(WIDTH,SIZE) t_trx;
    int unsigned i = 0;
    intf.RVALID = 1'b0; 
    @(posedge intf.clk);
    @(posedge intf.clk);
    forever begin
        repeat(ARID_queue.size()/3) //@(posedge intf.clk);   
	begin
          i = 0;
          tx.ARID = ARID_queue.pop_front();
          tx.ARLEN= ARID_queue.pop_front();  
          tx.ARSIZE= ARID_queue.pop_front();  
             while (i<=tx.ARLEN) 
               begin
                 intf.RVALID  <= 1'b1;
                 for(int i=0;i<(2**tx.ARSIZE);i++)
                 begin
                   tx.ARADDR=ARADDR_queue.pop_front();
                   rdata[8*i +:8]= m_mem[tx.ARADDR];
                   `uvm_info ("Slave_Driver",$psprintf("ARADDR data [%h]=%h",tx.ARADDR,m_mem[tx.ARADDR]),UVM_HIGH); 
                 end

                 `uvm_info ("Slave_Driver",$psprintf("rdata = %h",rdata),UVM_HIGH); 
                 intf.RDATA   <= rdata;
                 intf.RID     <= tx.ARID;
                 intf.RRESP   <= 2'b00; // OKAY
                 intf.RLAST   <= (i==tx.ARLEN && i != 0)? 1'b1 : 1'b0;
                 @(posedge intf.clk);
		  while(!intf.RREADY) @(posedge intf.clk);
                   i = i+1;
                   //if(i<=tx.ARLEN) tx.ARADDR=ARADDR_queue.pop_front();
                  intf.RVALID <= 1'b0;
                  @(posedge intf.clk);
               end
        end
          intf.RVALID <= 1'b0;
          intf.RLAST  <= 1'b0;
          @(posedge intf.clk);
        end
  endtask : sent_data_read_trx
  
endclass
