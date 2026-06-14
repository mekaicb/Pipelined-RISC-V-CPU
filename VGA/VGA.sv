module VGA(
	input logic clock, rst_n, we, // 100MHz clock from FPGA
	input logic [31:0] data_i,
	input logic [13:0] addr_i,
	output logic [2:0] rgb,
	output logic hsync, vsync
	);
	
	logic [14:0] addr_r;
	logic [9:0] x, y;
	logic [3:0] pixel_sel;
	logic [31:0] data_o;
	logic video_on;
	logic clk;
	
	assign pixel_sel = x[3:0]; // The upper bits of x are used to select the word, the bits shifted out are the "remainder" and are used to select the pixel in the word
	
	PLL PLL(.inclk0(clock), .c0(clk));
	frame_buffer frame_buffer(.clk(clk), .we(we), .addr_w(addr_i), .data_i(data_i), .addr_r(addr_r),.data_o(data_o));
	VGA_controller VGA_controller(.clk(clk), .rst_n(rst_n), .x(x), .y(y), .h_sync(hsync), .v_sync(vsync), .video_on(video_on));
	pixel_color pixel_color(.clk(clk), .pixel_sel(pixel_sel), .video_on(video_on), .data_o(data_o), .rgb(rgb));
	read_pipe read_pipe(.x(x), .y(y), .r_addr(addr_r));
	
	
endmodule