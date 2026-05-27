module program_counter(
	input logic [31:0] addr_in,
	input logic clk, rst_n, pcwrite, ebreak,
	output logic [31:0] addr_out
	);
	
	always_ff @(posedge clk) begin
		if(!rst_n) begin
			addr_out <= 32'b0;
		end
		else if(ebreak) begin
			addr_out <= addr_out;
		end
		else if(!pcwrite) begin
			addr_out <= addr_in;
		end
		
		// else hold prev value
		
	end
	
endmodule
