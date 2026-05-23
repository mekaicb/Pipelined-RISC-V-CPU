module EXMEM_buffer(
	input logic clk, rst_n,
	input logic branch_i, memread_i, memwrite_i, regwrite_i, memtoreg_i, jump_i,
	input logic [31:0] imm_i,
	input logic zero,
	input logic [31:0] ALU_result_i,
	input logic [31:0] rs2_data_i,
	input logic [4:0] rd_addr_i,
	input logic [2:0] funct3,
	input logic funct7,
	output logic branch_o, memread_o, memwrite_o, regwrite_o, memtoreg_o, jump_o,
	output logic [31:0] imm_o,
	output logic zero_o,
	output logic [31:0] ALU_result_o,
	output logic [31:0] rs2_data_o,
	output logic [4:0] rd_addr_o,
	output logic [2:0] EXMEM_funct3,
	output logic EXMEM_funct7
	);
	
	always_ff @(posedge clk) begin
		if(!rst_n) begin
			branch_o <= 1'b0;
			memread_o <= 1'b0;
			memwrite_o <= 1'b0;
			regwrite_o <= 1'b0;
			memtoreg_o <= 1'b0;
			imm_o <= 32'b0;
			ALU_result_o <= 32'b0;
			rs2_data_o <= 32'b0;
			rd_addr_o <= 32'b0;
			EXMEM_funct3 <= 3'b0;
			EXMEM_funct7 <= 1'b0;
			zero_o <= 1'b0;
			jump_o <= 1'b0;
		end
		else begin
			branch_o <= branch_i;
			memread_o <= memread_i;
			memwrite_o <= memwrite_i;
			regwrite_o <= regwrite_i;
			memtoreg_o <= memtoreg_i;
			imm_o <= imm_i;
			ALU_result_o <= ALU_result_i;
			rs2_data_o <= rs2_data_i;
			rd_addr_o <= rd_addr_i;
			EXMEM_funct3 <= funct3;
			EXMEM_funct7 <= funct7;
			zero_o <= zero;
			jump_o <= jump_i;
		end
	end
endmodule