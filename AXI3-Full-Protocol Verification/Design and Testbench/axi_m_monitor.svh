class axi_m_monitor#(int WIDTH=32,SIZE=3) extends uvm_monitor;

  `uvm_component_param_utils(axi_m_monitor#(WIDTH,SIZE))
  virtual axi_intf#(WIDTH,SIZE) intf;
  axi_m_Sequence_Item#(WIDTH,SIZE) w_tx, r_tx;
  uvm_analysis_port#(axi_m_Sequence_Item#(WIDTH,SIZE)) mon2sb_port;
  int unsigned i,j,k,l,m;
  int AR_queue[$],AW_queue[$],AWLEN_queue[$];
  bit [WIDTH-1:0] W_queue[$];
  bit [WIDTH-1:0] wdata;
  bit [WIDTH-1:0] rdata;

  function new(string name, uvm_component parent);
    super.new(name,parent);
    r_tx=new;
    w_tx=new;
    mon2sb_port=new("mon2sb_port",this);
  endfunction

  function void  build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual axi_intf#(WIDTH,SIZE))::get(this, "", "intf", intf))
    `uvm_fatal("NO_VIF","virtual interface not found");
  endfunction

  virtual task run_phase(uvm_phase phase);
  w_tx.WDATA = new[1];
  w_tx.RDATA.delete();
  r_tx.RDATA = new[1];
  r_tx.WDATA.delete();
  fork  
    forever 
      begin
        @(negedge intf.clk iff (intf.AWVALID == 1'b1 && intf.AWREADY == 1'b1));
            begin
              `uvm_info ("Master_Monitor","in monitor address write",UVM_HIGH); 
              AW_queue.push_back(intf.AWID);
              AW_queue.push_back(intf.AWADDR);
              AW_queue.push_back(intf.AWSIZE);
              AW_queue.push_back(intf.AWBURST);
              AW_queue.push_back(intf.AWLEN);
              AWLEN_queue.push_back(intf.AWLEN);
           //   w_tx.AWLOCK  = intf.AWLOCK;
           //   w_tx.AWCACHE = intf.AWCACHE;
           //   w_tx.AWPROT  = intf.AWPROT;
           //   w_tx.AWQOS   = intf.AWQOS;
           //   w_tx.AWREG   = intf.AWREG;
	    end
      end

    forever 
      begin
        //repeat(AWLEN_queue.size()==0) @(posedge intf.clk);
          //w_tx.AWLEN = AWLEN_queue.pop_front();
	  //while(i<=w_tx.AWLEN)
	    begin
              @(negedge intf.clk iff (intf.WVALID == 1'b1 && intf.WREADY == 1'b1));
                begin
                  `uvm_info ("Master_Monitor","in monitor data write",UVM_HIGH); 
                  W_queue.push_back(intf.WSTRB);
                  W_queue.push_back(intf.WID);
                  W_queue.push_back(intf.WDATA); 
                end
            end
      end
    
    forever 
      begin
        repeat(AW_queue.size()==0) @(posedge intf.clk);
        @(negedge intf.clk iff (intf.BVALID == 1'b1 && intf.BREADY == 1'b1));
          begin
            `uvm_info ("Master_Monitor","in monitor response write",UVM_HIGH);
	    w_tx.RW      = 1'b0;
            w_tx.BID     = intf.BID;
            w_tx.BRESP   = intf.BRESP;
            w_tx.AWID    = AW_queue.pop_front();
            w_tx.AWADDR  = AW_queue.pop_front();
            w_tx.AWSIZE  = AW_queue.pop_front();
            w_tx.AWBURST = AW_queue.pop_front();
            w_tx.AWLEN   = AW_queue.pop_front();
	    w_tx.WDATA   = new[(w_tx.AWLEN+1)*(2**w_tx.AWSIZE)];
	    w_tx.WSTRB   = new[w_tx.AWLEN+1];
	    repeat(w_tx.AWLEN+1) 
              begin
                w_tx.WSTRB[i/(2**w_tx.AWSIZE)] = W_queue.pop_front();
                w_tx.WID     = W_queue.pop_front();
                wdata        =  W_queue.pop_front();
                `uvm_info ("Master_Monitor",$psprintf("wdata = %h",wdata),UVM_HIGH);
		repeat(2**w_tx.AWSIZE)
                  begin
                   w_tx.WDATA[i] =  wdata[8*k +:8];
                   `uvm_info ("Master_Monitor",$psprintf("data %h,WDATA[%0d]=%h",wdata[8*k +:8],i,w_tx.WDATA[i]),UVM_HIGH);
                   i++;
                   k++;
                  end
                k=1'b0;
              end
            i=1'b0;

            `uvm_info ("Master_Monitor","Packet from Master_Monitor Put to the port write",UVM_HIGH);
            mon2sb_port.write(w_tx);
            //w_tx.print();
          end
      end

//######## Read Transaction #########
    forever
      begin
        @(negedge intf.clk iff (intf.ARVALID == 1'b1 && intf.ARREADY == 1'b1));
          begin
	      `uvm_info ("Master_Monitor","in monitor address read",UVM_HIGH);
              AR_queue.push_back(intf.ARID);
              AR_queue.push_back(intf.ARADDR);
              AR_queue.push_back(intf.ARLEN);
              AR_queue.push_back(intf.ARSIZE);
              AR_queue.push_back(intf.ARBURST);
           //   r_tx.ARLOCK  = intf.ARLOCK;
           //   r_tx.ARCACHE = intf.ARCACHE;
           //   r_tx.ARPROT  = intf.ARPROT;
           //   r_tx.ARQOS   = intf.ARQOS;
           //   r_tx.ARREG   = intf.ARREG;
	  end
      end

    forever
     @(posedge intf.clk)
        while(AR_queue.size() != 0)   
	begin
          j = 0;
	      r_tx.RW      = 1'b1;
          r_tx.ARID    = AR_queue.pop_front();
          r_tx.ARADDR  = AR_queue.pop_front();
          r_tx.ARLEN   = AR_queue.pop_front();
          r_tx.ARSIZE  = AR_queue.pop_front();
          r_tx.ARBURST = AR_queue.pop_front();
          r_tx.RDATA   = new[(r_tx.ARLEN+1)*(2**r_tx.ARSIZE)](r_tx.RDATA);
             while (j<=r_tx.ARLEN) 
               begin
                 @(negedge intf.clk)
                 if (intf.RVALID == 1'b1 && intf.RREADY == 1'b1)
                   begin
                     r_tx.RRESP   = intf.RRESP;
                     r_tx.RID     = intf.RID;
                     rdata= intf.RDATA;
                     `uvm_info ("Master_Monitor",$psprintf("rdata = %h",rdata),UVM_HIGH); 
                     repeat(2**r_tx.ARSIZE) 
                       begin
                         r_tx.RDATA[m] =  rdata[8*l +:8];
                         `uvm_info ("Master_Monitor",$psprintf("data %h,WDATA[%0d]=%h",rdata[8*l +:8],m,r_tx.RDATA[m]),UVM_HIGH); 
                         l++;
                         m++;
                       end
                       l=1'b0;

                     r_tx.RLAST   = intf.RLAST;
                     `uvm_info ("Master_Monitor",$psprintf("r_tx.RDATA[%d]=%h",j,r_tx.RDATA[j]),UVM_HIGH);
                     j = j+1;
	             if (intf.RLAST)
                     begin
		       @(negedge intf.RLAST)
                       `uvm_info ("Master_Monitor","Packet from Master_Monitor Put to the port read",UVM_HIGH); 
                       mon2sb_port.write(r_tx);
                       //r_tx.print();
                       m=0;
                       r_tx.RDATA=new[1];
                     end
                   end
               end
        end

  join
  endtask
endclass
