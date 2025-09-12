`ifndef AXI_DRIVER
`define AXI_DRIVER

`define vif v_intf.driver_mp.driver_cb

class driver extends uvm_driver#(transaction);

   `uvm_component_utils(driver)

   virtual axi_interface v_intf;

   function new(string name="driver",uvm_component parent=null);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if(!uvm_config_db#(virtual axi_interface)::get(this,"","DATA",v_intf)) begin
         `uvm_fatal("* DRIVER-CONNECTION FAILED *","");
      end
      else begin
         `uvm_info("DRIVER-CONNECTION DONE","",UVM_NONE);
      end

   endfunction



   
   //===================================================//
   //                WRITE ADDREDS BUS                  //
   //===================================================//
   task write_address(transaction trans);
      `uvm_info("DRIVER - WRITE ADDRESS BUS","",UVM_HIGH);
      @(posedge v_intf.clk);
      `vif.awid       <=     trans.awid;
      `vif.awaddr     <=     trans.awaddr[0];
      `vif.awlen      <=     trans.awlen;
      `vif.awsize     <=     trans.awsize;
      `vif.awburst    <=     trans.awburst;
      `vif.awlock     <=     trans.awlock;
      `vif.awcache    <=     trans.awcache;
      `vif.awprot     <=     trans.awprot;
      `vif.awvalid    <=     trans.awvalid;
      wait(v_intf.awready==1);
      @(posedge v_intf.clk);
      `vif.awid       <=     0;
      `vif.awaddr     <=     0;
      `vif.awvalid    <=     0;
   endtask
    


   //===================================================//
   //                WRITE DATA BUS                     //
   //===================================================//
   int write_data_count;
   task write_data(transaction trans);
         write_data_count <= 0;
         if(trans.awaddr[0]%4==0) trans.wstrb <= 4'b1111;
         else if(trans.awaddr[0]%4==1) trans.wstrb <= 4'b0001;
         else if(trans.awaddr[0]%4==2) trans.wstrb <= 4'b0011;
         else if(trans.awaddr[0]%4==3) trans.wstrb <= 4'b0111;
      repeat(trans.awlen+1) begin
         @(posedge v_intf.clk);
         `uvm_info("DRIVER - WRITE DATA BUS","",UVM_HIGH);
         `vif.wdata      <=     trans.wdata[write_data_count];
         `vif.wstrb      <=     trans.wstrb;
         `vif.wvalid     <=     trans.wvalid;
         if(write_data_count==trans.awlen) begin
            `vif.wlast      <=     1;
         end
         else begin 
            `vif.wlast <= 0;
         end
         while(v_intf.wready==0) begin
            @(posedge v_intf.clk);
         end
         write_data_count++;
         @(posedge v_intf.clk);
         `vif.wvalid     <=     0;
         trans.wstrb <=4'b1111;
      end
      `vif.wdata      <=     0;
   endtask
   

   //===================================================//
   //                WRITE RESPONSE BUS                 //
   //===================================================//
   task write_response(transaction trans);
      `uvm_info("DRIVER - WRITE RESPONSE BUS","",UVM_HIGH);
      `vif.bready     <=     trans.bready;
      while(v_intf.bvalid==0) begin
         @(posedge v_intf.clk);
      end
   endtask

   //===================================================//
   //                READ ADDREDS BUS                   //
   //===================================================//
   task read_address(transaction trans);
      `uvm_info("DRIVER - READ ADDRESS BUS","",UVM_HIGH);
      `vif.arid       <=     trans.arid;
      `vif.araddr     <=     trans.araddr[0];
      `vif.arlen      <=     trans.arlen;
      `vif.arsize     <=     trans.arsize;
      `vif.arburst    <=     trans.arburst;
      `vif.arlock     <=     trans.arlock;
      `vif.arcache    <=     trans.arcache;
      `vif.arprot     <=     trans.arprot;
      `vif.arvalid    <=     trans.arvalid;
      while(v_intf.arready==0) begin
         @(posedge v_intf.clk);
      end
      @(posedge v_intf.clk);
      `vif.arid       <=     0;
      `vif.araddr     <=     0;
      `vif.arvalid    <=     0;
   endtask

   //===================================================//
   //                READ DATA BUS                      //
   //===================================================//
   task read_data(transaction trans);
      repeat(trans.arlen+1) begin
         @(posedge v_intf.clk);
         `uvm_info("DRIVER - READ DATA BUS","",UVM_HIGH);
         while(v_intf.rvalid==0) begin
            @(posedge v_intf.clk);
         end
         `vif.rready     <=     trans.rready;
         @(posedge v_intf.clk);
         `vif.rready     <=     0;
      end
   endtask
   


   //===================================================//
   //                 RESET LOGIC                       //
   //===================================================//
   task reset_logic;
      `vif.awvalid    <=    0;
      `vif.wvalid     <=    0;
      `vif.bready     <=    0;
      `vif.arvalid    <=    0;
      `vif.rready     <=    0;
      //wait(v_intf.reset==0);
   endtask

   //===================================================//
   //                 DRIVER LOGIC                      //
   //===================================================//
   task driver_logic(transaction trans);
            write_address(trans);
            write_data(trans);
            write_response(trans);
            read_address(trans);
            read_data(trans);
   endtask

   
   //===================================================//
   //                 RUN PHASE                         //
   //===================================================//
   task run_phase(uvm_phase phase);

      transaction trans;

      forever begin
         seq_item_port.get_next_item(trans);
         if(trans.reset==1) begin
            v_intf.reset<=1;
            reset_logic();
         end
         else if(trans.reset==0) begin
            v_intf.reset<=0;
            driver_logic(trans);
         end
         seq_item_port.item_done();
         `uvm_info("DRIVER - TRANSACTION NUMBER","",UVM_NONE);
      end

   endtask

endclass

`endif



