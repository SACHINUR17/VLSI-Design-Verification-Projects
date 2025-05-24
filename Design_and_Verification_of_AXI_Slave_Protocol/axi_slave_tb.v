`timescale 1ns / 1ps

module axi_slave_tb;
reg clk,arvalid,res_n;
reg [1:0]arburst;
reg [2:0]arsize;
reg [3:0]arlen;
reg [4:0]araddr;
wire arready;
wire [15:0]rdata;
wire rresp,rlast;
reg rready;
wire rvalid;

reg awvalid;
reg [4:0]awaddr;
wire awready;
reg [3:0]awlen;
reg [1:0]awburst;
reg [2:0]awsize;

reg wvalid;
reg [15:0]wdata;
wire wready;
reg wlast;

reg bready;
wire bvalid;
wire bresp;


axi_slave uut(clk,arvalid,res_n,arburst,arsize,arlen,araddr,arready,awvalid ,awaddr,
              awready,awlen,awburst,awsize,wvalid,wdata,wready,wlast,bready,bvalid,bresp,rdata,rresp,rlast,rready,rvalid);

always #5 clk = ~clk;
initial
begin
res_n = 0;
clk = 0;
arvalid = 0;
arburst = 2'b00;
arsize = 3'b000;
arlen = 4'b0000;
araddr = 5'b00000;
rready = 0;
awvalid = 0;
awburst = 2'b00;
awsize = 3'b000;
awlen = 4'b0000;
awaddr=5'b00000;
wlast = 0;
bready = 0;
wdata = 0;
wvalid = 0;
end

initial
begin
#30 res_n=1;
#5 arvalid = 1;arburst = 2'b01;arsize = 3'b000;arlen = 4'b0011;araddr=5'b00000;
#10;
#10 arvalid = 0;arburst = 2'b00;arsize = 3'b000;arlen = 4'b0000;araddr=5'b00000;
#10 rready = 1;
#10;
#10;
#10;
#10;
#10;
#10;
#10;
#10;
#10;
#10 rready = 0;
#10;
#10 res_n = 1;
#10 awvalid = 1;awburst = 2'b01;awsize =3'b001;awlen=4'b0011;awaddr = 5'b00000;
#10;
#10 awvalid = 0;awburst = 2'b00;awsize = 3'b000;awlen = 4'b0000;awaddr=5'b00000;
#10 wvalid = 1;wdata = 16'hff11;
#10;
#10 wdata = 16'h11aa;
#10;
#10 wdata = 16'h0011;
#10;
#10 wdata = 16'h1110;wlast = 1;
#10;
#10 wlast = 0; 
#10 bready = 1;
#10 bready = 0;
#10;
#10 res_n=1;
#10 arvalid = 1;arburst = 2'b01;arsize = 3'b001;arlen = 4'b0011;araddr=5'b00000;
#10;
#10 arvalid = 0;arburst = 2'b00;arsize = 3'b000;arlen = 4'b0000;araddr=5'b00000;
#10 rready = 1;
#10;
#10;
#10;
#10;
#10;
#10;
#10;
#10;
#10;
#10 rready = 0;
#10;
 $finish;
end
endmodule
