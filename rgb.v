
//--------------------------------------------------------------------------------------------


module RGB(Din_l, Din_r, Nblank, R, G, B);
   input [3:0]  Din_l;
   input [3:0]  Din_r;
   input        Nblank;
   output [7:0] R;
   output [7:0] G;
   output [7:0] B;
   
   
   wire [7:0]   Gray;
   assign Gray = ((({Din_r[3:0], Din_r[3:0]}) + ({Din_l[3:0], Din_l[3:0]}))/2);
   assign R = (Nblank == 1'b1) ? Gray : 
              8'b00000000;
   assign G = (Nblank == 1'b1) ? Gray : 
              8'b00000000;
   assign B = (Nblank == 1'b1) ? Gray : 
              8'b00000000;
   
endmodule

