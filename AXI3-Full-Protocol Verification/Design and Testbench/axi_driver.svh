
class axi_m_driver#(int WIDTH=32, SIZE=3) extends uvm_driver#(axi_m_Sequence_Item#(WIDTH,SIZE));
  virtual interface axi_intf#(WIDTH,SIZE)   intf;
  uvm_analysis_port #(axi_m_Sequence_Item#(WIDTH,SIZE)) drv2sb_port;
  axi_m_Sequence_Item#(WIDTH,SIZE)         m_wr_queue[$];
  axi_m_Sequence_Item#(WIDTH,SIZE)         m_rd_queue[$];
  int unsigned                m_num_sent;
  bit [WIDTH-1:0] wdata;
  axi_m_Sequence_Item#(WIDTH,SIZE) tx;
  event                       event_sent_write_trx;
  event                       event_sent_read_trx;

  int unsigned                m_wr_addr_indx = 0;
  int unsigned                m_wr_data_indx = 0;

  int unsigned                m_rd_addr_indx = 0;
  `uvm_component_utils_begin(axi_m_driver#(WIDTH,SIZE))
  `uvm_field_int(m_num_sent,UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name="axi_m_driver",uvm_component parent);
    super.new(name,parent);
  endfunction : new 

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv2sb_port = new("drv2sb_port",this);
  endfunction : build_phase 

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (!uvm_config_db#(virtual interface axi_intf#(WIDTH,SIZE))::get(this, "", "intf", intf))
     `uvm_error("NOVIF",{"virtual interface must be set for: ",get_full_name(),".intf"})
  endfunction : connect_phase
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "in run phase", UVM_DEBUG)
      fork 
        sent_trx_to_seq();
        reset_signals();
        sent_addr_write_trx();
        sent_data_write_trx();
        received_resp_write_trx();
        sent_addr_read_trx();
        received_data_read_trx();
      join
  endtask : run_phase
  
  // Reset all master signals
  task reset_signals();
      forever 
      begin
        @(negedge intf.RESET);
        `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
          intf.AWID   <= 0;
          intf.AWADDR <= 0;
	  intf.ARVALID<= 0;
	  intf.AWVALID<= 0;
	  intf.WVALID <= 0;
      end
  endtask : reset_signals
  
  // get next trx when reset has already done
  task sent_trx_to_seq();
    forever 
    begin
      seq_item_port.get_next_item(req);
      //`uvm_info(get_type_name(), "packet in Driver run_phase", UVM_MEDIUM)         
      //req.print();
      if (req.RW == 1) 
        begin
	  req.WDATA.delete();
          m_rd_queue.push_back(req);
        end 
      else if (req.RW == 0) 
        begin
          m_wr_queue.push_back(req);
        end 
      else 
        begin
         `uvm_error("NOTYPE",{"type not support in sent_trx_to_seq Loop"})
        end

      drv2sb_port.write(req);
    m_num_sent++;
    `uvm_info(get_type_name(), $psprintf("Item %0d Sent ...", m_num_sent), UVM_HIGH)
      /*fork 
        wait (intf.WLAST)repeat(4)@(posedge intf.clk);
        wait (intf.RLAST)repeat(3)@(posedge intf.clk);
      join
      forever 
        @(posedge intf.clk) if(m_wr_data_indx == m_wr_queue.size())wait (intf.WLAST)repeat(4)@(posedge intf.clk);
      forever
        @(posedge intf.clk) if(m_rd_addr_indx == m_rd_queue.size())wait (intf.RLAST)repeat(3)@(posedge intf.clk);
      */

      if(m_num_sent==5)        repeat(5)  @(posedge intf.WLAST)repeat(4)@(posedge intf.clk);
      else if (m_num_sent==9)  repeat(4)  @(posedge intf.RLAST)repeat(4)@(posedge intf.clk);
      else if (m_num_sent==13) begin repeat(4)  @(posedge intf.WLAST)repeat(4)@(posedge intf.clk); repeat(10)@(posedge intf.clk);end
      else if (m_num_sent==17) repeat(4)  @(posedge intf.RLAST)repeat(4)@(posedge intf.clk);
      else if (m_num_sent==20) repeat(3)  @(posedge intf.WLAST)repeat(4)@(posedge intf.clk);
      else if (m_num_sent==23) repeat(3)  @(posedge intf.RLAST)repeat(4)@(posedge intf.clk);
      seq_item_port.item_done();
    end
  endtask : sent_trx_to_seq
  

///##################################
/*
  task sent_trx_to_seq();
    forever 
    begin
      if (m_num_sent==0)
      begin
        seq_item_port.get_next_item(req);
        `uvm_info(get_type_name(), "packet in Driver run_phase", UVM_MEDIUM)         
        req.print();
      end
    if(req) begin
//######## logic for ending of run_phase      
      if (rw_bit != req.RW)
        begin
          if(rw_bit)
            begin
              repeat(read)wait (intf.RLAST)repeat(3)@(posedge intf.clk);
              read=0;
              rw_bit=req.RW;
            end
          else if(!rw_bit)
            begin
              repeat(write)wait (intf.WLAST)repeat(4)@(posedge intf.clk);
              write=0;
              rw_bit=req.RW;
            end
	  else $display("###########");
        end
      else
        begin
          rw_bit=req.RW;
        end
//######### logic for ending of run_phase

    if (req.RW == 1) 
      begin
        m_rd_queue.push_back(req);
	read++;
      end 
    else if (req.RW == 0) 
      begin
        m_wr_queue.push_back(req);
	write++;
      end 
    else 
      begin
       `uvm_error("NOTYPE",{"type not support in Drive Transfer Loop"})
      end


    seq_item_port.item_done();end
    seq_item_port.try_next_item(req);
    if(req==null)
    begin
      fork
      repeat(read)wait (intf.RLAST)repeat(3)@(posedge intf.clk);
      repeat(write)wait (intf.WLAST)repeat(4)@(posedge intf.clk);
      join_any
    end
    else
    begin
      `uvm_info(get_type_name(), "packet in Driver run_phase", UVM_MEDIUM)         
      req.print();
    end
    m_num_sent++;
    `uvm_info(get_type_name(), $psprintf("Item %0d Sent ...", m_num_sent), UVM_HIGH)

  endtask : sent_trx_to_seq
*/
///#################################

  // addr write trx task by event_sent_write_trx.trigger
  task sent_addr_write_trx();
    axi_m_Sequence_Item#(WIDTH,SIZE) m_trx;
    `uvm_info(get_type_name(), "in sent_addr_write_trx", UVM_DEBUG)
    intf.AWVALID = 1'b0;
    forever begin
      // if write trx has existed...
      repeat(m_wr_queue.size()==0) @(posedge intf.clk);

      if (m_wr_addr_indx < m_wr_queue.size()) 
        begin
          m_trx = m_wr_queue[m_wr_addr_indx];
          intf.AWVALID <= 1'b1;
          intf.AWID    <= m_trx.AWID;
          intf.AWADDR  <= m_trx.AWADDR;
          m_trx.AWLEN   =  ((m_trx.WDATA.size%(m_trx.AWSIZE))==0) ? ((m_trx.WDATA.size/(2**m_trx.AWSIZE))-1) : (m_trx.WDATA.size/(2**m_trx.AWSIZE)) ;
          intf.AWLEN   <= ((m_trx.WDATA.size%(m_trx.AWSIZE))==0) ? ((m_trx.WDATA.size/(2**m_trx.AWSIZE))-1) : (m_trx.WDATA.size/(2**m_trx.AWSIZE)) ;
          intf.AWSIZE  <= m_trx.AWSIZE;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
          intf.AWBURST <= m_trx.AWBURST;
         // intf.AWLOCK  <= m_trx.AWLOCK;
         // intf.AWCACHE <= m_trx.AWCACHE;
         // intf.AWPROT  <= m_trx.AWPROT;
         // intf.AWQOS   <= m_trx.AWQOS;
         // intf.AWREG   <= m_trx.AWREG;
          @(posedge intf.clk);
          // hold until AWREADY received
          while (!intf.AWREADY) @(posedge intf.clk);
	  @(negedge intf.clk);
          intf.AWVALID <= 1'b0;
          m_wr_addr_indx += 1;
        end 
      else 
        begin
          `uvm_info(get_type_name(), "in sent_addr_write_trx else part", UVM_DEBUG)                 
          @(posedge intf.clk);
        end
    end
  endtask : sent_addr_write_trx
  
  // data write trx task by event_sent_write_trx.trigger
  task sent_data_write_trx();
    int unsigned  i=0,j=0,k=0;
    axi_m_Sequence_Item#(WIDTH,SIZE)  m_trx;
    `uvm_info(get_type_name(), "in sent_data_write_trx", UVM_DEBUG)
    intf.WVALID = 1'b0;
    forever 
      begin
        repeat(m_wr_queue.size()==0) @(posedge intf.clk);
	@(posedge intf.clk);
	@(posedge intf.clk);
        if (m_wr_data_indx < m_wr_queue.size()) 
	  begin
            m_trx = m_wr_queue[m_wr_data_indx];
            k=0;
            m_trx.AWLEN = ((m_trx.WDATA.size%(m_trx.AWSIZE))==0) ? ((m_trx.WDATA.size/(2**m_trx.AWSIZE))-1) : (m_trx.WDATA.size/(2**m_trx.AWSIZE)) ;
        m_trx.WSTRB= new[m_trx.AWLEN+1];   // define the size of WSTRB using AWLEN+1
            while (i<=m_trx.AWLEN) 
	      begin
                intf.WVALID  <= 1'b1;
                j=0;
                repeat(2**m_trx.AWSIZE) 
                  begin
                    wdata[8*j +:8] = m_trx.WDATA[k];
                    //$display ("daaata %d : %d  %d  %d %d ",j*8+7,j*8,2**m_trx.AWSIZE,m_trx.WDATA.size,m_trx.WDATA.size/2**m_trx.AWSIZE-1);
                    j++; 
                    k++;
                  end
                if (i != m_trx.AWLEN || (m_trx.WDATA.size%(2**m_trx.AWSIZE)==0)) begin  repeat(2**m_trx.AWSIZE) m_trx.WSTRB[i] = {m_trx.WSTRB[i],1'b1}; end
		else 
                  begin
                    repeat(2**m_trx.AWSIZE) m_trx.WSTRB[i] = {m_trx.WSTRB[i],1'b1};
                    repeat((2**m_trx.AWSIZE)-(m_trx.WDATA.size%(2**m_trx.AWSIZE)))m_trx.WSTRB[i]={m_trx.WSTRB[i],1'b0};
                  end 
                intf.WDATA   <= wdata;
                intf.WSTRB   <= m_trx.WSTRB[i]; 
                intf.WID     <= m_trx.WID;
                intf.WLAST   <= (i==m_trx.AWLEN)? 1'b1 : 1'b0;
                @(posedge intf.clk);
                if (intf.WREADY && intf.WVALID)
                i = i+1;
		else k=k-4;
              end
            intf.WVALID <= 1'b0;
            intf.WLAST  <= 1'b0;
            i = 0;
            m_wr_data_indx += 1;
          end 
        else 
	  begin
            `uvm_info(get_type_name(), "in sent_data_write_trx else part", UVM_DEBUG)                 
            @(posedge intf.clk); 
          end
      end
  endtask : sent_data_write_trx
    
  // data resp trx collect resp to trx
  task received_resp_write_trx();
    `uvm_info(get_type_name(), "in received_resp_write_trx", UVM_DEBUG)   
    intf.BREADY = 1'b0;
    forever 
      @(posedge intf.clk iff (intf.WVALID == 1'b1 && intf.WREADY == 1'b1 && intf.WLAST == 1'b1))
        begin
        intf.BREADY <= 1'b0;
          repeat($urandom_range(2,4)) @(posedge intf.clk);
        intf.BREADY <= 1'b1;
        // hold until BVALID received
        while(!intf.BVALID) @(posedge intf.clk);
        @(posedge intf.clk);
        intf.BREADY <= 1'b0;
    end
  endtask : received_resp_write_trx
  
  // addr read trx
  task sent_addr_read_trx();
    axi_m_Sequence_Item#(WIDTH,SIZE) m_trx;
    `uvm_info(get_type_name(), "in sent_addr_read_trx", UVM_DEBUG)  
    intf.ARVALID = 1'b0;
    forever 
      begin
        repeat(m_rd_queue.size()==0) @(posedge intf.clk);
          if (m_rd_addr_indx < m_rd_queue.size()) 
	    begin
              m_trx = m_rd_queue[m_rd_addr_indx];
              //repeat(5) @(posedge intf.clk);
              intf.ARVALID <= 1'b1;
              intf.ARID    <= m_trx.ARID;
              intf.ARADDR  <= m_trx.ARADDR;
              intf.ARLEN   <= m_trx.ARLEN;
              intf.ARSIZE  <= m_trx.ARSIZE;
              intf.ARBURST <= m_trx.ARBURST;
            //  intf.ARLOCK  <= m_trx.ARLOCK;
            //  intf.ARCACHE <= m_trx.ARCACHE;
            //  intf.ARPROT  <= m_trx.ARPROT;
            //  intf.ARQOS   <= m_trx.ARQOS;
            //  intf.ARREG   <= m_trx.ARREG;
              @(posedge intf.clk);
              // hold until ARREADY received
              while(!intf.ARREADY) @(posedge intf.clk);
             //void'(m_rd_queue.pop_front());
             intf.ARVALID <= 1'b0;
             @(posedge intf.clk);
             m_rd_addr_indx += 1;
          end 
        else 
          begin
            @(posedge intf.clk);
          end
      end
  endtask : sent_addr_read_trx
  
  // data read trx
  task received_data_read_trx();
    `uvm_info(get_type_name(), "in received_data_read_trx", UVM_DEBUG)
    intf.RREADY = 1'b0;
    forever 
      begin
        intf.RREADY <= 1'b0;
        repeat($urandom_range(4,6)) @(posedge intf.clk);

        intf.RREADY <= 1'b1;
        @(posedge intf.clk);

        // hold until RVALID received
        while(!intf.RVALID) @(posedge intf.clk);
      end
  endtask : received_data_read_trx
endclass
