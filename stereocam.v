
//--------------------------------------------------------------------------------------------


module StereoCam(clk100, btnl, btnc, btnr, config_finished_l, config_finished_r, vga_hsync, vga_vsync, vga_r, vga_g, vga_b, ov7670_pclk_l, ov7670_xclk_l, ov7670_vsync_l, ov7670_href_l, ov7670_data_l, ov7670_sioc_l, ov7670_siod_l, ov7670_pwdn_l, ov7670_reset_l, ov7670_pclk_r, ov7670_xclk_r, ov7670_vsync_r, ov7670_href_r, ov7670_data_r, ov7670_sioc_r, ov7670_siod_r, ov7670_pwdn_r, ov7670_reset_r);
   input        clk100;
   input        btnl;
   input        btnc;
   input        btnr;
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
   
   
   wire         clk_camera;
   wire         clk_vga;
   wire [0:0]   wren_l;
   wire [0:0]   wren_r;
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
   
   clocking your_instance_name(.CLK_100(clk100), 
								.CLK_50(clk_camera), 
								.CLK_25(clk_vga));
   
   assign vga_vsync = vSync;
   
   
   VGA Inst_VGA(.clk25(clk_vga), 
				.rez_160x120(rez_160x120), 
				.rez_320x240(rez_320x240), 
				.clkout(), 
				.hsync(vga_hsync), 
				.vsync(vSync), 
				.nblank(nBlank),
				.nsync(nSync), 
				.activearea(activeArea));
   
   
   debounce Inst_debounce(.clk(clk_vga),
						.i(btnc), 
						.o(resend));
   
   
   ov7670_controller Inst_ov7670_controller_left(.clk(clk_camera), 
												.resend(resend), 
												.config_finished(config_finished_l), 
												.sioc(ov7670_sioc_l), 
												.siod(ov7670_siod_l), 
												.reset(ov7670_reset_l),
												.pwdn(ov7670_pwdn_l), 
												.xclk(ov7670_xclk_l));
   
   
   ov7670_controller Inst_ov7670_controller_right(.clk(clk_camera), 
												.resend(resend), 
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
   
   
   frame_buffer Inst_frame_buffer_l(.addrb(rd_addr_l), 
									.clkb(clk_vga), 
									.doutb(rddata_l),
									.enb(1'b1), 
									.clka(ov7670_pclk_l),
									.addra(wr_addr_l), 
									.dina(wrdata_l[7:4]),
									.wea(wren_l));
   
   
   frame_buffer Inst_frame_buffer_r(.addrb(rd_addr_r), 
									.clkb(clk_vga), 
									.doutb(rddata_r), 
									.enb(1'b1), 
									.clka(ov7670_pclk_r),
									.addra(wr_addr_r), 
									.dina(wrdata_r[7:4]), 
									.wea(wren_r));
   
   
   ov7670_capture Inst_ov7670_capture_l(.pclk(ov7670_pclk_l), 
										.vsync(ov7670_vsync_l), 
										.href(ov7670_href_l), 
										.d(ov7670_data_l), 
										.addr(wraddress_l), 
										.dout(wrdata_l), 
										.we(wren_l[0]));
   
   
   ov7670_capture Inst_ov7670_capture_r(.pclk(ov7670_pclk_r), 
										.vsync(ov7670_vsync_r),
										.href(ov7670_href_r), 
										.d(ov7670_data_r), 
										.addr(wraddress_r), 
										.dout(wrdata_r),
										.we(wren_r[0]));
   
   
   RGB Inst_RGB(.Din_l(rddata_l), 
				.Din_r(rddata_r), 
				.Nblank(activeArea), 
				.R(red), 
				.G(green), 
				.B(blue));
   
   
   Address_Generator Inst_Address_Generator_l(.clk25(clk_vga), 
											.enable(activeArea), 
											.vsync(vSync),
											.address(rdaddress_l));
   
   Address_Generator Inst_Address_Generator_r(.clk25(clk_vga), 
											.enable(activeArea), 
											.vsync(vSync),
											.address(rdaddress_r));
   
endmodule
