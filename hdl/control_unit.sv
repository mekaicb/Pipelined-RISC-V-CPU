module control_unit(
	input logic [6:0] opcode, 
	output logic ALUsrc, pc_to_alu, 
	output logic [1:0] ALUop, // EX stage control signals
	output logic branch, memread, memwrite, // MEM stage control signals
	output logic regwrite, memtoreg, jal // WB stage control signals
	);
	
	always_comb begin
	
		case(opcode)
		
			// R-type
			7'b0110011 : begin 
				ALUsrc = 1'b0; 
				ALUop = 2'b10; 
				branch = 1'b0;
				memread = 1'b0;
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 1'b0;
				jal = 1'b0;
			end
			
			// I-type (Arithmetic/Logic)
			7'b0010011 : begin
				ALUsrc = 1'b1;  
				ALUop = 2'b11; 
				branch = 1'b0;  
				memread = 1'b0;
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 1'b0;
				jal = 1'b0;
			end
			
			// I-type (Loads)
			7'b0000011 : begin
				ALUsrc = 1'b1;  
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b1;
				memwrite = 1'b0;
				regwrite = 1'b1;
				memtoreg = 1'b1; 
				pc_to_alu = 1'b0;
				jal = 1'b0;
			end
			
			// S-type 
			7'b0100011 : begin
				ALUsrc = 1'b1;  
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0;
				memwrite = 1'b1;
				regwrite = 1'b0; // store is a 4 stage instruction, dont care
				memtoreg = 1'b0; 
				pc_to_alu = 1'b0;
				jal = 1'b0;
			end
			
			// B-type
			7'b1100011 : begin
				ALUsrc = 1'b0; 
				ALUop = 2'b01; 
				branch = 1'b1;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b0; 
				memtoreg = 1'b0;
				pc_to_alu = 1'b0;
				jal = 1'b0;
			end 
		
			// U-type	
			7'b0110111 : begin //LUI (Load upper immediate)
				ALUsrc = 1'b1; // Although doesn't need the ALU, route through so that can be selected by memtoreg
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 1'b0;
				jal = 1'b0;
			end
			
			7'b0010111 : begin //AUIPC (Add Upper Immediate to PC) 
				ALUsrc = 1'b1; // add imm (Note: will need additional mux to select between rs1_data & pc addr
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 1'b1;
				jal = 1'b0;
			end
			
			// J-type
			7'b1101111 : begin //JAL (Jump and Link)
				ALUsrc = 1'b1;
				ALUop = 2'b00;
				branch = 1'b0;
				memread = 1'b0;
				memwrite = 1'b0;
				regwrite = 1'b1;
				memtoreg = 1'b0;  
				pc_to_alu = 1'b1;   // PC + imm = jump target
				jal = 1'b1; // write PC+4 to rd instead
			end
			
			7'b1100111 : begin //JALR (Jump and Link Register)
				ALUsrc = 1'b1; 
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 1'b0;
				jal = 1'b1;
			end
			
			default : begin
				ALUsrc = 1'b0; 
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b0; 
				memtoreg = 1'b0;
				pc_to_alu = 1'b0;
				jal = 1'b0;
			end
		endcase
	end
endmodule


/*
	ALUsrc: Selects imm value (1) or reg (0) as ALU operand
	ALUop: Selects how ALU control should operate
			- 00 = add (loads/stores to compute effective addr)
			- 01 = sub (beq)
			- 10 = check funct7 & funct3
			- 11 = check funct3 only
	branch: Branch (1) or no branch (0)?
	memread: Read (1) or no read (0)?
	memwrite: Write (1) or no write (0)?
	regwrite: Write to register file (1)?
	memtoreg: Selects either the ALU result (0) or memory data (1) to send to the reg file
	pc_to_alu: control signal for additional mux added in to account for auipc instr
	jal: control signal for additional mux added to account for J-type commands. sits after memtoreg to select PC+4 or memtoreg output
*/