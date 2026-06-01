module VGA(
	input logic clk, rst_n, we, // assume clk is 25.175 created by PLL
	input logic [31:0] data_i,
	input logic [13:0] addr_i,
	output logic [31:0] data_o,
	output logic hsync, vsync
	);
	
	logic [13:0] addr_r;
	logic [9:0] x, y;
	logic video_on;
	
	frame_buffer frame_buffer(.clk(clk), .rst_n(rst_n), .we(we), .addr_w(addr_i), .data_i(data_i), .addr_r(addr_r),.data_o(data_o));
	VGA_controller VGA_controller(.clk(clk), .rst_n(rst_n), .x(x), .y(y), .h_sync(hsync), .v_sync(vsync), .video_on(video_on));
	read_pipe read_pipe(.x(x), .y(y), .r_addr(addr_r));
	
	
endmodule