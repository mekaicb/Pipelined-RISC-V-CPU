module program_counter(
	input logic [31:0] addr_in,
	input logic clk, rst_n,
	output logic [31:0] addr_out
	);

	reg_32bits pc(addr_in, clk, rst_n, addr_out); //dff module will take care of the updating each clock cycle

endmodule
