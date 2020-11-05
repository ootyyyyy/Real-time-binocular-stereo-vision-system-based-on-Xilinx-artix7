//--------------------------------------------------------------------------------------------


module ov7670_registers(clk, resend, advance, command, finished);
   input         clk;
   input         resend;
   input         advance;
   output [15:0] command;
   output        finished;
   
   reg [15:0]    sreg;
   reg [7:0]     address;
   assign command = sreg;
   assign finished = (sreg == 16'hFFFF) ? 1'b1 : 
                     1'b0;
   
   
   always @(posedge clk)
      
      begin
         if (resend == 1'b1)
            address <= {8{1'b0}};
         else if (advance == 1'b1)
            address <= (address + 1);
         
         case (address)
            8'h00 :
               sreg <= 16'h1280;
            8'h01 :
               sreg <= 16'h1280;
            8'h02 :
               sreg <= 16'h1200;
            8'h03 :
               sreg <= 16'h1100;
            8'h04 :
               sreg <= 16'h0C00;
            8'h05 :
               sreg <= 16'h3E00;
            
            8'h06 :
               sreg <= 16'h8C00;
            8'h07 :
               sreg <= 16'h0400;
            8'h08 :
               sreg <= 16'h4010;
            8'h09 :
               sreg <= 16'h3a04;
            8'h0A :
               sreg <= 16'h1438;
            8'h0B :
               sreg <= 16'h4fb3;
            8'h0C :
               sreg <= 16'h50b3;
            8'h0D :
               sreg <= 16'h5100;
            8'h0E :
               sreg <= 16'h523d;
            8'h0F :
               sreg <= 16'h53a7;
            8'h10 :
               sreg <= 16'h54e4;
            8'h11 :
               sreg <= 16'h589e;
            8'h12 :
               sreg <= 16'h3dc0;
            8'h13 :
               sreg <= 16'h1100;
            
            8'h14 :
               sreg <= 16'h1711;
            8'h15 :
               sreg <= 16'h1861;
            8'h16 :
               sreg <= 16'h32A4;
            
            8'h17 :
               sreg <= 16'h1903;
            8'h18 :
               sreg <= 16'h1A7b;
            8'h19 :
               sreg <= 16'h030a;
            
            8'h1A :
               sreg <= 16'h0e61;
            8'h1B :
               sreg <= 16'h0f4b;
            
            8'h1C :
               sreg <= 16'h1602;
            8'h1D :
               sreg <= 16'h1e37;
            
            8'h1E :
               sreg <= 16'h2102;
            8'h1F :
               sreg <= 16'h2291;
            
            8'h20 :
               sreg <= 16'h2907;
            8'h21 :
               sreg <= 16'h330b;
            
            8'h22 :
               sreg <= 16'h350b;
            8'h23 :
               sreg <= 16'h371d;
            
            8'h24 :
               sreg <= 16'h3871;
            8'h25 :
               sreg <= 16'h392a;
            
            8'h26 :
               sreg <= 16'h3c78;
            8'h27 :
               sreg <= 16'h4d40;
            
            8'h28 :
               sreg <= 16'h4e20;
            8'h29 :
               sreg <= 16'h6900;
            
            8'h2A :
               sreg <= 16'h6b4a;
            8'h2B :
               sreg <= 16'h7410;
            
            8'h2C :
               sreg <= 16'h8d4f;
            8'h2D :
               sreg <= 16'h8e00;
            
            8'h2E :
               sreg <= 16'h8f00;
            8'h2F :
               sreg <= 16'h9000;
            
            8'h30 :
               sreg <= 16'h9100;
            8'h31 :
               sreg <= 16'h9600;
            
            8'h32 :
               sreg <= 16'h9a00;
            8'h33 :
               sreg <= 16'hb084;
            
            8'h34 :
               sreg <= 16'hb10c;
            8'h35 :
               sreg <= 16'hb20e;
            
            8'h36 :
               sreg <= 16'hb382;
            8'h37 :
               sreg <= 16'hb80a;
            
            default :
               sreg <= 16'hffff;
         endcase
      end
   
endmodule
