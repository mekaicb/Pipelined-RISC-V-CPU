module CPU(
	input logic clk, rst_n
	);

	// Control Signals
	logic regwrite, alusrc, pc_to_alu, branch, memwrite, memread, memtoreg;
	logic [1:0] aluop;
	
	// PC
	logic [31:0] pc_addr_in, pc_addr_out;
	
	// Instruction Memory
	logic [31:0] instr_data_out;
	
	// IF/ID Buffer
	logic [31:0] IFID_addr_out, IFID_data_out;
	
	// Register File
	logic [6:0] opcode;
	logic [4:0] rs1_addr, rs2_addr, rd_addr;
	logic [31:0] rs1_data, rs2_data;
	logic [31:0] rd_data;
	logic [2:0] funct3;
	logic funct7;
	
	// Imm Gen
	logic [31:0] imm_gen_o;
	
	// ID/EX Buffer
	logic IDEX_regwrite, IDEX_alusrc, IDEX_pc_to_alu, IDEX_branch, IDEX_memwrite, IDEX_memread, IDEX_memtoreg;
	logic [1:0] IDEX_aluop;
	logic IDEX_funct7;
	logic [2:0] IDEX_funct3;
	logic [31:0] IDEX_addr_out;
	logic [31:0] IDEX_rs1_data, IDEX_rs2_data;
	logic [4:0] IDEX_rd_addr;
	logic [31:0] IDEX_imm;
	
	// ALU / EX Stage
	logic [31:0] branch_target;
	logic [31:0] in1, in2;
	logic zero, overflow;
	logic [31:0] ALU_result;
	logic [3:0] ALU_cont;
	
	// EX/MEM Buffer
	logic EXMEM_regwrite, EXMEM_branch, EXMEM_zero, EXMEM_memwrite, EXMEM_memread, EXMEM_memtoreg;
	logic [31:0] EXMEM_branch_target;
	logic [31:0] EXMEM_rs2_data;
	logic [31:0] EXMEM_ALU_result;
	logic [4:0] EXMEM_rd_addr;
	logic EXMEM_funct7;
	logic [2:0] EXMEM_funct3;
	
	// Branch Control Unit
	logic pcsrc;
	
	// RAM
	logic [31:0] read_data;

	// MEM/WB Buffer
	logic [31:0] mem_data;
	logic [31:0] MEMWB_ALU_result;
	logic [4:0] MEMWB_rd_addr;
	logic MEMWB_memtoreg, MEMWB_regwrite;
	
	program_counter pc(.addr_in(pc_addr_in), .clk(clk), .rst_n(rst_n), .addr_out(pc_addr_out));
	instruction_memory ROM(.addr_in(pc_addr_out), .clk(clk), .data_out(instr_data_out));
	IFID_buffer IFID_buffer(.pc_addr_i(pc_addr_out), .inst_data_i(instr_data_out), .clk(clk), .rst_n(rst_n), .pc_addr_o(IFID_addr_out), .inst_data_o(IFID_data_out));
	reg_file reg_file(.rs2_addr(rs2_addr), .rs1_addr(rs1_addr), .rd_addr(MEMWB_rd_addr), .rd_data(rd_data), .regwrite_sel(MEMWB_regwrite), .clk(clk), .rst_n(rst_n), .rs2_data(rs2_data), .rs1_data(rs1_data));
	imm_gen imm_gen(.instr_i(IFID_data_out), .imm_o(imm_gen_o));
	control_unit control(.opcode(opcode), .ALUsrc(alusrc), .pc_to_alu(pc_to_alu), .ALUop(aluop), .branch(branch), .memread(memread), .memwrite(memwrite), .regwrite(regwrite), .memtoreg(memtoreg));
	
	IDEX_buffer IDEX_buffer(.clk(clk), .rst_n(rst_n), .ALUsrc_i(alusrc), .branch_i(branch), .memread_i(memread), .memwrite_i(memwrite), .regwrite_i(regwrite), .memtoreg_i(memtoreg), .pc_to_alu_i(pc_to_alu),
									.ALUop_i(aluop), .funct7(funct7), .funct3(funct3), .pc_addr_i(IFID_addr_out), .rs2_data_i(rs2_data), .rs1_data_i(rs1_data), .rd_addr_i(rd_addr), .imm_i(imm_gen_o), 
									.ALUsrc_o(IDEX_alusrc), .branch_o(IDEX_branch), .memread_o(IDEX_memread), .memwrite_o(IDEX_memwrite), .regwrite_o(IDEX_regwrite), .memtoreg_o(IDEX_memtoreg), .pc_to_alu_o(IDEX_pc_to_alu),
									.ALUop_o(IDEX_aluop), .funct3_o(IDEX_funct3), .funct7_o(IDEX_funct7), .pc_addr_o(IDEX_addr_out), .rs2_data_o(IDEX_rs2_data), .rs1_data_o(IDEX_rs1_data), .rd_addr_o(IDEX_rd_addr), .imm_o(IDEX_imm)
									);

	ALU_control ALU_control_unit(.funct7(IDEX_funct7), .funct3(IDEX_funct3), .ALUop(IDEX_aluop), .ALUcontrol(ALU_cont));
	ALU ALU(.in1(in1), .in2(in2), .ALUcontrol(ALU_cont), .out(ALU_result), .zero(zero), .overflow(overflow));
	
	EXMEM_buffer EXMEM_buffer(.clk(clk), .rst_n(rst_n), .branch_i(IDEX_branch), .memread_i(IDEX_memread), .memwrite_i(IDEX_memwrite), .regwrite_i(IDEX_regwrite), .memtoreg_i(IDEX_memtoreg), .imm_i(branch_target),
										.zero(zero), .ALU_result_i(ALU_result), .rs2_data_i(IDEX_rs2_data), .rd_addr_i(IDEX_rd_addr), .funct3(IDEX_funct3), .funct7(IDEX_funct7), .branch_o(EXMEM_branch),
										.memread_o(EXMEM_memread), .memwrite_o(EXMEM_memwrite), .regwrite_o(EXMEM_regwrite), .memtoreg_o(EXMEM_memtoreg), .imm_o(EXMEM_branch_target), .ALU_result_o(EXMEM_ALU_result),
										.rs2_data_o(EXMEM_rs2_data), .rd_addr_o(EXMEM_rd_addr), .EXMEM_funct3(EXMEM_funct3), .EXMEM_funct7(EXMEM_funct7), .zero_o(EXMEM_zero)
										);
										
	branch_control branch_control_unit(.zero(EXMEM_zero), .branch(EXMEM_branch), .ALU_result(EXMEM_ALU_result), .funct3(EXMEM_funct3), .pcsrc(pcsrc));
	RAM RAM(.memwrite(EXMEM_memwrite), .memread(EXMEM_memread), .clk(clk), .addr_in(EXMEM_ALU_result), .data_i(EXMEM_rs2_data), .funct3(EXMEM_funct3), .data_o(read_data));
	
	MEMWB_buffer MEMWB_buffer(.clk(clk), .rst_n(rst_n), .regwrite_i(EXMEM_regwrite), .memtoreg_i(EXMEM_memtoreg), .memdata_i(read_data), .ALU_result_i(EXMEM_ALU_result), .rd_addr_i(EXMEM_rd_addr),
										.regwrite_o(MEMWB_regwrite), .memtoreg_o(MEMWB_memtoreg), .memdata_o(mem_data), .ALU_result_o(MEMWB_ALU_result), .rd_addr_o(MEMWB_rd_addr)
										);
									
	always_comb begin
		pc_addr_in = pcsrc ? EXMEM_branch_target : (pc_addr_out + 4);
		rs2_addr = IFID_data_out[24:20];
		rs1_addr = IFID_data_out[19:15];
		rd_addr = IFID_data_out[11:7];
		opcode = IFID_data_out[6:0];
		funct7 = IFID_data_out[30];
		funct3 = IFID_data_out[14:12];
		
		branch_target = (IDEX_imm << 1) + IDEX_addr_out;
		
		in1 = IDEX_pc_to_alu ? IDEX_addr_out : IDEX_rs1_data;
		in2 = IDEX_alusrc ? IDEX_imm : IDEX_rs2_data;
		
		rd_data = MEMWB_memtoreg ? mem_data: MEMWB_ALU_result;
		
	end
	
endmodule
		
		