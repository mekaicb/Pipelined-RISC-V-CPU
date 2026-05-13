module reg_32bits(
	input logic [31:0] in,
	input logic clk, rst_n, en,
	output logic [31:0] out
	);

	genvar i;
	
	generate
		for(i=0; i<32; i=i+1) begin : dff_array
			dflipflop inst(in[i], clk, rst_n, en, out[i]);
		end
	endgenerate
	
endmodule