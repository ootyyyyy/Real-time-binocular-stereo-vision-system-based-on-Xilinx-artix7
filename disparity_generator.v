
/******************************************************************************/
/******************  Module for processing image     **************/
/******************************************************************************/
//`include "parameter.v" 						// Include definition file
module disparity_generator
#(
  parameter WIDTH 	= 320, 					
			HEIGHT 	= 240, 						

			START_UP_DELAY = 100, 				
			HSYNC_DELAY = 160,					
			VALUE= 100								

)
(
	input HCLK,										
	input [3:0] left_in,
	input [3:0] right_in,	
	output [3:0]  dOUT,				
    output [16:0]  dOUT_addr,				
    output [16:0]	left_right_addr,

    output	reg		  ctrl_done,
    output reg offsetfound					
    		
	
);			

reg 		ctrl_data_run;					


reg [0 : (WIDTH*HEIGHT - 1)*4] org_L; 	
reg [0 : (WIDTH*HEIGHT - 1)*4] org_R ;
reg [8:0] row;
reg [8:0] col; 
parameter window = 5;
integer x,y; 
reg [3:0] offset, best_offset;
localparam [4:0] maxoffset = 10;
reg offsetfound;
reg offsetping;
reg compare;
reg [20:0] ssd;
reg [20:0] prev_ssd;
reg [16:0] data_count; 
reg [16:0] readreg;
reg doneFetch;

assign dOUT_addr= data_count;
assign left_right_addr=readreg;
assign dOUT=best_offset;

always@(posedge HCLK) begin
    if (~doneFetch) begin
        if (readreg<76800) begin
           org_L[readreg*4+:4]<= left_in;
           org_R[readreg*4+:4]<= right_in;
           readreg=readreg+1;
        end
        else begin
            readreg <= 0;
            doneFetch <=1;
        end
    end
    

    if(ctrl_done) begin
        data_count <= 0;
    end
    else begin
        if(ctrl_data_run)
			data_count <= data_count + 1;
    end
    
    ctrl_done <= (data_count == 308487)? 1'b1: 1'b0; 
    if (ctrl_done) doneFetch=0;
    

    
    if (offsetfound) begin
        offset <= 4'd4;
    end

    if (offsetping) begin
        for(x=-(window-1)/2; x<((window-1)/2)+1; x=x+1) begin
			for(y=-(window-1)/2; y<((window-1)/2)+1; y=y+1) begin
				ssd=ssd+(org_L[((row + x ) * WIDTH + col + y)*4  +:4   ]-org_R[((row + x ) * WIDTH + col + y -offset)*4 +:4 ])*(org_L[((row +  x ) * WIDTH + col + y )*4 +:4   ]-org_R[((row +  x ) * WIDTH + col + y - offset)*4 +:4 ]);

			end
	   end
	
	   compare<=1;
    end
    

    if (compare) begin
        if (ssd < prev_ssd ) begin
            prev_ssd<=ssd;
            best_offset<=offset;
            
        end
	

	
	
	   offsetping<=0;
	   compare<=0;
    end

    if (doneFetch) begin
        if(ctrl_done) begin
            row <= 0;
              col<= 0;
              offset<=4'd4;
              offsetping<=0;
              compare<=0;
              ctrl_done <= 0;
              
        end
        else begin
            
            if(ctrl_data_run & offsetping==0 & compare==0) begin
                if (offsetfound) begin
                    if(col == WIDTH - 1) begin
                        row <= row + 1;
                        
                    end
                    if(col == WIDTH - 1) begin
                        col <= 0;		
                    end
                    else begin 
                        col <= col + 1; 
                    end
                    offsetfound <= 0;
                    best_offset <= 0;
                    prev_ssd <= 21'd65535;

                end
                else begin
                    if(offset==maxoffset) begin
                        offsetfound <= 1;
                    end
                    else begin
                            offset<=offset+1;
                        
                    end
                    ssd<=0;
 
                    offsetping<=1;
            end
                
            
        end
end
end
 
    
end

endmodule

