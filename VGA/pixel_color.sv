module pixel_color(
	input  logic clk,
	input  logic [3:0] pixel_sel,   // which pixel in the word = x[3:0]
	input  logic video_on,
	input  logic [31:0] data_o,     // word out of the frame buffer
	output logic [2:0] rgb          // The actual signal sent to the VGA
	);

	logic	[3:0] pixel_sel_r; // delayed one cycle to match the registered read
	logic	video_on_r;
	logic [1:0] pixel; // 2 bits/pixel

	always_ff @(posedge clk) begin // due to delay in updating data_o in frame_buffer
		pixel_sel_r <= pixel_sel;
		video_on_r  <= video_on;
	end

	always_comb begin
		case(pixel_sel_r) // Selecting one pixel from the 32 bit word output from the frame buffer
			4'b0000 : pixel = data_o[1:0];
			4'b0001 : pixel = data_o[3:2];
			4'b0010 : pixel = data_o[5:4];
			4'b0011 : pixel = data_o[7:6];
			4'b0100 : pixel = data_o[9:8];
			4'b0101 : pixel = data_o[11:10];
			4'b0110 : pixel = data_o[13:12];
			4'b0111 : pixel = data_o[15:14];
			4'b1000 : pixel = data_o[17:16];
			4'b1001 : pixel = data_o[19:18];
			4'b1010 : pixel = data_o[21:20];
			4'b1011 : pixel = data_o[23:22];
			4'b1100 : pixel = data_o[25:24];
			4'b1101 : pixel = data_o[27:26];
			4'b1110 : pixel = data_o[29:28];
			4'b1111 : pixel = data_o[31:30];
		endcase
	end

	always_comb begin
		if(!video_on_r) 
			rgb = 3'b000;
		else 
			case(pixel)
				2'b00 : rgb = 3'b000; // black
				2'b01 : rgb = 3'b001; // red
				2'b10 : rgb = 3'b010; // green
				2'b11 : rgb = 3'b100; // blue
			endcase
	end
		
endmodule