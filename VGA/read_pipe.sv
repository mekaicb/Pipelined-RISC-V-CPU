module read_pipe(
	input logic [9:0] x, y,
	output logic [13:0] r_addr
	);
	
	assign r_addr = {y[9:0], 4'b0} + {2'b0, y[9:0], 2'b0} + {5'b0, x[9:5]}; // 2D address to 1D address
	
endmodule