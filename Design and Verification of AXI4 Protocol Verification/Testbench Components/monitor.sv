`ifndef AXI_MONITOR
`define AXI_MONITOR

`define vintf vintf
//`define vintf vintf.monitor_mp.monitor_cb

class monitor extends uvm_monitor;
   `uvm_component_utils(monitor)

   virtual axi_interface vintf;
  
   uvm_analysis_port#(transaction) mon2scor;

   semaphore sema =new(5);

   function new(string name="monitor",uvm_component parent=null);
      super.new(name,parent);
     mon2scor=new("mon2scor",this);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual axi_interface)::get(this,"","DATA",vintf)) begin
         `uvm_fatal("* MONITOR-CONNECTION FAILED *","");
      end
      else begin
         `uvm_info("MONITOR-CONNECTION DONE","",UVM_HIGH);
      end
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction

   int write_data_count;
   int read_data_count;
   task run_phase(uvm_phase phase);
      transaction trans;
      forever begin
        if(vintf.reset==0) begin
          trans=transaction::type_id::create("trans",this);
          
          fork begin
            
            begin
               @(posedge vintf.clk);
               while(vintf.awvalid==0 || vintf.awready==0) begin
                  @(posedge vintf.clk);
               end
               trans.awvalid   = `vintf.awvalid;
               trans.awready   = `vintf.awready;
               trans.awlen     = `vintf.awlen;
               trans.awaddr    = new[trans.awlen+1];
               trans.awaddr[0] = `vintf.awaddr;
               for(int i=1;i<=trans.awlen;i++) begin
                  if(trans.awaddr[i-1]%4==0)       trans.awaddr[i]=trans.awaddr[i-1]+4;
                  else if(trans.awaddr[i-1]%4==1)  trans.awaddr[i]=trans.awaddr[i-1]+3;
                  else if(trans.awaddr[i-1]%4==2)  trans.awaddr[i]=trans.awaddr[i-1]+2;
                  else if(trans.awaddr[i-1]%4==3)  trans.awaddr[i]=trans.awaddr[i-1]+1;
               end

               trans.wdata    = new[trans.awlen+1];
               sema.put(1);
            end
        
            begin
               @(posedge vintf.clk);
               write_data_count = 0;
               repeat(vintf.awlen+1) begin
                  while(vintf.wvalid==0 || vintf.wready==0)begin
                     @(posedge vintf.clk);
                  end
                  trans.wstrb = `vintf.wstrb;
                  trans.wvalid   = `vintf.wvalid;
                  trans.wready   = `vintf.wready;
                  if(trans.awaddr[write_data_count]%4 == 0)
                     trans.wdata[write_data_count] = `vintf.wdata;
                  else if(trans.awaddr[write_data_count]%4 == 1)
                     trans.wdata[write_data_count][7:0] = `vintf.wdata[7:0];
                  else if(trans.awaddr[write_data_count]%4 == 2)
                     trans.wdata[write_data_count][15:0] = `vintf.wdata[15:0];
                  else if(trans.awaddr[write_data_count]%4 == 3)
                     trans.wdata[write_data_count][23:0] = `vintf.wdata[23:0];
                  else
                     trans.wdata[write_data_count] = `vintf.wdata;
                  write_data_count++;
                  @(posedge vintf.clk);
               end
               sema.put(1);
            end
        
            begin
               while(vintf.bvalid==0 || vintf.bready==0)begin
                  @(posedge vintf.clk);
               end
        	      trans.bresp    = `vintf.bresp;
               trans.bvalid   = `vintf.bvalid;
               trans.bready   = `vintf.bready;
               sema.put(1);
            end
        
            begin
               while(vintf.arvalid==0 || vintf.arready==0)begin
                  @(posedge vintf.clk);
               end
               trans.arvalid  = `vintf.arvalid;
               trans.arready  = `vintf.arready;
               trans.arlen    = `vintf.arlen;
               trans.araddr   =  new[trans.arlen+1];
               trans.araddr[0] = `vintf.araddr;
               for(int i=1;i<=trans.arlen;i++) begin
                  if(trans.araddr[i-1]%4==0)       trans.araddr[i]=trans.araddr[i-1]+4;
                  else if(trans.araddr[i-1]%4==1)  trans.araddr[i]=trans.araddr[i-1]+3;
                  else if(trans.araddr[i-1]%4==2)  trans.araddr[i]=trans.araddr[i-1]+2;
                  else if(trans.araddr[i-1]%4==3)  trans.araddr[i]=trans.araddr[i-1]+1;
               end


               trans.rdata    = new[trans.arlen+1];
               sema.put(1);
            end
            
            begin
               read_data_count = 0;
               repeat(vintf.arlen+1) begin
                  while(vintf.rvalid==0 || vintf.rready==0) begin
                     @(posedge vintf.clk);
                  end
                  if(trans.araddr[read_data_count]%4==0)
                     trans.rdata[read_data_count][31:0] = `vintf.rdata[31:0];
                  else if(trans.araddr[read_data_count]%4==1)
                     trans.rdata[read_data_count][7:0] = `vintf.rdata[7:0];
                  else if(trans.araddr[read_data_count]%4==2)
                     trans.rdata[read_data_count][15:0] = `vintf.rdata[15:0];
                  else if(trans.araddr[read_data_count]%4==3)
                     trans.rdata[read_data_count][23:0] = `vintf.rdata[23:0];
                  else
                     trans.rdata[read_data_count][31:0] = `vintf.rdata[31:0];
                  trans.rvalid   = `vintf.rvalid;
                  trans.rready   = `vintf.rready;
                  read_data_count++;
          		   @(posedge vintf.clk);
               end
               sema.put(1);
            end
            
            begin
               sema.get(5);
               mon2scor.write(trans);
               `uvm_info("MONITOR-PACKETS SENT",$sformatf("%0s",trans.sprint),UVM_HIGH);
               `uvm_info("DATA CHECK",$sformatf("\n\n wmem_data == %p \n rmem_data == %p \n wmem_size == %0d \n rmem_size == %0d \n",trans.wdata,trans.rdata,trans.wdata.size,trans.rdata.size),UVM_NONE);
               `uvm_info("ADDR CHECK",$sformatf("\n\n wmem_addr == %p \n rmem_addr == %p\n awaddr_size == %0d \n araddr_size == %0d \n",trans.awaddr,trans.araddr,trans.awaddr.size,trans.araddr.size),UVM_NONE);
            end
          end
         join_none
         wait fork;
            

      	end
         else begin
            @(posedge vintf.clk);
            trans=transaction::type_id::create("trans",this);
            trans.reset = `vintf.reset;
            mon2scor.write(trans);
         end
      end
   endtask

endclass
`endif

