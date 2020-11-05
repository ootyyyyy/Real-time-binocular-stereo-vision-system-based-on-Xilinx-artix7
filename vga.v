
//--------------------------------------------------------------------------------------------


module VGA(CLK25, clkout, rez_160x120, rez_320x240, Hsync, Vsync, Nblank, activeArea, Nsync, avg_en);
   input      CLK25;
   output     clkout;
   input      rez_160x120;
   input      rez_320x240;
   output     Hsync;
   reg        Hsync;
   output     Vsync;
   reg        Vsync;
   output     Nblank;
   output     activeArea;
   reg        activeArea;
   output     Nsync;
   output     avg_en;
   reg        avg_en;
   
   reg [9:0]  Hcnt;
   reg [9:0]  Vcnt;
   wire       video;
   
   parameter  HM = 799;
   parameter  HD = 640;
   parameter  HF = 16;
   parameter  HB = 48;
   parameter  HR = 96;
   parameter  VM = 524;
   parameter  VD = 480;
   parameter  VF = 10;
   parameter  VB = 33;
   parameter  VR = 2;
   
   
   always @(posedge CLK25)
      
      begin
         if (Hcnt == HM)
         begin
            Hcnt <= 10'b0000000000;
            if (Vcnt == VM)
            begin
               Vcnt <= 10'b0000000000;
               activeArea <= 1'b1;
            end
            else
            begin
               if (rez_160x120 == 1'b1)
               begin
                  if (Vcnt < 120 - 1)
                     activeArea <= 1'b1;
               end
               else if (rez_320x240 == 1'b1)
               begin
                  if (Vcnt < 240 - 1)
                     activeArea <= 1'b1;
               end
               else
                  if (Vcnt < 480 - 1)
                     activeArea <= 1'b1;
               Vcnt <= Vcnt + 1;
            end
         end
         else
         begin
            if (rez_160x120 == 1'b1)
            begin
               if (Hcnt == 160 - 1)
                  activeArea <= 1'b0;
            end
            else if (rez_320x240 == 1'b1)
            begin
               if (Hcnt < 320)
                  avg_en <= 1'b0;
               else
                  avg_en <= 1'b1;
               if (Hcnt == 640 - 1)
                  activeArea <= 1'b0;
            end
            else
               if (Hcnt == 640 - 1)
                  activeArea <= 1'b0;
            Hcnt <= Hcnt + 1;
         end
      end
   
   
   always @(posedge CLK25)
      
      begin
         if (Hcnt >= (HD + HF) & Hcnt <= (HD + HF + HR - 1))
            Hsync <= 1'b0;
         else
            Hsync <= 1'b1;
      end
   
   
   always @(posedge CLK25)
      
      begin
         if (Vcnt >= (VD + VF) & Vcnt <= (VD + VF + VR - 1))
            Vsync <= 1'b0;
         else
            Vsync <= 1'b1;
      end
   
   assign Nsync = 1'b1;
   assign video = ((Hcnt < HD) & (Vcnt < VD)) ? 1'b1 : 
                  1'b0;
   assign Nblank = video;
   assign clkout = CLK25;
   
endmodule



