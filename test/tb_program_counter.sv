module tb_program_counter(); //no ports since highest level entity

	logic [31:0] addr_in; //input
	logic	clk, rst;	 //input
	logic [31:0] addr_out; //output
	
	program_counter dut(addr_in, clk, rst, addr_out);
	
	initial begin
		clk = 1; //initialize clock to 1
		rst = 1;
		
	end
	
	always #5ns clk = ~clk; //let clock has a period of 10ns
	
	initial begin
		addr_in = 32'h00000000;
		
		repeat(3) @(posedge clk) //repeat for five clock cycles
			addr_in <= addr_in + 4;
			
		rst <= 0;
		#10ns
		rst <= 1;
		
		repeat(3) @(posedge clk)
			addr_in <= addr_in + 4;
		$stop; //stop the simulation
	end
endmodule

/*
Note that although the output will jump back to the pre-reset input, on an actual CPU the PC output is wired into the +4 adder.
This will force the next input to be 0+4 after a reset. The values here are just hardcoded but don't reflect CPU behaviour.
*/