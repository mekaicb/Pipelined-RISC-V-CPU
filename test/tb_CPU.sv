`timescale 1ns/1ps

module tb_CPU();
	logic clk, rst_n;
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic funct7;
	logic hazard;
	
	int c_count;
	
	string inst_type;
	string hazard_detected;
	
	
	CPU dut(.clk(clk), .rst_n(rst_n));

	initial begin
		clk <= 1;
		rst_n <= 0;
		c_count = 0;
		$timeformat(-9, 0, " ns");
	end
	
	always #5ns clk = ~clk; // 100MHz clk
	
	
	
	// Automatically create a file and load the instruction
	task automatic test_instruction(
		input logic [31:0] instr1, instr2
	);
		dut.ROM.mem_array[0] = instr1;
		dut.ROM.mem_array[1] = instr2;
		
		rst_n = 0; 	 // Clear all pipeline registers from previous test
		#11			 // prevent weird timing bugs if held for less than/exactly one clock cycle
		rst_n = 1;
		
	endtask
	
	// Testing all 40 RV32I instructions. Using online assembler to convert RISCV to machine code
	initial begin
		
		// ADDI
		test_instruction(32'h00720193, 32'h0);
		#50;
		if(dut.reg_file.reg_out[3] == 32'h00000007)
			$display("ADDI PASSED\n");
		else
			$display("ADDI FAILED\n");
	end
	
	
	// Block to determine instructions
	always_comb begin
		
		opcode = dut.opcode; // hierarchical references
		funct3 = dut.funct3;
		funct7 = dut.funct7;
		
		case(opcode)
		
			7'b0110011 : begin // R-type
				case({funct7, funct3})
					4'b0000 : inst_type = "ADD";
					4'b1000 : inst_type = "SUB";
					4'b0001 : inst_type = "SLL";
					4'b0010 : inst_type = "SLT";
					4'b0011 : inst_type = "SLTU";
					4'b0100 : inst_type = "XOR";
					4'b0101 : inst_type = "SRL";
					4'b1101 : inst_type = "SRA";
					4'b0110 : inst_type = "OR";
					4'b0111 : inst_type = "AND";
					default  : inst_type = "R-type Unknown";
				endcase
			end
			
			7'b0010011 : begin // I-type Arith/Logic
				case(funct3)
					3'b000 : inst_type = "ADDI";
					3'b010 : inst_type = "SLTI";
					3'b011 : inst_type = "SLTIU";
					3'b100 : inst_type = "XORI";
					3'b110 : inst_type = "ORI";
					3'b111 : inst_type = "ANDI";
					3'b001 : inst_type = "SLLI";
					3'b101 : inst_type = funct7 ? "SRAI" : "SRLI";
					default : inst_type = "I-type ALU Unknown";
				endcase
			end
			
			7'b0000011 : begin // Loads
				case(funct3)
					3'b000 : inst_type = "LB";
					3'b001 : inst_type = "LH";
					3'b010 : inst_type = "LW";
					3'b100 : inst_type = "LBU";
					3'b101 : inst_type = "LHU";
					default : inst_type = "Load Unknown";
				endcase
			end
			
			7'b1100111 : inst_type = "JALR"; // JALR
			
			7'b0100011 : begin // S-type
				case(funct3)
					3'b000 : inst_type = "SB";
					3'b001 : inst_type = "SH";
					3'b010 : inst_type = "SW";
					default : inst_type = "S-type Unknown";
				endcase
			end
			
			7'b1100011 : begin // B-type
				case(funct3)
					3'b000 : inst_type = "BEQ";
					3'b001 : inst_type = "BNE";
					3'b100 : inst_type = "BLT";
					3'b101 : inst_type = "BGE";
					3'b110 : inst_type = "BLTU";
					3'b111 : inst_type = "BGEU";
					default : inst_type = "B-type Unknown";
				endcase
			end
			
			7'b0110111 : inst_type = "LUI"; 
			
			7'b0010111 : inst_type = "AUIPC";
			
			7'b1101111 : inst_type = "JAL";
			
			7'b0000000 : inst_type = "NOP";

			default    : inst_type = "Unknown";
		endcase
	end
	
	always @(posedge clk) begin
		c_count = c_count + 1;
		
		hazard = dut.IDEX_hazard_flush;
		if(hazard) begin
			hazard_detected = "YES";
		end
		else begin
			hazard_detected = "NO";
		end	
		
		$display("| Time: %0t | Cycle: %0d | Instruction Type: %s | Hazard?: %s |", $time, c_count, inst_type, hazard_detected);
	end
	
	
endmodule
	
