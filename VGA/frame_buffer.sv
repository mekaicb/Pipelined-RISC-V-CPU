module frame_buffer(
	input logic clk, we,
	input logic [13:0] addr_w, addr_r,
	input logic [31:0] data_i,
	output logic [31:0] data_o
	);
	
	logic [31:0] vram[0:9599]; 
	
	always_ff @(posedge clk) begin 
		if(we)
			vram[addr_w] <= data_i;// Synchronous write
	end
	
	always_comb begin
		data_o = vram[addr_r[13:0]]; // Asynchronous read
	end
	
	
endmodule