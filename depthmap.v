
//--------------------------------------------------------------------------------------------


module DepthMap(clk100, btnl, btnc, btnr, btnp, btnm, config_finished_l, config_finished_r, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, ov7670_pclk_l, ov7670_xclk_l, ov7670_vsync_l, ov7670_href_l, ov7670_data_l, ov7670_sioc_l, ov7670_siod_l, ov7670_pwdn_l, ov7670_reset_l, ov7670_pclk_r, ov7670_xclk_r, ov7670_vsync_r, ov7670_href_r, ov7670_data_r, ov7670_sioc_r, ov7670_siod_r, ov7670_pwdn_r, ov7670_reset_r, TxD);
   input        clk100;
   input        btnl;
   input        btnc;
   input        btnr;
   input        btnp;
   input        btnm;
   output       config_finished_l;
   output       config_finished_r;
   
   output       vga_hsync;
   output       vga_vsync;
   output [3:0] vga_r;
   output [3:0] vga_g;
   output [3:0] vga_b;
   
   input        ov7670_pclk_l;
   output       ov7670_xclk_l;
   input        ov7670_vsync_l;
   input        ov7670_href_l;
   input [7:0]  ov7670_data_l;
   output       ov7670_sioc_l;
   inout        ov7670_siod_l;
   output       ov7670_pwdn_l;
   output       ov7670_reset_l;
   
   input        ov7670_pclk_r;
   output       ov7670_xclk_r;
   input        ov7670_vsync_r;
   input        ov7670_href_r;
   input [7:0]  ov7670_data_r;
   output       ov7670_sioc_r;
   inout        ov7670_siod_r;
   output       ov7670_pwdn_r;
   output       ov7670_reset_r;
   
   output       TxD;
   
   
   wire         CLK_MAIN;
   wire         clk_camera;
   wire         clk_vga;
   wire [0:0]   wren_l;
   wire [0:0]   wren_r;
   wire [0:0]   avg_reg_en;
   wire         resend;
   wire         nBlank;
   wire         vSync;
   wire         nSync;
   
   wire [16:0]  wraddress_l;
   wire [11:0]  wrdata_l;
   wire [16:0]  wraddress_r;
   wire [11:0]  wrdata_r;
   
   wire [16:0]  rdaddress_l;
   wire [3:0]   rddata_l;
   wire [16:0]  rdaddress_r;
   wire [3:0]   rddata_r;
   wire [3:0]   avg_out;
   wire [3:0]   din_avg;
   wire         avg_en;
   
   wire [15:0]  exposure;
   wire         plus_deb;
   wire         plus_col_deb;
   wire         minus_deb;
   wire         minus_col_deb;
   
   wire [7:0]   disparity_out;
   wire [16:0]  rdaddress_disp;
   wire [7:0]   rddisp;
   wire [16:0]  wr_address_disp;
   wire [0:0]   wr_en;
   wire [16:0]  left_right_addr;
   wire [16:0]  address_left;
   wire [16:0]  address_right;
   wire [7:0]   red;
   wire [7:0]   green;
   wire [7:0]   blue;
   wire         activeArea;
   
   wire         rez_160x120;
   wire         rez_320x240;
   wire [1:0]   size_select;
   wire [16:0]  rd_addr_l;
   wire [16:0]  wr_addr_l;
   wire [16:0]  rd_addr_r;
   wire [16:0]  wr_addr_r;
   assign vga_r = red[7:4];
   assign vga_g = green[7:4];
   assign vga_b = blue[7:4];
   
   assign rez_160x120 = 1'b0;
   assign rez_320x240 = 1'b1;
   
   
   Clocks Inst_ClockDev(.clk_in1(clk100), 
						.clk_main(CLK_MAIN), 
						.clk50mhz(clk_camera), 
						.clk25mhz(clk_vga));
   
   assign vga_vsync = vSync;
   
   
   VGA Inst_VGA(.clk25(clk_vga), 
				.rez_160x120(rez_160x120), 
				.rez_320x240(rez_320x240), 
				.clkout(), 
				.hsync(vga_hsync), 
				.vsync(vSync), 
				.nblank(nBlank), 
				.nsync(nSync), 
				.activearea(activeArea), 
				.avg_en(avg_en));
   
   
   debounce Inst_debounce(.clk(CLK_MAIN), 
						.i(btnc), 
						.o(resend));
   
   
   ov7670_controller_left Inst_ov7670_controller_left(.clk(clk_camera), 
													.resend(resend),
													.config_finished(config_finished_l),
													.sioc(ov7670_sioc_l), 
													.siod(ov7670_siod_l),
													.reset(ov7670_reset_l), 
													.pwdn(ov7670_pwdn_l),
													.xclk(ov7670_xclk_l));
   
   
   ov7670_controller_right Inst_ov7670_controller_right(.clk(clk_camera), 
														.resend(resend), 
														.exposure(exposure), 
														.config_finished(config_finished_r), 
														.sioc(ov7670_sioc_r), 
														.siod(ov7670_siod_r),
														.reset(ov7670_reset_r),
														.pwdn(ov7670_pwdn_r), 
														.xclk(ov7670_xclk_r));
   
   assign rd_addr_l = rdaddress_l[16:0];
   assign rd_addr_r = rdaddress_r[16:0];
   assign wr_addr_r = wraddress_r[16:0];
   assign wr_addr_l = wraddress_l[16:0];
   
   
   frame_buffer Inst_frame_buffer_l(.addrb(address_left), 
									.clkb(clk_camera), 
									.doutb(rddata_l), 
									.enb(1'b1), 
									.clka(ov7670_pclk_l), 
									.addra(wr_addr_l), 
									.dina(wrdata_l[7:4]), 
									.wea(wren_l));
   
   
   frame_buffer Inst_frame_buffer_r(.addrb(address_right), 
									.clkb(clk_camera), 
									.doutb(rddata_r),
									.enb(1'b1), 
									.clka(ov7670_pclk_r),
									.addra(wr_addr_r), 
									.dina(wrdata_r[7:4]), 
									.wea(wren_r));
   
   
   frame_buffer Inst_frame_buffer_avg(.addrb(rdaddress_disp), 
									.clkb(clk_vga), 
									.doutb(din_avg), 
									.enb(1'b1), 
									.clka(CLK_MAIN), 
									.addra(left_right_addr),
									.dina(avg_out), 
									.wea(avg_reg_en));
   
   
   disparity_ram Inst_disparity_buffer(.addrb(rdaddress_disp), 
									.clkb(clk_vga), 
									.doutb(rddisp), 
									.clka(CLK_MAIN), 
									.addra(wr_address_disp), 
									.dina(disparity_out), 
									.wea(wr_en));
   
   
   Transmitter Inst_Transmitter(.clk(CLK_MAIN), 
								.reset(1'b0), 
								.transmit(1'b1), 
								.data(8'b10101011),
								.txd(TxD));
   
   
   ov7670_capture Inst_ov7670_capture_l(.pclk(ov7670_pclk_l), 
										.rez_160x120(rez_160x120), 
										.rez_320x240(rez_320x240), 
										.vsync(ov7670_vsync_l), 
										.href(ov7670_href_l), 
										.d(ov7670_data_l), 
										.addr(wraddress_l),
										.dout(wrdata_l),
										.we(wren_l[0]));
   
   
   ov7670_capture Inst_ov7670_capture_r(.pclk(ov7670_pclk_r), 
										.rez_160x120(rez_160x120), 
										.rez_320x240(rez_320x240), 
										.vsync(ov7670_vsync_r), 
										.href(ov7670_href_r), 
										.d(ov7670_data_r), 
										.addr(wraddress_r), 
										.dout(wrdata_r), 
										.we(wren_r[0]));
   
   
   RGB Inst_RGB(.din(rddisp), 
				.din_avg(din_avg), 
				.nblank(activeArea), 
				.r(red), .g(green), 
				.b(blue), 
				.avg_en(avg_en));
   
   
   Address_Generator Inst_Address_Generator(.clk(clk_vga), 
											.rez_160x120(rez_160x120), 
											.rez_320x240(rez_320x240), 
											.enable(activeArea), 
											.vsync(vSync), 
											.avg_en(avg_en),
											.address(rdaddress_disp));
   
   
   Image_Rectification Inst_rectification(.address_in(left_right_addr), 
										.plus(btnr), 
										.minus(btnl),
										.plus_col(btnp),
										.minus_col(btnm), 
										.clk(clk_camera), 
										.exposure(exposure), 
										.address_left(address_left), 
										.address_right(address_right));
   
   
   disparity_generator Inst_disparity_generator(.hclk(clk_camera),
												.clk_main(CLK_MAIN), 
												.left_in(rddata_l), 
												.right_in(rddata_r), 
												.avg_out(avg_out), 
												.dout(disparity_out), 
												.dout_addr(wr_address_disp), 
												.wr_en(wr_en), 
												.avg_reg_en(avg_reg_en), 
												.left_right_addr(left_right_addr));
   
endmodule
