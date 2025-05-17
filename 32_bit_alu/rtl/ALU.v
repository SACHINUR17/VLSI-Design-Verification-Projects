// 32-bit ALU RTL code goes here
module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [2:0] opcode,
    output logic [31:0] result,
    output logic zero
);

    always_comb begin
        case (opcode)
            3'b000: result = A + B;                  // ADD
            3'b001: result = A - B;                  // SUB
            3'b010: result = A & B;                  // AND
            3'b011: result = A | B;                  // OR
            3'b100: result = A ^ B;                  // XOR
            3'b101: result = A << B[4:0];            // SLL (only lower 5 bits)
            3'b110: result = A >> B[4:0];            // SRL
            3'b111: result = (A < B) ? 32'd1 : 32'd0; // SLT
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);

endmodule
