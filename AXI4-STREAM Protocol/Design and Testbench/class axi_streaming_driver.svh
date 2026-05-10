class axi_streaming_driver_c #(parameter DATA_WIDTH=64) extends uvm_driver#(axi_streaming_transaction_c#(DATA_WIDTH));

virtual axi_streaming_interface_c intf;

typedef axi_streaming_driver_c#(DATA_WIDTH) this_driver_t;
typedef axi_streaming_transaction_c#(DATA_WIDTH) trans_t;

trans_t axi_trans_q[$];

trans_t trans1;


int unsigned packet_no;

  `uvm_component_param_utils(axi_streaming_driver_c)
  
  const static string type_name = {"axi_streaming_driver_c"};
  virtual function string get_type_name();
    return type_name;
  endfunction
  
function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if(!uvm_config_db#(virtual axi_streaming_interface_c)::get(this, "", "intf", intf))
  `uvm_fatal("NO_INTF",{"virtual interface must be set for:",get_full_name(),".intf"});
endfunction

function new (input string name="axi_streaming_driver_c", input uvm_component parent = null);
  trans_t trans;
  super.new(name, parent);
  repeat(10)
  begin
    trans = new();
    trans.randomize();
    `uvm_info(get_name(),"DRIVER - SEQ_ITEM",UVM_LOW)
    trans.print();
    //`uvm_info(get_name(),"DRIVER - TRANS",UVM_LOW)
    //trans.print();
    axi_trans_q.push_back(trans);
  end
endfunction

task run_phase(uvm_phase phase);
  super.run_phase(phase);
  phase.raise_objection(this);
  #100ns;
  
  `uvm_info(get_name(),"DRIVER - Inside RUN phase",UVM_LOW)
  if(DATA_WIDTH == 64 || DATA_WIDTH == 128 || DATA_WIDTH == 256)
    drive_64_128_256();
  else
    drive_512();
  phase.drop_objection(this);
endtask

task drive_64_128_256();
  `uvm_info(get_name(),"Drive task for 64/128/256 bit Interface",UVM_LOW)
  intf.tready = 0;
  intf.tvalid = 0;
  //wait(axi_trans_q.size > 0);
  do
    begin
      trans1 = axi_trans_q.pop_front();
      repeat(trans1.tvalid_delay) @(intf.aclk);
      intf.tvalid = 1;
      packet_no++;

     trans1.tdata = new[1];

      `uvm_info(get_name(),$sformatf("Packet Number : %0d and Data : %0h",packet_no,trans1.tdata[0]),UVM_LOW)
      intf.tdata = trans1.tdata[0];
      begin
        repeat(trans1.tready_delay)
        @(intf.aclk);
        intf.tready = 1;
      end
    end
  while(axi_trans_q.size != 0);
  packet_no = 0;
  intf.tready = 0;
  intf.tvalid = 0;
endtask

task drive_512();
 `uvm_info(get_name(),"Drive task for 512 bit Interface",UVM_LOW)
endtask

endclass


class my_test extends uvm_test;
  
  `uvm_component_utils(my_test)
  
  axi_streaming_driver_c#(64) driver;
  
  function new (input string name="my_test", input uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    driver = axi_streaming_driver_c#(64)::type_id::create("driver",this);
  endfunction

endclass
