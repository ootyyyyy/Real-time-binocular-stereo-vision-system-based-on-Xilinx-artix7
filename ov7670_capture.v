
//--------------------------------------------------------------------------------------------


module ov7670_capture(pclk, vsync, href, d, addr, dout, we);
   input         pclk;
   input         vsync;
   input         href;
   input [7:0]   d;
   output [16:0] addr;
   output [11:0] dout;
   output        we;
   
   reg [15:0]    d_latch;
   reg [16:0]    address;
   reg [1:0]     line;
   reg [6:0]     href_last;
   reg           we_reg;
   reg           href_hold;
   reg           latched_vsync;
   reg           latched_href;
   reg [7:0]     latched_d;
   assign addr = address;
   assign we = we_reg;
   assign dout = {d_latch[15:12], d_latch[10:7], d_latch[4:1]};
   
   
   always @(posedge pclk)
   begin: capture_process
      
      begin
         if (we_reg == 1'b1)
            address <= (address + 1);
         
         if (href_hold == 1'b0 & latched_href == 1'b1)
            case (line)
               2'b00 :
                  line <= 2'b01;
               2'b01 :
                  line <= 2'b10;
               2'b10 :
                  line <= 2'b11;
               default :
                  line <= 2'b00;
            endcase
         href_hold <= latched_href;
         
         if (latched_href == 1'b1)
            d_latch <= {d_latch[7:0], latched_d};
         we_reg <= 1'b0;
         
         if (latched_vsync == 1'b1)
         begin
            address <= {17{1'b0}};
            href_last <= {7{1'b0}};
            line <= {2{1'b0}};
         end
         else
            if (href_last[2] == 1'b1)
            begin
               if (line[1] == 1'b1)
                  we_reg <= 1'b1;
               href_last <= {7{1'b0}};
            end
            else
               href_last <= {href_last[6 - 1:0], latched_href};
      end
      if (negedge pclk)
      begin
         latched_d <= d;
         latched_href <= href;
         latched_vsync <= vsync;
      end
   end
   
endmodule
