
//--------------------------------------------------------------------------------------------


module clocking(CLK_100, CLK_50, CLK_25);
   input       CLK_100;
   
   output      CLK_50;
   output      CLK_25;
   
   
   wire        clkin1;
   
   wire        clkfbout;
   wire        clkfbout_buf;
   wire        clkfboutb_unused;
   wire        clkout0;
   wire        clkout0b_unused;
   wire        clkout1;
   wire        clkout1b_unused;
   wire        clkout2_unused;
   wire        clkout2b_unused;
   wire        clkout3_unused;
   wire        clkout3b_unused;
   wire        clkout4_unused;
   wire        clkout5_unused;
   wire        clkout6_unused;
   
   wire [15:0] do_unused;
   wire        drdy_unused;
   
   wire        psdone_unused;
   
   wire        locked_unused;
   wire        clkfbstopped_unused;
   wire        clkinstopped_unused;
   
   
   IBUFG clkin1_buf(.o(clkin1), .i(CLK_100));
   
   
   
   
   
   
   
   
   MMCME2_ADV #("OPTIMIZED", 1'b0, "ZHOLD", 1'b0, 1, 10.000, 0.000, 1'b0, 20.000, 0.000, 0.500, 1'b0, 40, 0.000, 0.500, 1'b0, 10.000, 0.010)
   mmcm_adv_inst(.clkfbout(clkfbout), 
				.clkfboutb(clkfboutb_unused), 
				.clkout0(clkout0), 
				.clkout0b(clkout0b_unused), 
				.clkout1(clkout1), 
				.clkout1b(clkout1b_unused), 
				.clkout2(clkout2_unused), 
				.clkout2b(clkout2b_unused), 
				.clkout3(clkout3_unused), 
				.clkout3b(clkout3b_unused), 
				.clkout4(clkout4_unused), 
				.clkout5(clkout5_unused), 
				.clkout6(clkout6_unused), 
				.clkfbin(clkfbout_buf), 
				.clkin1(clkin1), 
				.clkin2(1'b0), 
				.clkinsel(1'b1), 
				.daddr(1'b0), 
				.dclk(1'b0), 
				.den(1'b0), 
				.di(1'b0), 
				.do(do_unused), 
				.drdy(drdy_unused), 
				.dwe(1'b0), 
				.psclk(1'b0), 
				.psen(1'b0), 
				.psincdec(1'b0), 
				.psdone(psdone_unused), 
				.locked(locked_unused), 
				.clkinstopped(clkinstopped_unused),
				.clkfbstopped(clkfbstopped_unused), 
				.pwrdwn(1'b0),
				.rst(1'b0));
   
   
   BUFG clkf_buf(.o(clkfbout_buf), .i(clkfbout));
   
   
   BUFG clkout1_buf(.o(CLK_50), .i(clkout0));
   
   
   BUFG clkout2_buf(.o(CLK_25), .i(clkout1));
   
endmodule
