`ifndef SCOREBOARD
`define SCOREBOARD

`uvm_analysis_imp_decl(_drv_pkt)
`uvm_analysis_imp_decl(_mon_pkt)

class AXI_Scoreboard#(int WIDTH=32,SIZE=3) extends uvm_scoreboard;
 
  `uvm_component_utils(AXI_Scoreboard#(WIDTH,SIZE))

  axi_m_Sequence_Item#(WIDTH,SIZE) tx,tx_drv;
  axi_m_Sequence_Item#(WIDTH,SIZE) que[$];
  uvm_analysis_imp_mon_pkt#(axi_m_Sequence_Item#(WIDTH,SIZE), AXI_Scoreboard#(WIDTH,SIZE)) mon2sb_port;
  uvm_analysis_imp_drv_pkt#(axi_m_Sequence_Item#(WIDTH,SIZE), AXI_Scoreboard#(WIDTH,SIZE)) drv2sb_port;
  virtual axi_intf#(WIDTH,SIZE) intf;
  byte unsigned ram [1024];
  int unsigned successfully_match=0,not_match=0,read_before_write=0,data_write=0,data_write_not_possible_due_to_WSTRB_bit;
  int unsigned write_pkt_success=0,write_pkt_failure=0, read_pkt_success=0,read_pkt_failure=0;
  
  function new(string name="AXI_Scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction : new 
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //tx=new("tx");
    mon2sb_port = new("mon2sb_port", this);
    drv2sb_port = new("drv2sb_port", this);
    if(!uvm_config_db#(virtual axi_intf#(WIDTH,SIZE))::get(this, "", "intf", intf))
    `uvm_fatal("NO_VIF","virtual interface not found");
  endfunction : build_phase 

  virtual function void write_mon_pkt (axi_m_Sequence_Item#(WIDTH,SIZE) pkt);
    `uvm_info("SCOREBOARD","pkt From Monitor to Scoreboard",UVM_MEDIUM)
    pkt.print();
    compare (pkt);
  endfunction 
   
  virtual function void write_drv_pkt (axi_m_Sequence_Item#(WIDTH,SIZE) pkt);
   // `uvm_info("SCOREBOARD","pkt From Driver to Scoreboard",UVM_MEDIUM)
  //  pkt.print();
  que.push_back(pkt);
  endfunction 
   
  function void compare(axi_m_Sequence_Item#(WIDTH,SIZE) tx);
    `uvm_info("SCOREBOARD","pkt From Driver to Scoreboard",UVM_MEDIUM)
    tx_drv = que.pop_front();
    tx_drv.print();
    if (!$isunknown(tx.AWID))
      begin
        if (tx.AWID==tx_drv.AWID && tx.AWSIZE==tx_drv.AWSIZE && tx.AWADDR==tx_drv.AWADDR && tx.AWBURST==tx_drv.AWBURST && tx.AWLEN == tx_drv.AWLEN /* && tx.WID == tx_drv.WID && tx.WSTRB == tx_drv.WSTRB && tx.BID == tx_drv.BID */)
	  begin
            `uvm_info("SCOREBOARD","Comparison Successfully of both packet in write part",UVM_MEDIUM)
            write_pkt_success++;
          end
          else
            begin
              `uvm_error("SCOREBOARD","Comparison failure of packet in write operation")
              write_pkt_failure++;   
            end
        for(int i=0;i<((tx.AWLEN+1)*(2**tx.AWSIZE));i++)
          begin
	    if (i==0 && tx.AWBURST==2'b10) tx.AWADDR=(tx.AWADDR/(2**tx.AWSIZE))*(2**tx.AWSIZE);  //BUG solved at 4:16 PM 12/4/18
            if(tx.WSTRB[i/(2**tx.AWSIZE)][i%(2**tx.AWSIZE)])
              begin
                //$display ("valu1=%d valu2=%d",i/(2**tx.AWSIZE),i%(2**tx.AWSIZE));
                case(tx.AWBURST)
                  2'b00 :  ram[tx.AWADDR] = tx.WDATA[i];
                  2'b01 :  ram[tx.AWADDR+i] = tx.WDATA[i];
                  2'b10 :  ram[tx.AWADDR+i] = tx.WDATA[i];
                  default : `uvm_error("SCOREBOARD","AWBURST value can't be 2'b11")
                endcase
                data_write++;
                `uvm_info("SCOREBOARD",$psprintf("Write ram[%h]=%h WDATA[%h]=%h",tx.AWADDR+i,ram[tx.AWADDR+i],i,tx.WDATA[i]),UVM_HIGH)
                `uvm_info("SCOREBOARD","Data write in scoreboard",UVM_HIGH)
              end
            else data_write_not_possible_due_to_WSTRB_bit++;
          end
      end
    else
      begin
        if (tx.ARID==tx_drv.ARID && tx.ARSIZE==tx_drv.ARSIZE && tx.ARADDR==tx_drv.ARADDR && tx.ARBURST==tx_drv.ARBURST && tx.ARLEN == tx_drv.ARLEN /* && tx.RID == tx_drv.RID */)
          begin
	    `uvm_info("SCOREBOARD","Comparison Successfully of both packet in read part",UVM_MEDIUM)
            read_pkt_success++;
          end   
         else
           begin
             `uvm_error("SCOREBOARD","Comparison failure of packet in read operation")
             read_pkt_failure++;
           end
        for(int i=0;i<((tx.ARLEN+1)*(2**tx.ARSIZE));i++)
          begin
            case(tx.ARBURST)
              2'b00 :  tx.ARADDR = (i==0) ? tx.ARADDR  : (tx.ARADDR-1); 
              2'b01 :  tx.ARADDR = tx.ARADDR;
              2'b10 :  tx.ARADDR = (i==0)?((tx.ARADDR/(2**tx.ARSIZE))*(2**tx.ARSIZE)):(tx.AWADDR);
              default : `uvm_error("SCOREBOARD","AWBURST value can't be 2'b11")
            endcase
            if(tx.RDATA[i]==00 && ram[tx.ARADDR+i]==00 || ram[tx.ARADDR+i]==00 || tx.RDATA[i]==00)
              begin
                read_before_write++;
                `uvm_info("SCOREBOARD","Read before write in scoreboard",UVM_HIGH)
                `uvm_info("SCOREBOARD",$psprintf("Read ram[%h]=%h RDATA[%h]=%h",tx.ARADDR+i,ram[tx.ARADDR+i],i,tx.RDATA[i]),UVM_HIGH)
              end
            else if(tx.RDATA[i]==ram[tx.ARADDR+i])
              begin	
                successfully_match++;
                `uvm_info("SCOREBOARD","Data read comaparison successfully",UVM_HIGH)
                `uvm_info("SCOREBOARD",$psprintf("Read ram[%h]=%h RDATA[%h]=%h",tx.ARADDR+i,ram[tx.ARADDR+i],i,tx.RDATA[i]),UVM_HIGH)
              end 
            else
              begin
                not_match++;
                `uvm_error("SCOREBOARD",$psprintf("Read Comparison failure\n\t\t ID=%h Read ram[%h]=%h RDATA[%h]=%h",tx.ARID,tx.ARADDR+i,ram[tx.ARADDR+i],i,tx.RDATA[i]))
              end
          end
      end
  endfunction:compare

  function void extract_phase(uvm_phase phase);
      super.extract_phase(phase);
      `uvm_info("SCOREBOARD", $psprintf("\n\n  SUCCESSFULLY DATA WRITE=%0d\n  SUCCESSFULLY MATCH=%0d\n  READ BEFORE WRITE=%0d\n  DATA WRITE NOT POSSIBLE DUE TO WSTRB BIT IS 0 =%0d\n  NOT MATCH=%0d\n\n  write pkt success=%0d\n  write pkt failure=%0d\n  read pkt success=%0d\n  read pkt failure=%0d\n  total packets=%0d \n ",data_write,successfully_match,read_before_write,data_write_not_possible_due_to_WSTRB_bit,not_match,write_pkt_success,write_pkt_failure,read_pkt_success,read_pkt_failure,(write_pkt_success+write_pkt_failure+read_pkt_success+read_pkt_failure)), UVM_NONE)  
  endfunction 

endclass
`endif
