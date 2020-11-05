`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/04/2015 11:29:02 AM
// Design Name: 
// Module Name: transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module transmitter(
input clk, 
input reset, 
input transmit, 
input [7:0] data, 
output reg TxD 
    );


reg [3:0] bitcounter; 
reg [13:0] counter; 
reg state,nextstate; 

reg [9:0] rightshiftreg; 
reg shift; 
reg load;
reg clear; 


always @ (posedge clk) 
begin 
    if (reset) 
	   begin 
        state <=0;
        counter <=0; 
        bitcounter <=0;
       end
    else begin
         counter <= counter + 1; 
            if (counter >= 10415) 
               begin 
                  state <= nextstate;
                  counter <=0;
            	  if (load) rightshiftreg <= {1'b1,data,1'b0};
		          if (clear) bitcounter <=0; 
                  if (shift) 
                     begin 
                        rightshiftreg <= rightshiftreg >> 1;
                        bitcounter <= bitcounter + 1; 
                     end
               end
         end
end 



always @ (posedge clk) 

begin
    load <=0; 
    shift <=0;
    clear <=0; 
    TxD <=1; 
    case (state)
        0: begin 
             if (transmit) begin 
             nextstate <= 1;
             load <=1; 
             shift <=0; 
             clear <=0; 
             end 
		else begin 
             nextstate <= 0; 
             TxD <= 1; 
             end
           end
        1: begin  
             if (bitcounter >=10) begin 
             nextstate <= 0;
             clear <=1; 
             end 
		else begin 
             nextstate <= 1; 
             TxD <= rightshiftreg[0];
             shift <=1; 
             end
           end
         default: nextstate <= 0;                      
    endcase
end


endmodule

