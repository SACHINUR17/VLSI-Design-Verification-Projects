`timescale 1ns / 1ps

module axi_slave(
input clk,arvalid,res_n,
input [1:0]arburst,
input [2:0]arsize,
input [3:0]arlen,
input [4:0]araddr,
output arready,

input awvalid,
input [4:0]awaddr,
output awready,
input [3:0]awlen,
input [1:0]awburst,
input [2:0]awsize,

input wvalid,
input [15:0]wdata,
output wready,
input wlast,

input bready,
output bvalid,
output bresp,

output reg [15:0]rdata,
output rresp,rlast,
input rready,
output rvalid
    );
    
    parameter [3:0]IDLE = 4'b0001,SETUP = 4'b0010, PREACCESS = 4'b0100,ACCESS = 4'b1000,
                                  SETUPW = 4'b0011, PREACCESSW = 4'b0111,ACCESSW = 4'b1111,
                                  WTERMINATE = 4'b0101;
    reg [3:0]current_state,next_state=IDLE;
    reg [1:0]burst;
    reg [2:0]size;
    reg [3:0]len;
    reg [31:0]addr;
    reg last;
    reg [15:0]memory[31:0];
    initial
      begin
        memory[0] = 16'hffff;
        memory[1] = 16'h1111;
        memory[2] = 16'h2222;
        memory[3] = 16'h1234;
        memory[4] = 16'h7890;
        memory[5] = 16'h1111;
      end
      
      
    always@(posedge clk,negedge res_n)
    begin
    if(!res_n)
      current_state <= IDLE;
    else 
      current_state <= next_state; 
    end
    
    always@(current_state,arvalid,rready,awvalid,wvalid,bready)
    begin
    case(current_state)
    IDLE : begin
             last = 0;
             rdata = 32'b0;
             if(arvalid)
               next_state <= SETUP;
             else if(awvalid)
               next_state <= SETUPW;
             else 
               next_state <= IDLE;
           end
           
    SETUPW : begin
               if(awvalid)
                 begin
                   burst = awburst;
                   size = awsize;
                   len = awlen + 1;
                   addr =  awaddr;
                   next_state <= PREACCESSW;
                 end
               else 
                 next_state <= IDLE;
             end
             
    PREACCESSW : begin
                   if(wvalid)
                     next_state <= ACCESSW;
                   else 
                     next_state <= PREACCESSW;
                 end
         
    ACCESSW : begin
                if(len != 4'd0)
                  begin
                    if(wlast)
                      next_state <= WTERMINATE;
                    else 
                      next_state <= PREACCESSW;
                    case(size)
                      3'b000: memory[addr] = {8'd0,wdata[7:0]} ;
                      3'b001: memory[addr] = wdata;
                      default : memory[addr] = 16'd0;
                    endcase
                    case(burst)
                      2'b00: addr = addr;
                      2'b01: addr = addr + 1;
                      default : addr = addr;
                    endcase
                    len = len - 1; 
                  end
                else 
                  next_state <= WTERMINATE;
              end  
              
    WTERMINATE : begin
                   if(bready)
                     next_state <= IDLE;
                   else 
                     next_state <= WTERMINATE;
                 end
       
    SETUP : begin
              if(arvalid)
                begin
                  burst = arburst;
                  size = arsize;
                  len = arlen + 1;
                  addr = araddr;
                  next_state <= PREACCESS; 
                end
              else
                next_state <= IDLE;
            end
    PREACCESS : begin
                  rdata = 32'd0;
                  if(rready)
                    next_state <= ACCESS;
                  else 
                    next_state <= PREACCESS;
                end
    ACCESS : begin
               if(len != 4'd0)
                 begin
                   if(len == 4'd1)
                     begin
                       last = 1;
                       next_state <= IDLE;
                     end
                   else 
                     next_state <= PREACCESS;
                   case(size)
                       3'b000 : rdata = (memory[addr] & 16'h00ff);
                     3'b001 : rdata = memory[addr];
                     default : rdata = 16'd0;
                   endcase
                   case(burst)
                     2'b00 : addr = addr;
                     2'b01 : addr = addr + 1;
                     default : addr = addr;
                   endcase
                   len = len - 1;
                 end
               else
                 next_state <= IDLE;
             end
          
    default : next_state <= IDLE; 
    endcase
    end 
    
    assign arready = (current_state == SETUP);
    assign rresp = (current_state == ACCESS);
    assign rlast = (rresp && last);
    assign rvalid = (current_state == ACCESS);
    assign awready = (current_state == SETUPW);
    assign wready = (current_state == ACCESSW);
    assign bresp = (current_state == WTERMINATE);
    assign bvalid = (current_state == WTERMINATE);
    
endmodule
