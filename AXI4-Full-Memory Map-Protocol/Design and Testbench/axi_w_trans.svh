



class axi_write_transaction;

  
  `include "design.sv"
  
   //interface signals
   logic [(ID_WIDTH   - 1) : 0]    awid;
   logic [(ADDR_WIDTH - 1) : 0]    awaddr;
   logic [(LEN_WIDTH  - 1) : 0]    awlen;
   logic [(2 - 1) : 0]             awburst;
   logic [(SIZE_WIDTH - 1) : 0]    awsize;
   logic                           awvalid;
   logic                           awready;

   logic [(ID_WIDTH - 1) : 0]      bid;
   logic [1:0]                     bresp;
   logic                           bvalid;
   logic                           bready;
   logic [(DATA_WIDTH - 1) : 0]    wdata;
   logic [(DATA_WIDTH/8) - 1 : 0]  wstrobe;
   logic                           wlast;
   logic                           wvalid;
   logic                           wready;

   //control knobs
   rand int                        req_delay;
   rand int                        rsp_delay;
   rand int                        data_delay;
   static int                      min_rsp_delay;
   static int                      min_req_delay;
   static int                      max_rsp_delay;
   static int                      max_req_delay;
   static int                      min_data_delay;
   static int                      max_data_delay;
   static bit [(2**ID_WIDTH)-1:0]  cmd_tag_queue_size;
  
    //CONSTRAINTS
    constraint req_delay_c  {req_delay inside {[min_req_delay:max_req_delay]};} 
    constraint rsp_delay_c  {rsp_delay inside {[min_rsp_delay:max_rsp_delay]};} 
    constraint data_delay_c {data_delay inside{[min_data_delay:max_data_delay]};} 
    



  
 endclass : axi_write_transaction


module axi_slave_write (
   //CLK & RST
   input                                  clk , 
   input                                  reset_n,
   //WRITE COMMAND BUS
   input [(ID_WIDTH   - 1) : 0]           awid,
   input [(ADDR_WIDTH  - 1) : 0]          awaddr,
   input [(LEN_WIDTH  - 1) : 0]           awlen,
   input [(2 - 1) : 0]                    awburst,
   input [(SIZE_WIDTH - 1) : 0]           awsize,
   input                                  awvalid,
   output  logic                          awready,
   //WRITE RESPONSE BUS
   output logic [(ID_WIDTH - 1) : 0]      bid,
   output logic [1:0]                     bresp,
   output logic                           bvalid,
   input                                  bready,
  //WRITE DATA BUS
   input        [(DATA_WIDTH - 1) : 0]    wdata,
   input        [(DATA_WIDTH/8) - 1 : 0]  wstrobe,
   input                                  wlast,
   input                                  wvalid,
   output      logic                      wready,
   //Control signals
   input [31:0]                           min_rsp_delay,
   input [31:0]                           min_req_delay,
   input [31:0]                           max_rsp_delay,
   input [31:0]                           max_req_delay,
   input [31:0]                           min_data_delay,
   input [31:0]                           max_data_delay,
   input [31:0]                           num_slave
);
   
   import  uvm_pkg :: *;
  `include "uvm_macros.svh"
   bit current_rsp_id_freeze;
   int request_q[$];
   axi_write_transaction               req , rsp , data_h;
   axi_write_transaction               cmd_order_queue[$];
   axi_write_transaction               tag_based_cmd_queue[2**ID_WIDTH][$];
   axi_write_transaction               addr_data_queue[$];
   bit                                 data_polling_queue [$];  
   bit [1:0]                           rsp_queue [2**ID_WIDTH][$];  
   bit                                 error_rsp_scenario;
   bit[3:0]                                 count=0;
 //// int data_fifo[i];

   initial begin
      fork
         write_request();
         write_data ();
         write_response ();
      join
   end

   always @(min_rsp_delay , min_req_delay , max_rsp_delay , max_req_delay) begin
      req.min_req_delay = min_req_delay;
      req.max_req_delay = max_req_delay;
      req.min_rsp_delay = min_rsp_delay;
      req.max_rsp_delay = max_rsp_delay;
   end

  


   task write_response ();
   axi_write_transaction               temp; 
      bvalid = 0;
      forever begin
         @(posedge clk); 
         bvalid = 0;
         rsp = new();
         assert (rsp.randomize()); 
         wait ((cmd_order_queue.size() > 0) && (data_polling_queue.size() > 0));
         repeat (rsp.rsp_delay) begin
            @(posedge clk);
         end
         bvalid = 1;
         temp   = cmd_order_queue.pop_front ();
         bresp  = rsp_queue[temp.awid].pop_front (); 
         bid    = temp.awid;
         wait (bready === 1'b1);
         #1;
         wait (bready === 1'b1);
         void '(tag_based_cmd_queue[temp.awid].pop_front()); 
         void '(data_polling_queue.pop_front ());
      end

   endtask : write_response

   task write_request ();
      awready  = 0;
      forever begin
         req = new();
         assert (req.randomize()); 
         @(posedge clk); 
         awready  = 0;
         wait (awvalid == 1) begin
           #1 wait (awvalid == 1);
            @(posedge clk);
         end
         repeat (req.req_delay) begin
            @(posedge clk);
         end
         while (tag_based_cmd_queue[awid].size() > 0) begin
            @(posedge clk); 
         end
         awready      = 1;
         req.awid     = awid;
         req.awaddr   = awaddr ;
         req.awlen    = awlen ;
         req.awburst  = awburst ;
         req.awsize   = awsize ;

         #1; 
         if (awvalid == 1) begin
            fork
            automatic axi_write_transaction txn = req;
               begin
                  @(posedge clk);
                  addr_data_queue.push_back(txn);
                 $display("TXN %d time %t",txn,$time);
                  cmd_order_queue.push_back (txn);
                  tag_based_cmd_queue[txn.awid].push_back(txn);
                  populate_rsp_queue (txn); 
               end
            join_none
         end
      end
   endtask : write_request

  
   task write_data;
    axi_write_transaction               packet;
      wready  = 0;
      forever 
      begin
        @(posedge clk); 
        data_h = new();
        packet  = new();
        assert (data_h.randomize()); 
       // wait (wvalid == 1) begin
        packet = addr_data_queue.pop_front ();
       // $display("1 packet %p",packet);
        //$display("2 data %h :%t",wdata,$time);
        if(packet != null) 
        begin     
          wait (wvalid == 1)
          begin
          wready  = 1;
          count = 0;
          repeat(packet.awlen+1) 
          begin
            @(posedge clk);
          //  $display("3 data %h :%t",wdata,$time);
            data_fifo[packet.awaddr+count] = wdata;
            count=count+1;
           end
           wready = 0;
        end
        if (wlast == 1'b1)
        begin
          fork 
          begin
            @(posedge clk);
            data_polling_queue.push_back (1);
          end
          join_none
        end
       end
       end
   endtask : write_data

   task populate_rsp_queue (axi_write_transaction txn);
      int incr_addr;
      bit [1:0] rsp;

      for (int i = 0 ; i <= txn.awlen ; i ++) begin
         if (txn.awburst == 1) begin
            incr_addr = incr_addr + (2**(txn.awsize+1));
         end    
         std :: randomize (error_rsp_scenario) with {error_rsp_scenario dist {0 := 90 , 1 := 10};};   
         if (txn.awaddr[(32 - 1) : 12] > (num_slave-1)) begin
            rsp = 2;
         end else if ((incr_addr [31:12] != txn.awaddr[(32 - 1) : 12]) && (txn.awburst == 1)) begin
            rsp = 3;
         end else begin
            rsp = 0;
         end
         if (error_rsp_scenario == 1) begin
            rsp = $random;
         end
         rsp_queue[txn.awid].push_back(rsp);
      end
         
   endtask : populate_rsp_queue


endmodule : axi_slave_write 

