module ALU_control(
	input logic funct7, // Only the 5th bit of funct7 matters
	input logic [2:0] funct3,
	input logic [1:0] ALUop,
	output logic [3:0] ALUcontrol
	);
	
	always_comb begin
		case(ALUop)
			
			2'b00 : ALUcontrol = 4'b0000; // ALways add
			
			2'b01 : begin
				case(funct3)
					3'b000 : ALUcontrol = 4'b0001; // BEQ (SUB -> Zero & Branch)
					3'b001 : ALUcontrol = 4'b0001; // BNE (SUB -> !Zero & Branch)
					3'b100 : ALUcontrol = 4'b0011; // BLT (SLT -> ALU Result & Branch)
					3'b101 : ALUcontrol = 4'b0011; // BGE (SLT -> !ALU Result & Branch)
					3'b110 : ALUcontrol = 4'b0100; // BLTU (SLTU -> ALU Result & Branch)
					3'b111 : ALUcontrol = 4'b0100; // BGEU (SLTU -> !ALU Result & Branch)
					default : ALUcontrol = 4'b0001; // Default SUB
				endcase
			end
			
			2'b10 : begin
				case({funct7, funct3})
					4'b0000 : ALUcontrol = 4'b0000; // ADD
					4'b1000 : ALUcontrol = 4'b0001; // SUB
					4'b0001 : ALUcontrol = 4'b0010; // SLL
					4'b0010 : ALUcontrol = 4'b0011; // SLT
					4'b0011 : ALUcontrol = 4'b0100; // SLTU
					4'b0100 : ALUcontrol = 4'b0101; // XOR
					4'b0101 : ALUcontrol = 4'b0110; // SRL
					4'b1101 : ALUcontrol = 4'b0111; // SRA
					4'b0110 : ALUcontrol = 4'b1000; // OR
					4'b0111 : ALUcontrol = 4'b1001; // AND
					default : ALUcontrol = 4'b0000; // Default ADD
				endcase
			end
			
			2'b11 : begin
				case(funct3)
					3'b000 : ALUcontrol = 4'b0000; // ADDI (ADD)
					3'b010 : ALUcontrol = 4'b0011; // SLTI (SLT)
					3'b011 : ALUcontrol = 4'b0100; // SLTIU (SLTU)
					3'b100 : ALUcontrol = 4'b0101; // XORI (XOR)
					3'b110 : ALUcontrol = 4'b1000; // ORI (OR)
					3'b111 : ALUcontrol = 4'b1001; // ANDI (AND)
					3'b001 : ALUcontrol = 4'b0010; // SLLI (SLL)
					
					3'b101 : begin
						ALUcontrol = funct7 ? 4'b0111 : 4'b0110; // SRAI vs SRLI
					end
					
					default : ALUcontrol = 4'b0000; // Default ADD
					
				endcase
			end
			
			default : ALUcontrol = 4'b0000;
				
		endcase 
	end
endmodule


/*

Covers 37/40 (Non system-type) RV32I instructions.

Note: Shift Immediate instructions depend on funct7. Added a seperate ternary statement to
account for this

*/