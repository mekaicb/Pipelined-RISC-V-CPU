	module CPU(
	input logic clk, rst_n
	);
	logic [31:0] pc_addr_in, pc_addr_out, IFID_addr_out, IDEX_addr_out;
	logic [31:0] instr_data_out, IFID_data_out;
	logic [6:0] opcode;
	
	logic [31:0] ALU_result, EXMEM_ALU_result, MEMWB_ALU_result;
	logic [31:0] rd_data;
	

	// Control Signals
	logic regwrite, IDEX_regwrite, EXMEM_regwrite, MEMWB_regwrite;
	logic branch, IDEX_branch, EXMEM_branch;
	logic memwrite,IDEX_memwrite, EXMEM_memwrite;
	logic memtoreg,IDEX_memtoreg, EXMEM_memtoreg, MEMWB_memtoreg;
	logic memread, IDEX_memread, EXMEM_memread;
	logic jump, IDEX_jump, EXMEM_jump;
	logic btarget, IDEX_btarget;
	logic ebreak, ebreak_halt;
	logic [1:0] aluop, IDEX_aluop;
	logic [3:0] ALU_cont;
	logic [1:0] alusrc, IDEX_alusrc;
	logic [1:0] pc_to_alu, IDEX_pc_to_alu;
	logic pcsrc;
	logic pcwrite, IFID_write, IDEX_hazard_flush;
	
	logic [4:0] rs1_addr, IDEX_rs1_addr;
	logic [4:0] rs2_addr, IDEX_rs2_addr;
	logic [4:0] rd_addr, IDEX_rd_addr, EXMEM_rd_addr, MEMWB_rd_addr;
	
	logic [31:0] rs1_data, IDEX_rs1_data;
	logic [31:0] rs2_data, IDEX_rs2_data, EXMEM_rs2_data;
	
	logic [2:0] funct3, IDEX_funct3, EXMEM_funct3;
	logic funct7, IDEX_funct7, EXMEM_funct7;
	
	logic [31:0] imm_gen_o, IDEX_imm;

	logic [31:0] branch_target, EXMEM_branch_target;
	logic [31:0] in1, in2;
	
	logic zero, EXMEM_zero; 
	logic overflow;

	logic [1:0] forward_A, forward_B;
	logic [31:0] forward_A_out, forward_B_out;
	
	logic [31:0] read_data, mem_data; // Wire 

	
	
	program_counter pc(
		.clk(clk),
		.rst_n(rst_n),
		
		.ebreak(ebreak_halt),
		.addr_in(pc_addr_in), 
		.addr_out(pc_addr_out),
		.pcwrite(pcwrite)
	);
	
	instruction_memory ROM(
		.clk(clk),
		
		.addr_in(pc_addr_out),
		.data_out(instr_data_out)
	);
	
	IFID_buffer IFID_buffer(
		.clk(clk), 
		.rst_n(rst_n),
		
		.pc_addr_i(pc_addr_out), 
		.inst_data_i(instr_data_out),
		.pc_addr_o(IFID_addr_out),
		.inst_data_o(IFID_data_out),
		
		.ebreak_flush(ebreak),
		.IFID_flush(pcsrc),
		.IFID_write(IFID_write)
	);
	
	
	reg_file reg_file(
		.rs2_addr(rs2_addr), 
		.rs1_addr(rs1_addr),
		.rd_addr(MEMWB_rd_addr),
		.rd_data(rd_data),
		.regwrite_sel(MEMWB_regwrite), 
		.clk(clk),
		.rst_n(rst_n), 
		.rs2_data(rs2_data),
		.rs1_data(rs1_data)
	);
	
	imm_gen imm_gen(
		.instr_i(IFID_data_out),
		.imm_o(imm_gen_o)
	);
	
	control_unit control(
		.opcode(opcode), 
		.ALUsrc(alusrc), 
		.pc_to_alu(pc_to_alu),
		.ALUop(aluop),
		.branch(branch), 
		.memread(memread),
		.memwrite(memwrite),
		.regwrite(regwrite),
		.memtoreg(memtoreg),
		.jump(jump),
		.btarget(btarget),
		.ebreak(ebreak)
	);
	
	IDEX_buffer IDEX_buffer(
		.clk(clk),
		.rst_n(rst_n), 
		
		.ALUsrc_i(alusrc),
		.branch_i(branch),
		.memread_i(memread), 
		.memwrite_i(memwrite), 
		.regwrite_i(regwrite),
		.memtoreg_i(memtoreg),
		.pc_to_alu_i(pc_to_alu),
		.ALUop_i(aluop), 
		.jump_i(jump),
		.btarget_i(btarget),
		
		.funct7(funct7),
		.funct3(funct3), 
		
		.pc_addr_i(IFID_addr_out), 
		.rs2_data_i(rs2_data),
		.rs1_data_i(rs1_data), 
		.rd_addr_i(rd_addr), 
		.rs2_addr_i(rs2_addr),
		.rs1_addr_i(rs1_addr),
		
		.imm_i(imm_gen_o),
		
		.ALUsrc_o(IDEX_alusrc), 
		.branch_o(IDEX_branch),
		.memread_o(IDEX_memread),
		.memwrite_o(IDEX_memwrite),
		.regwrite_o(IDEX_regwrite),
		.memtoreg_o(IDEX_memtoreg), 
		.pc_to_alu_o(IDEX_pc_to_alu),
		.ALUop_o(IDEX_aluop),
		.jump_o(IDEX_jump),
		.btarget_o(IDEX_btarget),
		.IDEX_flush(pcsrc),
		.IDEX_hazard_flush(IDEX_hazard_flush),
		
		.funct3_o(IDEX_funct3),
		.funct7_o(IDEX_funct7), 
		
		.pc_addr_o(IDEX_addr_out),
		.rs2_data_o(IDEX_rs2_data), 
		.rs1_data_o(IDEX_rs1_data),
		.rd_addr_o(IDEX_rd_addr), 
		.IDEX_rs2_addr(IDEX_rs2_addr),
		.IDEX_rs1_addr(IDEX_rs1_addr),
		
		.imm_o(IDEX_imm)
	);
	
	ALU_control ALU_control_unit(
		.funct7(IDEX_funct7), 
		.funct3(IDEX_funct3),
		.ALUop(IDEX_aluop),
		.ALUcontrol(ALU_cont)
	);
	
	ALU ALU(
		.in1(in1), 
		.in2(in2),
		.ALUcontrol(ALU_cont),
		.out(ALU_result),
		.zero(zero),
		.overflow(overflow)
	);
	
	forwarding_unit forwarding_unit(
		.IDEX_rs1_addr(IDEX_rs1_addr),
		.IDEX_rs2_addr(IDEX_rs2_addr),
		.EXMEM_rd_addr(EXMEM_rd_addr),
		.MEMWB_rd_addr(MEMWB_rd_addr),
		.EXMEM_regwrite(EXMEM_regwrite),
		.MEMWB_regwrite(MEMWB_regwrite),
		.forward_A(forward_A),
		.forward_B(forward_B)
	);
	
	hazard_detection hazard_unit(
		.IFID_rs1_addr(rs1_addr),
		.IFID_rs2_addr(rs2_addr),
		.IDEX_rd_addr(IDEX_rd_addr),
		.IDEX_memread(IDEX_memread),
		.pcwrite(pcwrite),
		.IFID_write(IFID_write),
		.IDEX_hazard_flush(IDEX_hazard_flush)
	);
	
	EXMEM_buffer EXMEM_buffer(
		.clk(clk), 
		.rst_n(rst_n), 
		
		.branch_i(IDEX_branch), 
		.memread_i(IDEX_memread), 
		.memwrite_i(IDEX_memwrite),
		.regwrite_i(IDEX_regwrite),
		.memtoreg_i(IDEX_memtoreg), 
		
		.imm_i(branch_target),
		.zero(zero),
		.ALU_result_i(ALU_result), 
		
		.rs2_data_i(forward_B_out), // forward_B_out to handle forwarded value on a hazard in case of store
		.rd_addr_i(IDEX_rd_addr), 
		
		.funct3(IDEX_funct3), 
		.funct7(IDEX_funct7), 
		
		.branch_o(EXMEM_branch),
		.memread_o(EXMEM_memread), 
		.memwrite_o(EXMEM_memwrite),
		.regwrite_o(EXMEM_regwrite),
		.memtoreg_o(EXMEM_memtoreg), 
		
		.imm_o(EXMEM_branch_target), 
		.zero_o(EXMEM_zero),
		.ALU_result_o(EXMEM_ALU_result),
		.EXMEM_flush(pcsrc),
		
		.rs2_data_o(EXMEM_rs2_data), 
		.rd_addr_o(EXMEM_rd_addr),
		
		.EXMEM_funct3(EXMEM_funct3),
		.EXMEM_funct7(EXMEM_funct7),
		
		.jump_i(IDEX_jump),
		.jump_o(EXMEM_jump)
	);	
				
	branch_control branch_control_unit(
		.zero(EXMEM_zero), 
		.branch(EXMEM_branch), 
		.ALU_result(EXMEM_ALU_result), 
		.funct3(EXMEM_funct3), 
		.pcsrc(pcsrc), 
		.jump(EXMEM_jump)
	);
	
	RAM RAM(
		.memwrite(EXMEM_memwrite), 
		.memread(EXMEM_memread),
		.clk(clk),
		.addr_in(EXMEM_ALU_result),
		.data_i(EXMEM_rs2_data),
		.funct3(EXMEM_funct3), 
		.data_o(read_data)
	);
	
	MEMWB_buffer MEMWB_buffer(
		.clk(clk), 
		.rst_n(rst_n),
		.regwrite_i(EXMEM_regwrite), 
		.memtoreg_i(EXMEM_memtoreg),
		.memdata_i(read_data), 
		.ALU_result_i(EXMEM_ALU_result),
		.rd_addr_i(EXMEM_rd_addr),
		.regwrite_o(MEMWB_regwrite),
		.memtoreg_o(MEMWB_memtoreg), 
		.memdata_o(mem_data), 
		.ALU_result_o(MEMWB_ALU_result), 
		.rd_addr_o(MEMWB_rd_addr)
	);
									
	always_comb begin
		pc_addr_in = pcsrc ? EXMEM_branch_target : (pc_addr_out + 4);
		rs2_addr = IFID_data_out[24:20];
		rs1_addr = IFID_data_out[19:15];
		rd_addr = IFID_data_out[11:7];
		opcode = IFID_data_out[6:0];
		funct7 = IFID_data_out[30];
		funct3 = IFID_data_out[14:12];
		
		case(forward_A)
			2'b00 : forward_A_out = IDEX_rs1_data;
			2'b01 : forward_A_out = rd_data;
			2'b10 : forward_A_out = EXMEM_ALU_result;
			default : forward_A_out = IDEX_rs1_data;
		endcase
		
		case(forward_B)
			2'b00 : forward_B_out = IDEX_rs2_data;
			2'b01 : forward_B_out = rd_data;
			2'b10 : forward_B_out = EXMEM_ALU_result;
			default : forward_B_out = IDEX_rs2_data;
		endcase
		
		case(IDEX_pc_to_alu) // in1 mux
			2'b00 : in1 = forward_A_out; // rs1
			2'b01 : in1 = IDEX_addr_out; // PC addr
			2'b10 : in1 = 32'b0;         // 0
			default: in1 = 32'b0;
		endcase
		 
		case(IDEX_alusrc) // in2 mux
			2'b00 : in2 = forward_B_out; // rs2
			2'b01 : in2 = IDEX_imm;      // imm
			2'b10 : in2 = 32'h00000004;  // 4
			default: in2 = 32'b0;
		endcase

		branch_target = (IDEX_btarget ? forward_A_out : IDEX_addr_out) + IDEX_imm;
		
		rd_data = MEMWB_memtoreg ? mem_data: MEMWB_ALU_result;
		
	end
	
	always_ff @(posedge clk) begin
		if(!rst_n)     
			ebreak_halt <= 0;
		else if(ebreak) 
			ebreak_halt <= 1; // sets and never clears until reset
	end
	
endmodule
		
		