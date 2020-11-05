
//--------------------------------------------------------------------------------------------


module ov7670_controller_left(clk, resend, config_finished, sioc, siod, reset, pwdn, xclk);
   input           clk;
   input           resend;
   output          config_finished;
   output          sioc;
   inout           siod;
   output          reset;
   output          pwdn;
   output          xclk;
   
   
   reg             sys_clk;
   wire [15:0]     command;
   wire            finished;
   wire            taken;
   wire            send;
   
   parameter [7:0] camera_address = 8'h42;
   assign config_finished = finished;
   
   assign send = (~finished);
   
   i2c_sender Inst_i2c_sender(.clk(clk), 
							.taken(taken), 
							.siod(siod), 
							.sioc(sioc), 
							.send(send), 
							.id(camera_address),
							.reg_xhdl0(command[15:8]), 
							.value(command[7:0]));
   
   assign reset = 1'b1;
   assign pwdn = 1'b0;
   assign xclk = sys_clk;
   
   
   ov7670_registers_left Inst_ov7670_registers_left(.clk(clk), 
													.advance(taken), 
													.command(command),
													.finished(finished), 
													.resend(resend));
   
   
   always @(posedge clk)
      
         sys_clk <= (~sys_clk);
   
endmodule
