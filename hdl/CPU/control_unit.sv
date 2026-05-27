module control_unit(
	input logic [6:0] opcode,
	output logic [1:0] ALUop, ALUsrc, pc_to_alu, // EX stage control signals
	output logic btarget, jump,
	output logic branch, memread, memwrite, // MEM stage control signals
	output logic regwrite, memtoreg, // WB stage control signals
	output logic ebreak
	);
	
	always_comb begin
	
		case(opcode)
		
			// R-type
			7'b0110011 : begin 
				ALUsrc = 2'b00; 
				ALUop = 2'b10; 
				branch = 1'b0;
				memread = 1'b0;
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 2'b00;
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end
			
			// I-type (Arithmetic/Logic)
			7'b0010011 : begin
				ALUsrc = 2'b01;
				ALUop = 2'b11; 
				branch = 1'b0;  
				memread = 1'b0;
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 2'b00;
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end
			
			// I-type (Loads)
			7'b0000011 : begin
				ALUsrc = 2'b01;  
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b1;
				memwrite = 1'b0;
				regwrite = 1'b1;
				memtoreg = 1'b1; 
				pc_to_alu = 2'b00;
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end
			
			// I-type (JALR)
			7'b1100111 : begin //JALR (Jump and Link Register)
				ALUsrc = 2'b10; // in2 = 4
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 2'b01; // in1 = PC address. ALU result = PC + 4
				btarget = 1'b1;
				jump = 1'b1;
				ebreak = 1'b0;
			end
		
			// S-type 
			7'b0100011 : begin
				ALUsrc = 2'b01;   
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0;
				memwrite = 1'b1;
				regwrite = 1'b0;
				memtoreg = 1'b0; 
				pc_to_alu = 2'b00;
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end
			
			// B-type
			7'b1100011 : begin
				ALUsrc = 2'b00; 
				ALUop = 2'b01; // Branch
				branch = 1'b1;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b0; 
				memtoreg = 1'b0;
				pc_to_alu = 2'b00;
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end 
		
			// U-type	
			7'b0110111 : begin //LUI (Load upper immediate)
				ALUsrc = 2'b01;
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 2'b10; // in1 = 0. ALU result = 0 + shifted imm
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end
			
			7'b0010111 : begin //AUIPC (Add Upper Immediate to PC) 
				ALUsrc = 2'b01; 
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b1; 
				memtoreg = 1'b0;
				pc_to_alu = 2'b01; // in1 = PC address, ALU result = PC + shifted imm
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end
			
			// J-type
			7'b1101111 : begin //JAL (Jump and Link)
				ALUsrc = 2'b10; // in2 = 4.
				ALUop = 2'b00;
				branch = 1'b0;
				memread = 1'b0;
				memwrite = 1'b0;
				regwrite = 1'b1;
				memtoreg = 1'b0; 
				pc_to_alu = 2'b01; // in1 = PC address. ALU result = PC + 4
				btarget = 1'b0;
				jump = 1'b1;
				ebreak = 1'b0;
			end
			
			7'b1110011  : begin // EBREAK/ECALL
				ALUsrc = 2'b00; 
				ALUop = 2'b00;
				branch = 1'b0;
				memread = 1'b0;
				memwrite = 1'b0;
				regwrite = 1'b0;
				memtoreg = 1'b0; 
				pc_to_alu = 2'b00; 
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b1; // Halt the PC
			end			
				
			default : begin 
				ALUsrc = 2'b00;
				ALUop = 2'b00; 
				branch = 1'b0;  
				memread = 1'b0; 
				memwrite = 1'b0;
				regwrite = 1'b0; 
				memtoreg = 1'b0;
				pc_to_alu = 2'b00;
				btarget = 1'b0;
				jump = 1'b0;
				ebreak = 1'b0;
			end
		endcase
	end
endmodule


/*
	ALUsrc: Selects imm value (01), rs2(00), or 4 (10), as in2 ALU operand
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
	pc_to_alu: Selects rs1 (00), imm value (01), or 0 (10), as in1 ALU operand
	btarget: Selects PC (0) or rs1 (1) (For JALR) to add to offset as the branch target
	jump: Special control signal to signal pcsrc = 1 on JAL/JALR
*/