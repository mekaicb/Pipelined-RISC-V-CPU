module imm_gen(
	input logic [31:0] instr_i,
	output logic [31:0] imm_o
	);
	
	logic [6:0] opcode;
	
	always_comb begin
		opcode = instr_i[6:0];

		case(opcode)
			
			// I-type 
			7'b0010011 : begin // imm arith/logic instructions (addi, andi etc)
				imm_o = {{20{instr_i[31]}}, instr_i[31:20]}; // Imm stored in 31:20, then sign extend
			end	
			
			7'b0000011 : begin // loads
				imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
			end
			
			7'b1100111 : begin // JALR
				imm_o = {{20{instr_i[31]}}, instr_i[31:20]};
			end
			
			// S-type
			7'b0100011 : begin
				imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
			end
			
			// B-type
			7'b1100011 : begin
				imm_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0}; // 1'b0 for word alignment
			end
			
			// U-type
			7'b0110111 : begin // LUI
				imm_o = {instr_i[31:12], 12'b0}; // U type stores the value in the upper 20 bits and then zero extends
			end
			
			7'b0010111 : begin //AUIPC
				imm_o = {instr_i[31:12], 12'b0};
			end
			
			//J-type
			7'b1101111 : begin //JAL
				imm_o = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0}; // imm[0] always 0 for J-type
			end
			
			default : begin
				imm_o = 32'b0;
			end
			
		endcase
	end
endmodule
	