module branch_control(
	input logic zero, branch,
	input logic [31:0] ALU_result,
	input logic [2:0] funct3,
	output logic pcsrc
	);
	
	always_comb begin
		case(funct3)
			3'b000 : pcsrc = (zero & branch); // BEQ
			3'b001 : pcsrc = (!zero & branch); // BNE
			3'b100, 3'b110 : pcsrc = (ALU_result[0] & branch); // BLT/BLTU
			3'b101, 3'b111 : pcsrc = (!ALU_result[0] & branch); // BGE/BGEU
			default : pcsrc = 1'b0;
		endcase
	end
endmodule
	
	
	