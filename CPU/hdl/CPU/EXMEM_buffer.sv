module EXMEM_buffer(
	input logic clk, rst_n,
	input logic branch_i, memread_i, memwrite_i, regwrite_i, memtoreg_i,
	input logic [31:0] ALU_result_i,
	input logic [31:0] rs2_data_i,
	input logic [4:0] rd_addr_i,
	input logic [2:0] funct3,
	input logic EXMEM_flush,
	input logic EXMEM_stall,
	output logic memread_o, memwrite_o, regwrite_o, memtoreg_o,
	output logic [31:0] ALU_result_o,
	output logic [31:0] rs2_data_o,
	output logic [4:0] rd_addr_o,
	output logic [2:0] EXMEM_funct3
	);
	
	always_ff @(posedge clk) begin
		if(!rst_n || EXMEM_flush) begin
			memread_o <= 1'b0;
			memwrite_o <= 1'b0;
			regwrite_o <= 1'b0;
			memtoreg_o <= 1'b0;
			ALU_result_o <= 32'b0;
			rs2_data_o <= 32'b0;
			rd_addr_o <= 5'b0;
			EXMEM_funct3 <= 3'b0;
		end
		else if (!EXMEM_stall) begin
			memread_o <= memread_i;
			memwrite_o <= memwrite_i;
			regwrite_o <= regwrite_i;
			memtoreg_o <= memtoreg_i;
			ALU_result_o <= ALU_result_i;
			rs2_data_o <= rs2_data_i;
			rd_addr_o <= rd_addr_i;
			EXMEM_funct3 <= funct3;
		end
	end
endmodule