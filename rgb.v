
//--------------------------------------------------------------------------------------------


module RGB(Din, Din_avg, Nblank, R, G, B, avg_en);
   input [7:0]  Din;
   input [3:0]  Din_avg;
   input        Nblank;
   output [7:0] R;
   output [7:0] G;
   output [7:0] B;
   input        avg_en;
   
   wire [7:0]   vga_out;
   
   assign vga_out = (avg_en == 1'b0) ? Din : 
                    (avg_en == 1'b1) ? {Din_avg, Din_avg} : 
   
   assign R = (Nblank == 1'b1) ? (vga_out) : 
              8'b00000000;
   assign G = (Nblank == 1'b1) ? (vga_out) : 
              8'b00000000;
   assign B = (Nblank == 1'b1) ? (vga_out) : 
              8'b00000000;
   
endmodule
