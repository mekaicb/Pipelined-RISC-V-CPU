module IFID_buffer(
	input	logic [31:0] pc_addr_i, inst_data_i,
	input logic clk, rst_n, IFID_flush, IFID_write, ebreak_flush,
	output logic [31:0] pc_addr_o, inst_data_o
	);
	
	always_ff @(posedge clk) begin
		if(!rst_n || IFID_flush || ebreak_flush) begin // if reset enabled, flush buffers
			pc_addr_o <= 0;
			inst_data_o <= 0;
		end
		else if (!IFID_write) begin // else send input data through to output on the next clock cycle IF not stalling
			pc_addr_o <= pc_addr_i;
			inst_data_o <= inst_data_i;
		end
		// always_ff assumes else = hold value
	end
endmodule

// Note: if/else in sequential blocks require begin/end statements
// if(IFID) -> Stall buffer