
interface alu_if(input bit clk);
    logic [31:0] A, B;
    logic [3:0] op;
    logic [31:0] ALU_Out;
endinterface
