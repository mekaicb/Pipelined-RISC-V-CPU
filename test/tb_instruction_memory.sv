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
		
		repeat(8) @(posedge clk) //repeat for 10 clock cycles (will read max 10 hex strings for this test)
			addr_in = addr_in + 1;
		$stop;
	end
	
endmodule