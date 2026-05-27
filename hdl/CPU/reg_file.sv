module reg_file(
	input logic [4:0] rs2_addr, rs1_addr, rd_addr,
	input logic [31:0] rd_data,
	input logic regwrite_sel, clk, rst_n,
	output logic [31:0] rs2_data, rs1_data
	);
	
	logic [31:0] reg_in [0:31]; // array of 32 bit address input wires
	logic [31:0] reg_out [0:31]; // array of 32 bit data output wires
	logic [31:0] en;
	
	// decode logic
	always_comb begin
		en = 32'h0; //initialize enable as a 32 bit bus, one bit into each register 
		if(regwrite_sel)
			en[rd_addr] = 1'b1; //only care about enable for writes
	end
	
	
	// generate array of registers
	genvar i;
	generate
		for(i=0; i<32; i=i+1) begin : reg_array
			reg_32bits register(reg_in[i], ~clk, rst_n, en[i], reg_out[i]); //reg_in[i] = 32 bit input into register
		end
	endgenerate
	
	// read/write logic
	always_comb begin
	
		for(int i = 0; i<32; i=i+1) begin // fix inferred latches warning
			reg_in[i] = 32'h0; // default all (enabled) register inputs to 0
		end
		
		if(regwrite_sel)
			reg_in[rd_addr] = rd_data; //write rd_data into its register
			
		rs1_data = reg_out[rs1_addr]; //read output from register
		rs2_data = reg_out[rs2_addr];
	end
	
endmodule


	
	