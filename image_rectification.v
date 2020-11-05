//--------------------------------------------------------------------------------------------


module Image_Rectification(address_in, plus, minus, plus_col, minus_col, CLK, exposure, address_left, address_right);
   input [16:0]  address_in;
   input         plus;
   input         minus;
   input         plus_col;
   input         minus_col;
   input         CLK;
   output [15:0] exposure;
   output [16:0] address_left;
   output [16:0] address_right;
   
   
   reg [3:0]     adjust;
   reg [7:0]     adjust_vert;
   
   reg [15:0]    counter;
   
   assign address_left = address_in;
   assign address_right = (address_in + (adjust * 320) + adjust_vert);
   
   
   always @(posedge CLK)
   begin: caliberate_alignment_process
      
      begin
         counter <= counter + 1'b1;
         if (plus == 1'b1 & counter == 16'hffff)
            adjust <= adjust + 1'b1;
         if (minus == 1'b1 & counter == 16'hffff)
            adjust <= adjust - 1'b1;
      end
   end
   
   always @(posedge CLK)
   begin: caliberate_exposure_process
      
      begin
         if (plus_col == 1'b1 & counter == 16'hffff)
            adjust_vert <= adjust_vert + 1'b1;
         if (minus_col == 1'b1 & counter == 16'hffff)
            adjust_vert <= adjust_vert - 1'b1;
      end
   end
   
endmodule

