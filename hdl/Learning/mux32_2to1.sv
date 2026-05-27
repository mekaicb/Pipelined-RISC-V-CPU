module mux32_2to1(
	input logic [31:0] in1, in2,
	input logic sel,
	output logic [31:0] out
	);
	
	always_comb begin
		out = sel ? in1 : in2;
	end
	
endmodule