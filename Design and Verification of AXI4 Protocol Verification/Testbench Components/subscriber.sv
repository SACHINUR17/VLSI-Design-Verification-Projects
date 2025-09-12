`ifndef AXI_SUBSCRIBER
`define AXI_SUBSCRIBER

class subscriber extends uvm_subscriber#(transaction);
   `uvm_component_utils(subscriber)

   transaction trans;
   uvm_tlm_analysis_fifo#(transaction) mon2scor;

   function new(string name="agent",uvm_component parent=null);
      super.new(name,parent);
      axi_cg=new();
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon2scor=new("mon2scor",this);
   endfunction

   function void write(T t);
      axi_cg.sample();
   endfunction

   int write_data_count;
   int read_data_count;
   int wdata;
   int rdata;
   int awaddr;
   int araddr;
   task run_phase(uvm_phase phase);
      forever begin
         mon2scor.get(trans);
         repeat(trans.awlen+1) begin
            wdata = trans.wdata[write_data_count];
            rdata = trans.rdata[read_data_count];
            awaddr = trans.awaddr[write_data_count];
            araddr = trans.araddr[read_data_count];
            read_data_count++;
            write_data_count++;
            write(trans);
         end
      end
   endtask

   covergroup axi_cg;
      cp1:coverpoint awaddr {bins b1={[0:16'hffff]};}
      cp2:coverpoint araddr {bins b3={[0:16'hffff]};}
      cp3:coverpoint wdata  {bins b2={[0:32'hffff_ffff]};}
      cp4:coverpoint rdata  {bins b4={[0:32'hffff_ffff]};}
   endgroup

    function void check_phase(uvm_phase phase);
      $display("-------------------------------------------------------------");
      `uvm_info("MY_COVERAGE",$sformatf("%0d",axi_cg.get_coverage()),UVM_NONE);
      $display("-------------------------------------------------------------");
   endfunction


endclass

`endif
