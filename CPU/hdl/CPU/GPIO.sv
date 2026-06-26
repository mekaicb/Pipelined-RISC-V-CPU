module GPIO(
	input logic clk,
	input logic p1_left, p1_right,
	input logic p2_left, p2_right,
	input logic [31:0] addr_i,
	output logic [31:0] user_input
	);
	
	logic [31:0] eff_addr;
	localparam offset = 32'h17C00;
	
	(* ramstyle = "M9K" *) logic [31:0] mem_array[0:3];
	
	assign eff_addr = (addr_i - offset) >> 2;
	
	always_ff @(posedge clk) begin
			mem_array[0] <= p1_left; // Store input every cycle, not gated by a write signal. Since not gated, 
			mem_array[1] <= p1_right;
			mem_array[2] <= p2_left;
			mem_array[3] <= p2_right;

			user_input <= mem_array[eff_addr]; // Output the data of the requested user input
	end
	
endmodule