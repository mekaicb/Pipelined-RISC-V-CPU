module mux1_2to1(
	input logic in1, in2, sel,
	output logic out
	);
	
	always_comb begin
		out = sel ? in1 : in2;
	end
	
endmodule