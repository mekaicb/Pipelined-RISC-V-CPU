module IDEX_buffer(
	input logic clk, rst_n, IDEX_flush, IDEX_hazard_flush,
	input logic branch_i, memread_i, memwrite_i, regwrite_i, memtoreg_i, jump_i, btarget_i,
	input logic [1:0] ALUop_i, ALUsrc_i, pc_to_alu_i,
	input logic funct7,
	input logic [2:0] funct3,
	input logic [31:0] pc_addr_i,
	input logic [31:0] rs2_data_i, rs1_data_i,
	input logic [4:0] rd_addr_i, rs2_addr_i, rs1_addr_i,
	input logic [31:0] imm_i,
	input logic IDEX_stall,
	output logic branch_o, memread_o, memwrite_o, regwrite_o, memtoreg_o, jump_o, btarget_o,
	output logic [1:0] ALUop_o, ALUsrc_o, pc_to_alu_o,
	output logic funct7_o,
	output logic [2:0] funct3_o,
	output logic [31:0] pc_addr_o,
	output logic [31:0] rs2_data_o, rs1_data_o, 
	output logic [4:0] rd_addr_o, IDEX_rs2_addr, IDEX_rs1_addr,
	output logic [31:0] imm_o
	);
	
	always_ff @(posedge clk) begin
		if(!rst_n || IDEX_flush || IDEX_hazard_flush) begin // IDEX_flush to flush for branch delay, IDEX_hazard_flush to flush on load/store hazard
			ALUsrc_o <= 2'b00;
			ALUop_o <= 2'b00;
			branch_o <= 1'b0;
			memread_o <= 1'b0;
			memwrite_o <= 1'b0;
			regwrite_o <= 1'b0;
			memtoreg_o <= 1'b0;
			pc_to_alu_o <= 2'b00;
			jump_o <= 1'b0;
			btarget_o <= 1'b0;
			funct7_o <= 1'b0;
			funct3_o <= 3'b0;
			pc_addr_o <= 32'b0;
			rs2_data_o <= 32'b0;
			rs1_data_o <= 32'b0;
			rd_addr_o <= 5'b0;
			imm_o <= 32'b0;
			IDEX_rs2_addr <= 5'b0;
			IDEX_rs1_addr <= 5'b0;
		end
		else if (!IDEX_stall) begin
			ALUsrc_o <= ALUsrc_i;
			ALUop_o <= ALUop_i;
			branch_o <= branch_i;
			memread_o <= memread_i;
			memwrite_o <= memwrite_i;
			regwrite_o <= regwrite_i;
			memtoreg_o <= memtoreg_i;
			pc_to_alu_o <= pc_to_alu_i;
			jump_o <= jump_i;
			btarget_o <= btarget_i;
			funct7_o <= funct7;
			funct3_o <= funct3;
			pc_addr_o <= pc_addr_i;
			rs2_data_o <= rs2_data_i;
			rs1_data_o <= rs1_data_i;
			rd_addr_o <= rd_addr_i;
			imm_o <= imm_i;
			IDEX_rs2_addr <= rs2_addr_i;
			IDEX_rs1_addr <= rs1_addr_i;
		end

	end
	
endmodule
	
	