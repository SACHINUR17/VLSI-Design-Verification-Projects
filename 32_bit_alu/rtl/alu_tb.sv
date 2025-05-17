// tb_top.sv
`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import alu_test_pkg::*;

    // Interface
    alu_if alu_if0();

    // DUT instantiation
    alu dut (
        .A      (alu_if0.A),
        .B      (alu_if0.B),
        .opcode (alu_if0.opcode),
        .result (alu_if0.result),
        .zero   (alu_if0.zero)
    );

    // Run the test
    initial begin
        run_test("alu_test");
    end

endmodule
