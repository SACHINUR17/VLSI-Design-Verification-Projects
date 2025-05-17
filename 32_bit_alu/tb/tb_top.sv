
`include "uvm_macros.svh"

import uvm_pkg::*;

`include "alu_if.sv"
`include "alu_txn.sv"
`include "alu_seq.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_scoreboard.sv"
`include "alu_agent.sv"
`include "alu_env.sv"
`include "alu_test.sv"

`include "alu.v"

module tb_top;
    bit clk;
    always #5 clk = ~clk;

    alu_if intf(clk);

    alu dut (
        .clk(intf.clk),
        .A(intf.A),
        .B(intf.B),
        .op(intf.op),
        .ALU_Out(intf.ALU_Out)
    );

    initial begin
        uvm_config_db#(virtual alu_if)::set(null, "*", "vif", intf);
        run_test("alu_test");
    end
endmodule
