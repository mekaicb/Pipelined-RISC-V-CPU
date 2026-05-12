module instruction_memory(
	input logic [31:0] addr_in,
	input logic	clk,
	output logic [31:0] data_out
	);
	
	logic [31:0] mem_array[0:69119]; //69120 words in a single column
	
	// Note: Wont compile since quartus will try to load 32x69120 dff's. Will run in Modelsim though

	initial $readmemh("../test/hex_file.txt", mem_array); //read data from hex_file.txt and write to mem_array
		
	always_ff @(posedge clk) begin
		data_out <= mem_array[addr_in[16:0]]; // 17 address bits to select one word (log(69120) = 16.02 -> 17)
	end
	
endmodule

