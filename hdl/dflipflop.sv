module dflipflop(
	input logic D, clk, rst_n,
	output logic Q
	);
	
	always_ff @(negedge rst_n, posedge clk) begin
		if(!rst_n)
			Q <= 0;
		else
			Q <= D; // output = input from prev clock cycle
	end
endmodule