
//--------------------------------------------------------------------------------------------


module debounce(clk, i, o);
   input     clk;
   input     i;
   output    o;
   reg       o;
   
   reg [4:0] c;
   
   always @(posedge clk)
      
      begin
         if (i == 1'b1)
         begin
            if (c == 24'hFFFFFF)
               o <= 1'b1;
            else
               o <= 1'b0;
            c <= c + 1;
         end
         else
         begin
            c <= {24{1'b0}};
            o <= 1'b0;
         end
      end
   
endmodule
