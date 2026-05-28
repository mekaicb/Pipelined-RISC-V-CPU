module tb_instruction_memory();
	logic clk;
	logic [31:0] addr_in;
	logic [31:0] data_out;
	
	initial begin
		clk = 0;
	end 
	
	always #5ns clk = ~clk; // period of 5ns
	
	instruction_memory dut(addr_in, clk, data_out);
	
	initial begin
		addr_in = 32'h00000000;
		
		repeat(100) @(posedge clk)
			addr_in = addr_in + 4;
		$stop;
	end
	
endmodule