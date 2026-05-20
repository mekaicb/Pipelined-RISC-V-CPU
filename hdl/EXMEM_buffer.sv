module EXMEM_buffer(
	input logic clk, rst_n,
	input logic branch_i, memread_i, memwrite_i, regwrite_i, memtoreg_i, jal_i,
	input logic [31:0] imm_i,
	input logic zero,
	input logic ALU_result_i,
	input logic [31:0] rs2_data_i,
	input logic [4:0] rd_addr_i,
	output logic branch_o, memread_o, memwrite_o, regwrite_o, memtoreg_o, jal_o,
	output logic [31:0] imm_o,
	output logic [31:0] ALU_result_o,
	output logic [31:0] rs2_data_o,
	output logic [4:0] rd_addr_o
	);
	
	always_ff @(posedge clk) begin
		if(!rst_n) begin
			branch_o <= 1'b0;
			memread_o <= 1'b0;
			memwrite_o <= 1'b0;
			regwrite_o <= 1'b0;
			memtoreg_o <= 1'b0;
			jal_o <= 1'b0;
			imm_o <= 32'b0;
			ALU_result_o <= 32'b0;
			rs2_data_o <= 32'b0;
			rd_addr_o <= 32'b0;
		end
		else begin
			branch_o <= branch_i;
			memread_o <= memread_i;
			memwrite_o <= memwrite_i;
			regwrite_o <= regwrite_i;
			memtoreg_o <= memtoreg_i;
			jal_o <= jal_i;
			imm_o <= imm_i;
			ALU_result_o <= ALU_result_i;
			rs2_data_o <= rs2_data_i;
			rd_addr_o <= rd_addr_i;
		end
	end
endmodule