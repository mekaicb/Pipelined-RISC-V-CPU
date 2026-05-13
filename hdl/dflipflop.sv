module dflipflop(
	input logic D, clk, rst_n, en,
	output logic Q
	);
	
	always_ff @(negedge rst_n, posedge clk) begin
		if(!rst_n)
			Q <= 0;
		else if (en)
			Q <= D; // output = input from prev clock cycle (if enabled)
	end
endmodule

// Note: always_ff will hold the value by default if no conditions are met rather than creating an unintended latch