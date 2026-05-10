property p1;
      @(posedge clk) ($rose(awvalid) or $rose(awready)) |-> ##[1:$] ($fell(awvalid) and $fell(awready));
   endproperty

   property p2;
      @(posedge clk) ($rose(arvalid) or $rose(arready)) |-> ##[1:$] ($fell(arvalid) and $fell(arready));
   endproperty

   awvalid_awready : assert property (p1);
   wvalid_wready   : assert property (p2);
