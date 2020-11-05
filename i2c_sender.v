//--------------------------------------------------------------------------------------------


module i2c_sender(clk, siod, sioc, taken, send, id, reg_xhdl0, value);
   input       clk;
   inout       siod;
   output      sioc;
   reg         sioc;
   output      taken;
   reg         taken;
   input       send;
   input [7:0] id;
   input [7:0] reg_xhdl0;
   input [7:0] value;
   
   reg [2:0]   divider;
   reg [31:0]  busy_sr;
   reg [31:0]  data_sr;
   
   always @(busy_sr or data_sr[31])
      if (busy_sr[11:10] == 2'b10 | busy_sr[20:19] == 2'b10 | busy_sr[29:28] == 2'b10)
         siod <= 1'bZ;
      else
         siod <= data_sr[31];
   
   
   always @(posedge clk)
      
      begin
         taken <= 1'b0;
         if (busy_sr[31] == 1'b0)
         begin
            sioc <= 1'b1;
            if (send == 1'b1)
            begin
               if (divider == 8'b00000000)
               begin
                  data_sr <= {3'b100, id, 1'b0, reg_xhdl0, 1'b0, value, 1'b0, 2'b01};
                  busy_sr <= {3'b111, 9'b111111111, 9'b111111111, 9'b111111111, 2'b11};
                  taken <= 1'b1;
               end
               else
                  divider <= divider + 1;
            end
         end
         else
         begin
            
            case ({busy_sr[32 - 1:32 - 3], busy_sr[2:0]})
               {3'b111, 3'b111} :
                  case (divider[7:6])
                     2'b00 :
                        sioc <= 1'b1;
                     2'b01 :
                        sioc <= 1'b1;
                     2'b10 :
                        sioc <= 1'b1;
                     default :
                        sioc <= 1'b1;
                  endcase
               {3'b111, 3'b110} :
                  case (divider[7:6])
                     2'b00 :
                        sioc <= 1'b1;
                     2'b01 :
                        sioc <= 1'b1;
                     2'b10 :
                        sioc <= 1'b1;
                     default :
                        sioc <= 1'b1;
                  endcase
               {3'b111, 3'b100} :
                  case (divider[7:6])
                     2'b00 :
                        sioc <= 1'b0;
                     2'b01 :
                        sioc <= 1'b0;
                     2'b10 :
                        sioc <= 1'b0;
                     default :
                        sioc <= 1'b0;
                  endcase
               {3'b110, 3'b000} :
                  case (divider[7:6])
                     2'b00 :
                        sioc <= 1'b0;
                     2'b01 :
                        sioc <= 1'b1;
                     2'b10 :
                        sioc <= 1'b1;
                     default :
                        sioc <= 1'b1;
                  endcase
               {3'b100, 3'b000} :
                  case (divider[7:6])
                     2'b00 :
                        sioc <= 1'b1;
                     2'b01 :
                        sioc <= 1'b1;
                     2'b10 :
                        sioc <= 1'b1;
                     default :
                        sioc <= 1'b1;
                  endcase
               {3'b000, 3'b000} :
                  case (divider[7:6])
                     2'b00 :
                        sioc <= 1'b1;
                     2'b01 :
                        sioc <= 1'b1;
                     2'b10 :
                        sioc <= 1'b1;
                     default :
                        sioc <= 1'b1;
                  endcase
               default :
                  case (divider[7:6])
                     2'b00 :
                        sioc <= 1'b0;
                     2'b01 :
                        sioc <= 1'b1;
                     2'b10 :
                        sioc <= 1'b1;
                     default :
                        sioc <= 1'b0;
                  endcase
            endcase
            
            if (divider == 8'b11111111)
            begin
               busy_sr <= {busy_sr[32 - 2:0], 1'b0};
               data_sr <= {data_sr[32 - 2:0], 1'b1};
               divider <= {8{1'b0}};
            end
            else
               divider <= divider + 1;
         end
      end
   
endmodule
