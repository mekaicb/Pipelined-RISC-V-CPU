module tb_IFID();
	logic clk, rst_n;
	logic [31:0] pc_in;
	logic [31:0] pc_out, pc_IFID_out;
	logic [31:0] inst_data, inst_data_IFID;
	logic [4:0] rs2_addr, rs1_addr, rd_addr;
	logic [31:0] rd_data;
	logic [31:0] rs2_data, rs1_data;
	logic [31:0] imm_o;
	logic [6:0] opcode;
	logic ALUsrc, pc_to_alu;
	logic [1:0] ALUop;
	logic branch, memread, memwrite;
	logic regwrite, memtoreg, jal;
	
	program_counter dut_pc(.addr_in(pc_in), .clk(clk), .rst_n(rst_n), .addr_out(pc_out)); // dont need to put instantiation into "initial begin/end" block
	adder dut_adder(.in1(pc_out), .in2(32'h00000004), .out(pc_in));
	instruction_memory dut_imem(.addr_in(pc_out), .clk(clk), .data_out(inst_data));
	IFID_buffer dut_buffer(.pc_addr_i(pc_out), .inst_data_i(inst_data), .clk(clk), .rst_n(rst_n), .pc_addr_o(pc_IFID_out), .inst_data_o(inst_data_IFID));
	reg_file dut_regfile(.rs2_addr(rs2_addr), .rs1_addr(rs1_addr), .rd_addr(rd_addr), .rd_data(rd_data), .regwrite_sel(regwrite), .clk(clk), .rst_n(rst_n), .rs2_data(rs2_data), .rs1_data(rs1_data));
	imm_gen dut_immgen(.instr_i(inst_data_IFID), .imm_o(imm_o));
	control_unit dut_control(.opcode(opcode), .ALUsrc(ALUsrc), .pc_to_alu(pc_to_alu), .ALUop(ALUop), .branch(branch), .memread(memread), .memwrite(memwrite), .regwrite(regwrite), .memtoreg(memtoreg), .jal(jal));
	
	initial begin
		clk <= 1;
		rst_n <= 0;
		rd_data <= 32'h0;  // driving rd_data with default zeroes 
		#10ns
		rst_n <= 1;
	end
	
	
	always #5ns clk = ~clk;	
	
	always_comb begin
		rs2_addr = inst_data_IFID[24:20]; 
		rs1_addr = inst_data_IFID[19:15];
		rd_addr = inst_data_IFID[11:7];
		opcode = inst_data_IFID[6:0];
	end
	
	initial begin
		#50ns
		rst_n <= 0;
		#10ns
		rst_n <= 1;
	end
	
	always @(posedge clk) begin
		$display("t=%0t | PC=%h | inst=%h | opcode=%b | regwrite=%b | reset=%b",
					$time, pc_out, inst_data_IFID, opcode, regwrite, rst_n);
	end
	
	initial begin
		#240ns
		$stop;
	end
	
endmodule

/*
This module should simulate the execution of the IF/ID stages.
- Inputs: 0x00000000 into pc
- Outputs: Name of instruction type

- Goals:
- PC is fed into adder and incremented by 4 each clock cycle
- Instruction memory outputs one instruction each clock cycle
- IFID buffer will receive instruction correctly and handle reset
- Control can properly identify instruction type
- Imm_gen will generate the correct imm_o and display in decimal

Note: All data wires will return undefined since all registers are empty. No way to write data until WB is complete.
Note: No need to initialize pc to 0 due to reset enabled on start

*/