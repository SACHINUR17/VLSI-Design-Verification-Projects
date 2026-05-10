/*

1. All signals
2. w/r txn to all slaves
3. outstanding
4. interleaving
5. out of order
6. aligned / unaligned address
7. valid / invalid address

*/

class coverage extends uvm_component;
   `uvm_component_utils (coverage)

   uvm_analysis_export   #(w_seq_item) w_cov_exp;
   uvm_analysis_export   #(r_seq_item) r_cov_exp;
   uvm_tlm_analysis_fifo #(w_seq_item) w_cov_af;
   uvm_tlm_analysis_fifo #(r_seq_item) r_cov_af;
   w_seq_item                          w_cov_txn;
   r_seq_item                          r_cov_txn;

   bit interleaving;
   bit out_of_order;

   r_seq_item    r_command_queue[$],r_data_queue[$];
   r_seq_item    arid_txn,rid_txn;

   function new (string name = "coverage" , uvm_component parent);
      super.new(name,parent);
      cg_w_command  = new();
      cg_w_data     = new();
      cg_w_response = new();
      cg_r_command  = new();
      cg_r_data     = new();
   endfunction

   extern function void build_phase              (uvm_phase phase);
   extern function void connect_phase            (uvm_phase phase);
   extern task run_phase                         (uvm_phase phase);
   extern function void out_of_order_check ();

   covergroup cg_w_command; 

      option.per_instance = 1;
      option.goal         = 100;
      option.name         = "w_command";

      cp_awid : coverpoint w_cov_txn.awid {
                                           bins awid[] = {[0:15]};
                                          }

      cp_awburst : coverpoint w_cov_txn.awburst {
                                                 bins awburst0 = {0};
                                                 bins awburst1 = {1};
                                                 bins awburst2 = {2};
                                                }

      cp_awsize : coverpoint w_cov_txn.awsize {
                                               bins awsize0 = {0};
                                               bins awsize1 = {1};
                                               bins awsize2 = {2};
                                               bins awsize3 = {3};
                                              }

      cp_awlen : coverpoint w_cov_txn.awlen {
                                             wildcard bins awlen0  = {8'b 0xxxxxxx};
                                             wildcard bins awlen1  = {8'b x0xxxxxx};
                                             wildcard bins awlen2  = {8'b xx0xxxxx};
                                             wildcard bins awlen3  = {8'b xxx0xxxx};
                                             wildcard bins awlen4  = {8'b xxxx0xxx};
                                             wildcard bins awlen5  = {8'b xxxxx0xx};
                                             wildcard bins awlen6  = {8'b xxxxxx0x};
                                             wildcard bins awlen7  = {8'b xxxxxxx0};
                                             wildcard bins awlen8  = {8'b 1xxxxxxx};
                                             wildcard bins awlen9  = {8'b x1xxxxxx};
                                             wildcard bins awlen10 = {8'b xx1xxxxx};
                                             wildcard bins awlen11 = {8'b xxx1xxxx};
                                             wildcard bins awlen12 = {8'b xxxx1xxx};
                                             wildcard bins awlen13 = {8'b xxxxx1xx};
                                             wildcard bins awlen14 = {8'b xxxxxx1x};
                                             wildcard bins awlen15 = {8'b xxxxxxx1};
                                            }

      cp_awaddr : coverpoint w_cov_txn.awaddr {
                                               wildcard bins awaddr0  = {32'b 0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr1  = {32'b x0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr2  = {32'b xx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr3  = {32'b xxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr4  = {32'b xxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr5  = {32'b xxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr6  = {32'b xxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr7  = {32'b xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr8  = {32'b xxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr9  = {32'b xxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr10 = {32'b xxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr11 = {32'b xxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr12 = {32'b xxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr13 = {32'b xxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr14 = {32'b xxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr15 = {32'b xxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr16 = {32'b xxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxx};
                                               wildcard bins awaddr17 = {32'b xxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxx};
                                               wildcard bins awaddr18 = {32'b xxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxx};
                                               wildcard bins awaddr19 = {32'b xxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxx};
                                               wildcard bins awaddr20 = {32'b xxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxx};
                                               wildcard bins awaddr21 = {32'b xxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxx};
                                               wildcard bins awaddr22 = {32'b xxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxx};
                                               wildcard bins awaddr23 = {32'b xxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxx};
                                               wildcard bins awaddr24 = {32'b xxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxx};
                                               wildcard bins awaddr25 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxx};
                                               wildcard bins awaddr26 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxx};
                                               wildcard bins awaddr27 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxx};
                                               wildcard bins awaddr28 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxx};
                                               wildcard bins awaddr29 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xx};
                                               wildcard bins awaddr30 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0x};
                                               wildcard bins awaddr31 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0};
                                               wildcard bins awaddr32 = {32'b 1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr33 = {32'b x1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr34 = {32'b xx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr35 = {32'b xxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr36 = {32'b xxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr37 = {32'b xxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr38 = {32'b xxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr39 = {32'b xxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr40 = {32'b xxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr41 = {32'b xxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr42 = {32'b xxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr43 = {32'b xxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr44 = {32'b xxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr45 = {32'b xxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr46 = {32'b xxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr47 = {32'b xxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxx};
                                               wildcard bins awaddr48 = {32'b xxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx};
                                               wildcard bins awaddr49 = {32'b xxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxx};
                                               wildcard bins awaddr50 = {32'b xxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxx};
                                               wildcard bins awaddr51 = {32'b xxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx};
                                               wildcard bins awaddr52 = {32'b xxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxx};
                                               wildcard bins awaddr53 = {32'b xxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx};
                                               wildcard bins awaddr54 = {32'b xxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxx};
                                               wildcard bins awaddr55 = {32'b xxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxx};
                                               wildcard bins awaddr56 = {32'b xxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxx};
                                               wildcard bins awaddr57 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxx};
                                               wildcard bins awaddr58 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxx};
                                               wildcard bins awaddr59 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxx};
                                               wildcard bins awaddr60 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxx};
                                               wildcard bins awaddr61 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xx};
                                               wildcard bins awaddr62 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x};
                                               wildcard bins awaddr63 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1};
                                              }
   endgroup : cg_w_command

   covergroup cg_w_data; 

      option.per_instance = 1;
      option.goal         = 100;
      option.name         = "w_data";

      cp_wlast : coverpoint w_cov_txn.wlast {
                                             bins wlast0 = {0};
                                             bins wlast1 = {1};
                                            }

      cp_wdata : coverpoint w_cov_txn.wdata[0] {
                                                wildcard bins wdata0   =  {64'b 0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata1   =  {64'b x0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata2   =  {64'b xx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata3   =  {64'b xxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata4   =  {64'b xxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata5   =  {64'b xxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata6   =  {64'b xxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata7   =  {64'b xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata8   =  {64'b xxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata9   =  {64'b xxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata10  =  {64'b xxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata11  =  {64'b xxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata12  =  {64'b xxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata13  =  {64'b xxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata14  =  {64'b xxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata15  =  {64'b xxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata16  =  {64'b xxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata17  =  {64'b xxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata18  =  {64'b xxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata19  =  {64'b xxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata20  =  {64'b xxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata21  =  {64'b xxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata22  =  {64'b xxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata23  =  {64'b xxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata24  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata25  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata26  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata27  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata28  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata29  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata30  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata31  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata32  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata33  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata34  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata35  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata36  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata37  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata38  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata39  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata40  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata41  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata42  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata43  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata44  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata45  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata46  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata47  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata48  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata49  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxx}; 
                                                wildcard bins wdata50  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxx}; 
                                                wildcard bins wdata51  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxx}; 
                                                wildcard bins wdata52  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxx}; 
                                                wildcard bins wdata53  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxx}; 
                                                wildcard bins wdata54  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxx}; 
                                                wildcard bins wdata55  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxx}; 
                                                wildcard bins wdata56  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxx}; 
                                                wildcard bins wdata57  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxx}; 
                                                wildcard bins wdata58  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxx}; 
                                                wildcard bins wdata59  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxx}; 
                                                wildcard bins wdata60  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxx}; 
                                                wildcard bins wdata61  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xx}; 
                                                wildcard bins wdata62  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0x}; 
                                                wildcard bins wdata63  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0}; 
                                                wildcard bins wdata64  =  {64'b 1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata65  =  {64'b x1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata66  =  {64'b xx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata67  =  {64'b xxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata68  =  {64'b xxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata69  =  {64'b xxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata70  =  {64'b xxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata71  =  {64'b xxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata72  =  {64'b xxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata73  =  {64'b xxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata74  =  {64'b xxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata75  =  {64'b xxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata76  =  {64'b xxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata77  =  {64'b xxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata78  =  {64'b xxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata79  =  {64'b xxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata80  =  {64'b xxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata81  =  {64'b xxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata82  =  {64'b xxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata83  =  {64'b xxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata84  =  {64'b xxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata85  =  {64'b xxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata86  =  {64'b xxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata87  =  {64'b xxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata88  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata89  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata90  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata91  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata92  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata93  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata94  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata95  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata96  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata97  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata98  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata99  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata100 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata101 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata102 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata103 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata104 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata105 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata106 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata107 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata108 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata109 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata110 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata111 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata112 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx}; 
                                                wildcard bins wdata113 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxx}; 
                                                wildcard bins wdata114 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxx}; 
                                                wildcard bins wdata115 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx}; 
                                                wildcard bins wdata116 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxx}; 
                                                wildcard bins wdata117 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx}; 
                                                wildcard bins wdata118 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxx}; 
                                                wildcard bins wdata119 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxx}; 
                                                wildcard bins wdata120 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxx}; 
                                                wildcard bins wdata121 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxx}; 
                                                wildcard bins wdata122 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxx}; 
                                                wildcard bins wdata123 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxx}; 
                                                wildcard bins wdata124 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxx}; 
                                                wildcard bins wdata125 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xx}; 
                                                wildcard bins wdata126 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x}; 
                                                wildcard bins wdata127 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1}; 
                                               }

      cp_wstrb : coverpoint w_cov_txn.wstrb[0] {
                                                wildcard bins wstrb0  = {8'b 0xxxxxxx};
                                                wildcard bins wstrb1  = {8'b x0xxxxxx};
                                                wildcard bins wstrb2  = {8'b xx0xxxxx};
                                                wildcard bins wstrb3  = {8'b xxx0xxxx};
                                                wildcard bins wstrb4  = {8'b xxxx0xxx};
                                                wildcard bins wstrb5  = {8'b xxxxx0xx};
                                                wildcard bins wstrb6  = {8'b xxxxxx0x};
                                                wildcard bins wstrb7  = {8'b xxxxxxx0};
                                                wildcard bins wstrb8  = {8'b 1xxxxxxx};
                                                wildcard bins wstrb9  = {8'b x1xxxxxx};
                                                wildcard bins wstrb10 = {8'b xx1xxxxx};
                                                wildcard bins wstrb11 = {8'b xxx1xxxx};
                                                wildcard bins wstrb12 = {8'b xxxx1xxx};
                                                wildcard bins wstrb13 = {8'b xxxxx1xx};
                                                wildcard bins wstrb14 = {8'b xxxxxx1x};
                                                wildcard bins wstrb15 = {8'b xxxxxxx1};
                                               }

   endgroup : cg_w_data

   covergroup cg_w_response; 

      option.per_instance = 1;
      option.goal         = 100;
      option.name         = "w_response";

      cp_bid : coverpoint w_cov_txn.bid {
                                         bins bid[] = {[0:15]};
                                        }

      cp_bresp : coverpoint w_cov_txn.bresp {
                                             bins bresp0 = {0};
                                             bins bresp2 = {2};
                                             bins bresp3 = {3};
                                            }

   endgroup : cg_w_response

   covergroup cg_r_command; 

      option.per_instance = 1;
      option.goal         = 100;
      option.name         = "r_command";

      cp_arid : coverpoint r_cov_txn.arid {
                                           bins arid[] = {[0:15]};
                                          }

      cp_arburst : coverpoint r_cov_txn.arburst {
                                                 bins arburst0 = {0};
                                                 bins arburst1 = {1};
                                                 bins arburst2 = {2};
                                                }

      cp_arsize : coverpoint r_cov_txn.arsize {
                                               bins arsize0 = {0};
                                               bins arsize1 = {1};
                                               bins arsize2 = {2};
                                               bins arsize3 = {3};
                                              }

      cp_awlen : coverpoint w_cov_txn.awlen {
                                             wildcard bins arlen0  = {8'b 0xxxxxxx};
                                             wildcard bins arlen1  = {8'b x0xxxxxx};
                                             wildcard bins arlen2  = {8'b xx0xxxxx};
                                             wildcard bins arlen3  = {8'b xxx0xxxx};
                                             wildcard bins arlen4  = {8'b xxxx0xxx};
                                             wildcard bins arlen5  = {8'b xxxxx0xx};
                                             wildcard bins arlen6  = {8'b xxxxxx0x};
                                             wildcard bins arlen7  = {8'b xxxxxxx0};
                                             wildcard bins arlen8  = {8'b 1xxxxxxx};
                                             wildcard bins arlen9  = {8'b x1xxxxxx};
                                             wildcard bins arlen10 = {8'b xx1xxxxx};
                                             wildcard bins arlen11 = {8'b xxx1xxxx};
                                             wildcard bins arlen12 = {8'b xxxx1xxx};
                                             wildcard bins arlen13 = {8'b xxxxx1xx};
                                             wildcard bins arlen14 = {8'b xxxxxx1x};
                                             wildcard bins arlen15 = {8'b xxxxxxx1};
                                            }

      cp_araddr : coverpoint r_cov_txn.araddr {
                                               wildcard bins araddr0  = {32'b 0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr1  = {32'b x0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr2  = {32'b xx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr3  = {32'b xxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr4  = {32'b xxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr5  = {32'b xxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr6  = {32'b xxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr7  = {32'b xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr8  = {32'b xxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr9  = {32'b xxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr10 = {32'b xxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr11 = {32'b xxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr12 = {32'b xxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr13 = {32'b xxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr14 = {32'b xxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr15 = {32'b xxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxx};
                                               wildcard bins araddr16 = {32'b xxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxx};
                                               wildcard bins araddr17 = {32'b xxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxx};
                                               wildcard bins araddr18 = {32'b xxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxx};
                                               wildcard bins araddr19 = {32'b xxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxx};
                                               wildcard bins araddr20 = {32'b xxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxx};
                                               wildcard bins araddr21 = {32'b xxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxx};
                                               wildcard bins araddr22 = {32'b xxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxx};
                                               wildcard bins araddr23 = {32'b xxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxx};
                                               wildcard bins araddr24 = {32'b xxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxx};
                                               wildcard bins araddr25 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxx};
                                               wildcard bins araddr26 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxx};
                                               wildcard bins araddr27 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxx};
                                               wildcard bins araddr28 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxx};
                                               wildcard bins araddr29 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xx};
                                               wildcard bins araddr30 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0x};
                                               wildcard bins araddr31 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0};
                                               wildcard bins araddr32 = {32'b 1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr33 = {32'b x1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr34 = {32'b xx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr35 = {32'b xxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr36 = {32'b xxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr37 = {32'b xxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr38 = {32'b xxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr39 = {32'b xxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr40 = {32'b xxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr41 = {32'b xxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr42 = {32'b xxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr43 = {32'b xxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr44 = {32'b xxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr45 = {32'b xxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr46 = {32'b xxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxx};
                                               wildcard bins araddr47 = {32'b xxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxx};
                                               wildcard bins araddr48 = {32'b xxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx};
                                               wildcard bins araddr49 = {32'b xxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxx};
                                               wildcard bins araddr50 = {32'b xxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxx};
                                               wildcard bins araddr51 = {32'b xxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx};
                                               wildcard bins araddr52 = {32'b xxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxx};
                                               wildcard bins araddr53 = {32'b xxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx};
                                               wildcard bins araddr54 = {32'b xxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxx};
                                               wildcard bins araddr55 = {32'b xxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxx};
                                               wildcard bins araddr56 = {32'b xxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxx};
                                               wildcard bins araddr57 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxx};
                                               wildcard bins araddr58 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxx};
                                               wildcard bins araddr59 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxx};
                                               wildcard bins araddr60 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxx};
                                               wildcard bins araddr61 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xx};
                                               wildcard bins araddr62 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x};
                                               wildcard bins araddr63 = {32'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1};
                                              }
   endgroup : cg_r_command

   covergroup cg_r_data; 

      option.per_instance = 1;
      option.goal         = 100;
      option.name         = "r_data";

      cp_rlast : coverpoint r_cov_txn.rlast {
                                             bins rlast0 = {0};
                                             bins rlast1 = {1};
                                            }

      cp_rdata : coverpoint r_cov_txn.rdata[0] {
                                                wildcard bins rdata0   =  {64'b 0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata1   =  {64'b x0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata2   =  {64'b xx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata3   =  {64'b xxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata4   =  {64'b xxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata5   =  {64'b xxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata6   =  {64'b xxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata7   =  {64'b xxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata8   =  {64'b xxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata9   =  {64'b xxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata10  =  {64'b xxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata11  =  {64'b xxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata12  =  {64'b xxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata13  =  {64'b xxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata14  =  {64'b xxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata15  =  {64'b xxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata16  =  {64'b xxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata17  =  {64'b xxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata18  =  {64'b xxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata19  =  {64'b xxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata20  =  {64'b xxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata21  =  {64'b xxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata22  =  {64'b xxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata23  =  {64'b xxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata24  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata25  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata26  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata27  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata28  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata29  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata30  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata31  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata32  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata33  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata34  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata35  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata36  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata37  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata38  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata39  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata40  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata41  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata42  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata43  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata44  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata45  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata46  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata47  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata48  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata49  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxxx}; 
                                                wildcard bins rdata50  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxxx}; 
                                                wildcard bins rdata51  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxxx}; 
                                                wildcard bins rdata52  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxxx}; 
                                                wildcard bins rdata53  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxxx}; 
                                                wildcard bins rdata54  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxxx}; 
                                                wildcard bins rdata55  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxxx}; 
                                                wildcard bins rdata56  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxxx}; 
                                                wildcard bins rdata57  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxxx}; 
                                                wildcard bins rdata58  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxxx}; 
                                                wildcard bins rdata59  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxxx}; 
                                                wildcard bins rdata60  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xxx}; 
                                                wildcard bins rdata61  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0xx}; 
                                                wildcard bins rdata62  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0x}; 
                                                wildcard bins rdata63  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx0}; 
                                                wildcard bins rdata64  =  {64'b 1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata65  =  {64'b x1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata66  =  {64'b xx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata67  =  {64'b xxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata68  =  {64'b xxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata69  =  {64'b xxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata70  =  {64'b xxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata71  =  {64'b xxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata72  =  {64'b xxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata73  =  {64'b xxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata74  =  {64'b xxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata75  =  {64'b xxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata76  =  {64'b xxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata77  =  {64'b xxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata78  =  {64'b xxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata79  =  {64'b xxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata80  =  {64'b xxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata81  =  {64'b xxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata82  =  {64'b xxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata83  =  {64'b xxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata84  =  {64'b xxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata85  =  {64'b xxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata86  =  {64'b xxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata87  =  {64'b xxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata88  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata89  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata90  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata91  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata92  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata93  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata94  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata95  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata96  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata97  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata98  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata99  =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata100 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata101 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata102 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata103 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata104 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata105 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata106 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata107 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata108 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata109 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata110 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata111 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata112 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxxx}; 
                                                wildcard bins rdata113 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxxx}; 
                                                wildcard bins rdata114 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxxx}; 
                                                wildcard bins rdata115 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxxx}; 
                                                wildcard bins rdata116 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxxx}; 
                                                wildcard bins rdata117 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxxx}; 
                                                wildcard bins rdata118 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxxx}; 
                                                wildcard bins rdata119 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxxx}; 
                                                wildcard bins rdata120 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxxx}; 
                                                wildcard bins rdata121 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxxx}; 
                                                wildcard bins rdata122 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxxx}; 
                                                wildcard bins rdata123 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxxx}; 
                                                wildcard bins rdata124 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xxx}; 
                                                wildcard bins rdata125 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1xx}; 
                                                wildcard bins rdata126 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1x}; 
                                                wildcard bins rdata127 =  {64'b xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx1}; 
                                               }

      cp_rstrb : coverpoint r_cov_txn.rstrb[0] {
                                                wildcard bins rstrb0  = {8'b 0xxxxxxx};
                                                wildcard bins rstrb1  = {8'b x0xxxxxx};
                                                wildcard bins rstrb2  = {8'b xx0xxxxx};
                                                wildcard bins rstrb3  = {8'b xxx0xxxx};
                                                wildcard bins rstrb4  = {8'b xxxx0xxx};
                                                wildcard bins rstrb5  = {8'b xxxxx0xx};
                                                wildcard bins rstrb6  = {8'b xxxxxx0x};
                                                wildcard bins rstrb7  = {8'b xxxxxxx0};
                                                wildcard bins rstrb8  = {8'b 1xxxxxxx};
                                                wildcard bins rstrb9  = {8'b x1xxxxxx};
                                                wildcard bins rstrb10 = {8'b xx1xxxxx};
                                                wildcard bins rstrb11 = {8'b xxx1xxxx};
                                                wildcard bins rstrb12 = {8'b xxxx1xxx};
                                                wildcard bins rstrb13 = {8'b xxxxx1xx};
                                                wildcard bins rstrb14 = {8'b xxxxxx1x};
                                                wildcard bins rstrb15 = {8'b xxxxxxx1};
                                               }

      cp_rid : coverpoint r_cov_txn.rid {
                                         bins rid[] = {[0:15]};
                                        }

      cp_rresp : coverpoint r_cov_txn.rresp[0] {
                                                bins rresp0 = {0};
                                                bins rresp2 = {2};
                                                bins rresp3 = {3};
                                               }

      cp_out_of_order : coverpoint out_of_order { 
                                                bins ooo_0 = {0};
                                                bins ooo_1 = {1};
                                               }

   endgroup : cg_r_data



endclass : coverage

   function void coverage :: build_phase (uvm_phase phase);
      super.build_phase (phase);
     `uvm_info ("coverage" , "build_phase" , UVM_MEDIUM)
      w_cov_af  = new ("w_cov_af" , this);
      r_cov_af  = new ("r_cov_af" , this);
      w_cov_exp = new ("w_cov_exp");
      r_cov_exp = new ("r_cov_exp");
      w_cov_txn = w_seq_item :: type_id :: create ("w_cov_txn");
      r_cov_txn = r_seq_item :: type_id :: create ("r_cov_txn");
      arid_txn  = r_seq_item :: type_id :: create ("arid_txn");
      rid_txn   = r_seq_item :: type_id :: create ("rid_txn");
   endfunction : build_phase

   function void coverage :: connect_phase (uvm_phase phase);
      super.connect_phase (phase);
     `uvm_info ("coverage" , "connect_phase" , UVM_MEDIUM)
      w_cov_exp.connect(w_cov_af.analysis_export);
      r_cov_exp.connect(r_cov_af.analysis_export);
   endfunction : connect_phase

   task coverage :: run_phase (uvm_phase phase);
      `uvm_info ("coverage" , "run_phase" , UVM_MEDIUM)
      forever begin
         fork
            begin
               w_cov_af.get(w_cov_txn);
               if(w_cov_txn.w_packet == w_command)begin
                  cg_w_command.sample();
               end
               if(w_cov_txn.w_packet == w_data)begin
                  cg_w_data.sample();
               end
               if(w_cov_txn.w_packet == w_resp)begin
                  cg_w_response.sample();
               end
            end

            begin
               r_cov_af.get(r_cov_txn);
               if(r_cov_txn.r_packet == r_command)begin
                  r_command_queue.push_back(r_cov_txn);
                  cg_r_command.sample();
               end
               if(r_cov_txn.r_packet == r_data)begin
                  if(r_cov_txn.rlast==1)begin
                     r_data_queue.push_back(r_cov_txn);
                     out_of_order_check();
                  end
                  cg_r_data.sample();
               end
            end
         join_none
         #1;
      end
   endtask : run_phase

   function void coverage :: out_of_order_check();
      if(r_data_queue.size>0 && r_command_queue.size>0)begin
         arid_txn = r_command_queue.pop_front();
         rid_txn = r_data_queue.pop_front();
         if(arid_txn.arid == rid_txn.rid)begin
            out_of_order = 0;
         end else begin
            out_of_order = 1;
         end
      end
   endfunction : out_of_order_check
         
