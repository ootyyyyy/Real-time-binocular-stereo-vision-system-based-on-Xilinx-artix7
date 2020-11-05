
//--------------------------------------------------------------------------------------------


module i3c2(clk, inst_address, inst_data, i2c_scl, i2c_sda, inputs, outputs, reg_addr, reg_data, reg_write, error);
   parameter [7:0] clk_divide = 0;
   
   input           clk;
   output [9:0]    inst_address;
   input [8:0]     inst_data;
   output          i2c_scl;
   reg             i2c_scl;
   inout           i2c_sda;
   input [15:0]    inputs;
   output [15:0]   outputs;
   reg [15:0]      outputs;
   output [4:0]    reg_addr;
   reg [4:0]       reg_addr;
   output [7:0]    reg_data;
   reg [7:0]       reg_data;
   output          reg_write;
   reg             reg_write;
   output          error;
   reg             error;
   
   
   parameter [3:0] STATE_RUN = 4'b0000;
   parameter [3:0] STATE_DELAY = 4'b0001;
   parameter [3:0] STATE_I2C_START = 4'b0010;
   parameter [3:0] STATE_I2C_BITS = 4'b0011;
   parameter [3:0] STATE_I2C_STOP = 4'b0100;
   reg [3:0]       state;
   
   parameter [3:0] OPCODE_JUMP = 4'b0000;
   parameter [3:0] OPCODE_SKIPSET = 4'b0001;
   parameter [3:0] OPCODE_SKIPCLEAR = 4'b0010;
   parameter [3:0] OPCODE_SET = 4'b0011;
   parameter [3:0] OPCODE_CLEAR = 4'b0100;
   parameter [3:0] OPCODE_I2C_READ = 4'b0101;
   parameter [3:0] OPCODE_DELAY = 4'b0110;
   parameter [3:0] OPCODE_SKIPACK = 4'b0111;
   parameter [3:0] OPCODE_SKIPNACK = 4'b1000;
   parameter [3:0] OPCODE_NOP = 4'b1001;
   parameter [3:0] OPCODE_I2C_STOP = 4'b1010;
   parameter [3:0] OPCODE_I2C_WRITE = 4'b1011;
   parameter [3:0] OPCODE_WRITELOW = 4'b1100;
   parameter [3:0] OPCODE_WRITEHI = 4'b1101;
   parameter [3:0] OPCODE_UNKNOWN = 4'b1110;
   wire [3:0]      opcode;
   
   reg             ack_flag;
   reg             skip;
   
   reg             i2c_doing_read;
   reg             i2c_started;
   reg [1:0]       i2c_bits_left;
   
   reg [3:0]       pcnext;
   reg [3:0]       delay;
   reg [2:0]       bitcount;
   
   reg [8:0]       i2c_data;
   
   assign opcode = (inst_data[8:7] == 2'b00) ? OPCODE_JUMP : 
                   (inst_data[8:4] == 5'b01000) ? OPCODE_SKIPCLEAR : 
                   (inst_data[8:4] == 5'b01001) ? OPCODE_SKIPSET : 
                   (inst_data[8:4] == 5'b01010) ? OPCODE_CLEAR : 
                   (inst_data[8:4] == 5'b01011) ? OPCODE_SET : 
                   (inst_data[8:5] == 4'b0110) ? OPCODE_I2C_READ : 
                   (inst_data[8:4] == 5'b01110) ? OPCODE_DELAY : 
                   (inst_data[8:0] == 9'b011110000) ? OPCODE_SKIPACK : 
                   (inst_data[8:0] == 9'b011110001) ? OPCODE_SKIPNACK : 
                   (inst_data[8:0] == 9'b011110010) ? OPCODE_WRITELOW : 
                   (inst_data[8:0] == 9'b011110011) ? OPCODE_WRITEHI : 
                   (inst_data[8:0] == 9'b011111110) ? OPCODE_NOP : 
                   (inst_data[8:0] == 9'b011111111) ? OPCODE_I2C_STOP : 
                   (inst_data[8:8] == 1'b1) ? OPCODE_I2C_WRITE : 
                   OPCODE_UNKNOWN;
   
   assign inst_address = pcnext;
   
   
   always @(posedge clk)
   begin: cpu
      
         case (state)
            STATE_I2C_START :
               begin
                  i2c_started <= 1'b1;
                  i2c_scl <= 1'b1;
                  
                  if (bitcount == ({1'b0, }))
                     i2c_sda <= 1'b0;
                  
                  if (bitcount == 0)
                  begin
                     state <= STATE_I2C_BITS;
                     i2c_scl <= 1'b0;
                     bitcount <= clk_divide;
                  end
                  else
                     bitcount <= bitcount - 1;
               end
            
            STATE_I2C_BITS :
               begin
                  if (bitcount == clk_divide - ({2'b00, }))
                  begin
                     if (i2c_data[8] == 1'b0)
                        i2c_sda <= 1'b0;
                     else
                        i2c_sda <= 1'bZ;
                  end
                  
                  if (bitcount == ({1'b0, }))
                     i2c_scl <= 1'b1;
                  
                  if (bitcount == ({2'b00, }))
                     i2c_data <= {i2c_data[7:0], i2c_sda};
                  
                  if (bitcount == 0)
                  begin
                     i2c_scl <= 1'b0;
                     if (i2c_bits_left == 3'b000)
                     begin
                        i2c_scl <= 1'b0;
                        if (i2c_doing_read == 1'b1)
                        begin
                           reg_data <= i2c_data[8:1];
                           reg_write <= 1'b1;
                        end
                        ack_flag <= (~i2c_data[0]);
                        state <= STATE_RUN;
                        pcnext <= pcnext + 1;
                     end
                     else
                        i2c_bits_left <= i2c_bits_left - 1;
                     bitcount <= clk_divide;
                  end
                  else
                     bitcount <= bitcount - 1;
               end
            
            STATE_I2C_STOP :
               begin
                  i2c_started <= 1'b0;
                  if (bitcount == clk_divide - ({2'b00, }))
                     i2c_sda <= 1'b0;
                  
                  if (bitcount == ({1'b0, }))
                     i2c_scl <= 1'b1;
                  
                  if (bitcount == ({2'b00, }))
                     i2c_sda <= 1'bZ;
                  if (bitcount == 0)
                  begin
                     state <= STATE_RUN;
                     pcnext <= pcnext + 1;
                  end
                  else
                     bitcount <= bitcount - 1;
               end
            
            STATE_DELAY :
               if (bitcount != 0)
                  bitcount <= bitcount - 1;
               else
                  if (delay == 0)
                  begin
                     pcnext <= pcnext + 1;
                     state <= STATE_RUN;
                  end
                  else
                  begin
                     delay <= delay - 1;
                     bitcount <= clk_divide - 1;
                  end
            
            STATE_RUN :
               begin
                  reg_data <= 8'bXXXXXXXX;
                  
                  if (skip == 1'b1)
                  begin
                     skip <= 1'b0;
                     pcnext <= pcnext + 1;
                  end
                  else
                     case (opcode)
                        OPCODE_JUMP :
                           begin
                              skip <= 1'b1;
                              pcnext <= {(inst_data[6:0]), 3'b000};
                           end
                        
                        OPCODE_I2C_WRITE :
                           begin
                              i2c_data <= {inst_data[7:0], 1'b1};
                              bitcount <= clk_divide;
                              i2c_doing_read <= 1'b0;
                              i2c_bits_left <= 4'b1000;
                              if (i2c_started == 1'b0)
                                 state <= STATE_I2C_START;
                              else
                                 state <= STATE_I2C_BITS;
                           end
                        
                        OPCODE_I2C_READ :
                           begin
                              reg_addr <= inst_data[4:0];
                              i2c_data <= {8'hFF, 1'b1};
                              bitcount <= clk_divide;
                              i2c_bits_left <= 4'b1000;
                              i2c_doing_read <= 1'b1;
                              if (i2c_started == 1'b0)
                                 state <= STATE_I2C_START;
                              else
                                 state <= STATE_I2C_BITS;
                           end
                        
                        OPCODE_SKIPCLEAR :
                           begin
                              skip <= inputs[((inst_data[3:0]))] ~^ inst_data[4];
                              pcnext <= pcnext + 1;
                           end
                        
                        OPCODE_SKIPSET :
                           begin
                              skip <= inputs[((inst_data[3:0]))] ~^ inst_data[4];
                              pcnext <= pcnext + 1;
                           end
                        
                        OPCODE_CLEAR :
                           begin
                              outputs[((inst_data[3:0]))] <= inst_data[4];
                              pcnext <= pcnext + 1;
                           end
                        
                        OPCODE_SET :
                           begin
                              outputs[((inst_data[3:0]))] <= inst_data[4];
                              pcnext <= pcnext + 1;
                           end
                        
                        OPCODE_SKIPACK :
                           begin
                              skip <= ack_flag;
                              pcnext <= pcnext + 1;
                           end
                        
                        OPCODE_SKIPNACK :
                           begin
                              skip <= (~ack_flag);
                              pcnext <= pcnext + 1;
                           end
                        
                        OPCODE_DELAY :
                           begin
                              state <= STATE_DELAY;
                              bitcount <= clk_divide;
                              case (inst_data[3:0])
                                 4'b0000 :
                                    delay <= 16'h0001;
                                 4'b0001 :
                                    delay <= 16'h0002;
                                 4'b0010 :
                                    delay <= 16'h0004;
                                 4'b0011 :
                                    delay <= 16'h0008;
                                 4'b0100 :
                                    delay <= 16'h0010;
                                 4'b0101 :
                                    delay <= 16'h0020;
                                 4'b0110 :
                                    delay <= 16'h0040;
                                 4'b0111 :
                                    delay <= 16'h0080;
                                 4'b1000 :
                                    delay <= 16'h0100;
                                 4'b1001 :
                                    delay <= 16'h0200;
                                 4'b1010 :
                                    delay <= 16'h0400;
                                 4'b1011 :
                                    delay <= 16'h0800;
                                 4'b1100 :
                                    delay <= 16'h1000;
                                 4'b1101 :
                                    delay <= 16'h2000;
                                 4'b1110 :
                                    delay <= 16'h4000;
                                 default :
                                    delay <= 16'h8000;
                              endcase
                           end
                        
                        OPCODE_I2C_STOP :
                           begin
                              bitcount <= clk_divide;
                              state <= STATE_I2C_STOP;
                           end
                        
                        OPCODE_NOP :
                           pcnext <= pcnext + 1;
                        default :
                           error <= 1'b1;
                     endcase
               end
            
            default :
               begin
                  state <= STATE_RUN;
                  pcnext <= {10{1'b0}};
                  skip <= 1'b1;
               end
         endcase
   end
   
endmodule
