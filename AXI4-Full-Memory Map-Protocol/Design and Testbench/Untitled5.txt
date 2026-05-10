
interface axi_intf  (input clk,reset_n);

   logic [3 : 0]                awid;
   logic [ADDR_WIDTH   - 1 : 0] awaddr;
   logic [7 : 0]                awlen;
   logic [2 : 0]                awsize;
   logic [1 : 0]                awburst;
   logic                        awvalid;
   logic                        awready;

   logic [DATA_WIDTH   - 1 : 0] wdata;
   logic [DATA_WIDTH/8 - 1 : 0] wstrb;
   logic                        wlast;
   logic                        wvalid;
   logic                        wready;

   logic [3 : 0]                bid;
   logic [1 : 0]                bresp;
   logic                        bvalid;
   logic                        bready;

   logic [3 : 0]                arid;
   logic [ADDR_WIDTH   - 1 : 0] araddr;
   logic [7 : 0]                arlen;
   logic [2 : 0]                arsize;
   logic [1 : 0]                arburst;
   logic                        arvalid;
   logic                        arready;

   logic [3 : 0]                rid;
   logic [1 : 0]                rresp;
   logic [DATA_WIDTH  - 1 : 0]  rdata;
   logic [DATA_WIDTH/8- 1 : 0]  rstrb;
   logic                        rlast;
   logic                        rvalid;
   logic                        rready;

   logic [31 : 0]               min_req_delay;
   logic [31 : 0]               max_req_delay;
   logic [31 : 0]               min_rsp_delay;
   logic [31 : 0]               max_rsp_delay;
   logic [31 : 0]               min_data_delay;
   logic [31 : 0]               max_data_delay;
   logic [31 : 0]               num_slave;
   logic                        interleaving_en;
   logic                        out_of_order_en;

   clocking w_drv_cb @(posedge clk);
      default input #1 output #0;
      output  awid;
      output  awaddr;
      output  awlen;
      output  awsize;
      output  awburst;
      output  awvalid;
      input   awready;

      output  wdata;
      output  wstrb;
      output  wlast;
      output  wvalid;
      input   wready;

      output  bready;
      input   bvalid;
   endclocking : w_drv_cb

   clocking r_drv_cb @(posedge clk);
      default input #1 output #0;
      output  arid;
      output  araddr;
      output  arlen;
      output  arsize;
      output  arburst;
      output  arvalid;
      input   arready;
      input rdata;
      output  rready;
      input   rvalid;
   endclocking : r_drv_cb

   clocking c_drv_cb @(posedge clk);
      default input #1 output #0;
      output  min_req_delay;
      output  max_req_delay;
      output  min_rsp_delay;
      output  max_rsp_delay;
      output  min_data_delay;
      output  max_data_delay;
      output  interleaving_en;
      output  out_of_order_en;
      output  num_slave;
   endclocking : c_drv_cb

   clocking w_mon_cb @(posedge clk);
      default input #1 output #0;
      input  awid;
      input  awlen;
      input  awsize;
      input  awburst;
      input  awaddr;
      input  awvalid;
      input  awready;
   
      input  wdata;
      input  wlast;
      input  wstrb;
      input  wvalid;
      input  wready;
   
      input  bid;
      input  bresp;
      input  bvalid;
      input  bready;
   endclocking : w_mon_cb

   clocking r_mon_cb @(posedge clk);
      default input #1 output #0;
      input  arid;
      input  arlen;
      input  arsize;
      input  arburst;
      input  araddr;
      input  arvalid;
      input  arready;
   
      input  rid;
      input  rdata;
      input  rstrb;
      input  rlast;
      input  rresp;
      input  rvalid;
      input  rready;
   endclocking : r_mon_cb

   clocking c_mon_cb @(posedge clk);
      default input #1 output #0;
      input  min_req_delay;
      input  max_req_delay;
      input  min_rsp_delay;
      input  max_rsp_delay;
      input  min_data_delay;
      input  max_data_delay;
      input  interleaving_en;
      input  out_of_order_en;
      input  num_slave;
   endclocking : c_mon_cb

   modport W_DRV_MOD (clocking w_drv_cb, input reset_n);
   modport R_DRV_MOD (clocking r_drv_cb, input reset_n);
   modport C_DRV_MOD (clocking c_drv_cb, input reset_n);
   modport W_MON_MOD (clocking w_mon_cb, input reset_n);
   modport R_MON_MOD (clocking r_mon_cb, input reset_n);
   modport C_MON_MOD (clocking c_mon_cb, input reset_n);

   

endinterface : axi_intf

