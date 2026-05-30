module frame_buffer(
	input logic clk, we,
	input logic [13:0] addr_w, addr_r,
	input logic [31:0] data_i,
	output logic [31:0] data_o
	);
	
	logic [31:0] vram[0:9599];
	
	always_ff @(posedge clk) begin // synchronous read & write
		vram[addr_w[13:0]] <= we ? data_i : vram[addr_w[13:0]];
		data_o <= vram[addr_r[13:0]]; 
	end
endmodule