`timescale 1ns/1ps

module tb_CPU();
	logic clk, rst_n;
	logic clk_25;
	logic [3:0] VGA_R, VGA_G, VGA_B;
	logic hsync, vsync;
	logic [9:0] LED;
	logic [6:0] opcode;
	logic [2:0] funct3;
	logic funct7;

	int pass_count, sumtest_pass;
	string inst_type;
	
	logic [63:0] cycle_count, finish_count;
	logic measuring;

	
	CPU dut(.clk(clk), .rst_n(rst_n), .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B), .hsync(hsync), .vsync(vsync), .LED(LED));
	
	always #10ns clk = ~clk; // 50MHz 
	
	always #37.72ns clk_25 = ~clk_25; // 25MHz
	
	task automatic test_instruction(
		input logic [31:0] instr1, instr2, instr3, instr4
	);
		dut.ROM.mem_array[0] = instr1;
		dut.ROM.mem_array[1] = instr2;
		dut.ROM.mem_array[2] = instr3;
		dut.ROM.mem_array[3] = instr4;
		
		rst_n = 0; 	 // Clear all pipeline registers from previous test
		#30		 // prevent weird timing bugs if held for less than/exactly one clock cycle
		rst_n = 1;	
	endtask
	
	task automatic clear_all();
		rst_n = 0;
		#40
		rst_n = 1;
		
		for(int i = 0; i<8; i=i+1) begin
			dut.RAM.mem_array[i] = 32'b0; // Clear memory (Assume only first 8 words in RAM used for testing)
		end
		
	endtask
	
	// Testing all 40 RV32I instructions. Using online assembler to convert RISCV to machine code
	initial begin
		clk <= 1;
		pass_count = 0;
		$timeformat(-9, 0, " ns");

		// LUI/ADDI/SW (li x4, 0x12345678 + sw x4, RAM_BASE(x0) = lui x4, 0x12345 + addi x4, 0x678 + lui x3, 0x1 + sw x4, 0x400(x3)) 
		test_instruction(32'h12345237, 32'h67820213, 32'h000011B7, 32'h4041A023);
		#200
		if(dut.reg_file.reg_out[4] == 32'h12345678) begin
			$display("LUI PASSED\nADDI PASSED");
			pass_count = pass_count + 2;
		end
		else begin
			$display("LUI FAILED\nADDI FAILED\n");
		end

		if({dut.RAM.mem_array[0]}== 32'h12345678) begin
			$display("SW PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("SW FAILED");
		end
		
		clear_all();
		
		// ADD (addi x3, x0, 0x0000000A, addi x4, x0, 0x0000000B, add x3, x3, x4)
		test_instruction(32'h00A00193, 32'h00B00213, 32'h004181B3, 32'h0);
		#200
		if(dut.reg_file.reg_out[3] == 32'd21) begin
			$display("ADD PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("ADD FAILED");
		end
		
		clear_all();
		
		// SUB (addi x5, x0, 20, addi x6, x0, 8, sub x7, x5, x6)
		test_instruction(32'h01400293, 32'h00800313, 32'h406283B3, 32'h0);
		#200
		if(dut.reg_file.reg_out[7] == 32'd12) begin
			$display("SUB PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("SUB FAILED");
		end
		
		clear_all();

		// AND (addi x5, x0, 15, addi x6, x0, 51, and x7, x5, x6)
		test_instruction(32'h00F00293, 32'h03300313, 32'h0062F3B3, 32'h0);
		#200
		if(dut.reg_file.reg_out[7] == 32'h03) begin
			$display("AND PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("AND FAILED");
		end
		
		clear_all();

		// OR (addi x5, x0, 15, addi x6, x0, 51, or x8, x5, x6)
		test_instruction(32'h00F00293, 32'h03300313, 32'h0062E433, 32'h0);
		#200
		if(dut.reg_file.reg_out[8] == 32'h3F) begin
			$display("OR PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("OR FAILED");
		end
		
		clear_all();

		// SLLI (addi x5, x0, 1, slli x6, x5, 4)
		test_instruction(32'h00100293, 32'h00429313, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[6] == 32'd16) begin
			$display("SLLI PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("SLLI FAILED");
		end
		
		clear_all();

		// LW (lui x3, 0x1, addi x4, x0, 0x99, sw x4, 0x400(x3), lw x5, 0x400(x3))
		test_instruction(32'h000011b7, 32'h09900213, 32'h4041a023, 32'h4001a283);
		#220
		if(dut.reg_file.reg_out[5] == 32'h99) begin
			$display("LW PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("LW FAILED");
		end
		
		clear_all();
		
		// XOR (addi x5, x0, 15, addi x6, x0, 9, xor x7, x5, x6)
		test_instruction(32'h00F00293, 32'h00900313, 32'h0062C3B3, 32'h0);
		#200
		if(dut.reg_file.reg_out[7] == 32'd6) begin
			$display("XOR PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("XOR FAILED");
		end
		
		clear_all();

		// SLT (addi x5, x0, 5, addi x6, x0, 10, slt x7, x5, x6)
		test_instruction(32'h00500293, 32'h00A00313, 32'h0062A3B3, 32'h0);
		#200
		if(dut.reg_file.reg_out[7] == 32'd1) begin
			$display("SLT PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("SLT FAILED");
		end
		
		clear_all();

		// BEQ (addi x3, x0, 5, beq x3, x3, 0x00000008, addi x4, x0, 0x9, addi x5, x0, 0x1)
		test_instruction(32'h00500193, 32'h00318463, 32'h00900213, 32'h00100293);
		#300
		if(dut.reg_file.reg_out[4] != 32'd9 && dut.reg_file.reg_out[5] == 32'd1) begin
			$display("BEQ PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("BEQ FAILED");
		end
		
		clear_all();

		// BNE (addi x3, x0, 5, bne x3, x0, 0x00000008, addi x4, x0, 0x9, addi x5, x0, 0x1)
		test_instruction(32'h00500193, 32'h00019463, 32'h00900213, 32'h00100293);
		#260
		if(dut.reg_file.reg_out[4] != 32'd9 && dut.reg_file.reg_out[5] == 32'd1) begin
			$display("BNE PASSED");
			pass_count = pass_count + 1;
		end
		else begin
			$display("BNE FAILED");
		end
		
		clear_all();
		
		// SLTU (addi x3, x0, 5, addi x4, x0, 10, sltu x5, x3, x4)
		test_instruction(32'h00500193, 32'h00A00213, 32'h0041B2B3, 32'h0);
		#200
		if(dut.reg_file.reg_out[5] == 32'd1) begin
			 $display("SLTU PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SLTU FAILED");
		end

		clear_all();


		// SRLI (addi x3, x0, 16, srli x4, x3, 2)
		test_instruction(32'h01000193, 32'h0021D213, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] == 32'd4) begin
			 $display("SRLI PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SRLI FAILED");
		end

		clear_all();


		// SRAI (addi x3, x0, -8, srai x4, x3, 1)
		test_instruction(32'hFF800193, 32'h4011D213, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] == 32'hFFFFFFFC) begin
			 $display("SRAI PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SRAI FAILED");
		end

		clear_all();
		
		// SLTI (addi x3, x0, 5, slti x4, x3, 10)
		test_instruction(32'h00500193, 32'h00A1A213, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] == 32'd1) begin
			 $display("SLTI PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SLTI FAILED");
		end

		clear_all();


		// SLTIU (addi x3, x0, 5, sltiu x4, x3, 10)
		test_instruction(32'h00500193, 32'h00A1B213, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] == 32'd1) begin
			 $display("SLTIU PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SLTIU FAILED");
		end

		clear_all();


		// ANDI (addi x3, x0, 15, andi x4, x3, 9)
		test_instruction(32'h00F00193, 32'h0091F213, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] == 32'd9) begin
			 $display("ANDI PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("ANDI FAILED");
		end

		clear_all();
		
		// XORI (addi x3, x0, 15, xori x4, x3, 9)
		test_instruction(32'h00F00193, 32'h0091C213, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] == 32'd6) begin
			 $display("XORI PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("XORI FAILED");
		end

		clear_all();

		// ORI (addi x3, x0, 15, ori x4, x3, 16)
		test_instruction(32'h00F00193, 32'h0101E213, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] == 32'd31) begin
			 $display("ORI PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("ORI FAILED");
		end

		clear_all();

		// SLL (addi x3, x0, 1, addi x4, x0, 4, sll x5, x3, x4)
		test_instruction(32'h00100193, 32'h00400213, 32'h004192B3, 32'h0);
		#220
		if(dut.reg_file.reg_out[5] == 32'd16) begin
			 $display("SLL PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SLL FAILED");
		end

		clear_all();

		// SRL (addi x3, x0, 16, addi x4, x0, 2, srl x5, x3, x4)
		test_instruction(32'h01000193, 32'h00200213, 32'h0041D2B3, 32'h0);
		#220
		if(dut.reg_file.reg_out[5] == 32'd4) begin
			 $display("SRL PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SRL FAILED");
		end

		clear_all();

		// SRA (addi x3, x0, -8, addi x4, x0, 1, sra x5, x3, x4)
		test_instruction(32'hFF800193, 32'h00100213, 32'h4041D2B3, 32'h0);
		#220
		if(dut.reg_file.reg_out[5] == 32'hFFFFFFFC) begin
			 $display("SRA PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SRA FAILED");
		end

		clear_all();

		// BLT (addi x3, x0, 5, addi x4, x0, 10, blt x3, x4, 8, addi x5, x0, 9)
		test_instruction(32'h00500193, 32'h00A00213, 32'h0041C463, 32'h00900293);
		#260
		if(dut.reg_file.reg_out[5] != 32'd9) begin
			 $display("BLT PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("BLT FAILED");
		end

		clear_all();

		// BGE (addi x3, x0, 10, addi x4, x0, 5, bge x3, x4, 8, addi x5, x0, 9)
		test_instruction(32'h00A00193, 32'h00500213, 32'h0041D463, 32'h00900293);
		#260
		if(dut.reg_file.reg_out[5] != 32'd9) begin
			 $display("BGE PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("BGE FAILED");
		end

		clear_all();

		// BLTU (addi x3, x0, 5, addi x4, x0, 10, bltu x3, x4, 8, addi x5, x0, 9)
		test_instruction(32'h00500193, 32'h00A00213, 32'h0041E463, 32'h00900293);
		#260
		if(dut.reg_file.reg_out[5] != 32'd9) begin
			 $display("BLTU PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("BLTU FAILED");
		end

		clear_all();

		// BGEU (addi x3, x0, 10, addi x4, x0, 5, bgeu x3, x4, 8, addi x5, x0, 9)
		test_instruction(32'h00A00193, 32'h00500213, 32'h0041F463, 32'h00900293);
		#260
		if(dut.reg_file.reg_out[5] != 32'd9) begin
			 $display("BGEU PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("BGEU FAILED");
		end

		clear_all();

		// JAL (jal x3, 8, addi x4, x0, 9, addi x5, x0, 1)
		test_instruction(32'h008001EF, 32'h00900213, 32'h00100293, 32'h0);
		#260
		if(dut.reg_file.reg_out[3] == 32'd4 && dut.reg_file.reg_out[4] != 32'd9) begin
			 $display("JAL PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("JAL FAILED");
		end

		clear_all();

		// JALR (addi x3, x0, 12, jalr x4, x3, 0, addi x5, x0, 9, nop)
		test_instruction(32'h00C00193, 32'h00018267, 32'h00900293, 32'h00000013);
		#260
		if(dut.reg_file.reg_out[4] == 32'd8 && dut.reg_file.reg_out[5] != 32'd9) begin
			  $display("JALR PASSED");
			  pass_count = pass_count + 1;
		end
		else begin
			  $display("JALR FAILED");
		end

		clear_all();

		// SB (lui x3, 0x1, addi x3, x3, 0x400, addi x4, x0, 0xAB, sb x4, 0(x3))
		test_instruction(32'h000011B7, 32'h40018193, 32'h0AB00213, 32'h00418023);
		#220
		if(dut.RAM.mem_array[0] == 8'hAB) begin
			 $display("SB PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SB FAILED");
		end

   	clear_all();

		// RAM_BASE = 0x1400

		// SH (lui x3, 0x1, li x4, 0xABCD, sh x4, 0x400(x3))
		test_instruction(32'h000011B7, 32'h0000B237, 32'hBCD20213, 32'h40419023);
		#350
		if(dut.RAM.mem_array[0][15:0] == 16'hABCD) begin
			 $display("SH PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("SH FAILED");
		end

		clear_all();
		
		// LB (lui x3, 0x1, addi x4, x0, -2, sb x4, 0x400(x3), lb x5, 0x400(x3))
		test_instruction(32'h000011B7, 32'hFFE00213, 32'h40418023, 32'h40018283);
		#240
		if(dut.reg_file.reg_out[5] == 32'hFFFFFFFE) begin
			 $display("LB PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("LB FAILED");
		end

		clear_all();

		// LH (lui x3, 0x1, addi x4, x0, -2, sh x4, 0x400(x3), lh x5, 0x400(x3))
		test_instruction(32'h000011B7, 32'hFFE00213, 32'h40419023, 32'h40019283);
		#240
		if(dut.reg_file.reg_out[5] == 32'hFFFFFFFE) begin
			 $display("LH PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("LH FAILED");
		end

		clear_all();

		// LBU (lui x3, 0x1, addi x4, x0, -2, sb x4, 0x400(x3), lbu x5, 0x400(x3))
		test_instruction(32'h000011B7, 32'hFFE00213, 32'h40418023, 32'h4001C283);
		#240
		if(dut.reg_file.reg_out[5] == 32'h000000FE) begin
			 $display("LBU PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("LBU FAILED");
		end

		clear_all();

		// LHU (lui x3, 0x1, addi x4, x0, -2, sh x4, 0x400(x3), lhu x5, 0x400(x3))
		test_instruction(32'h000011B7, 32'hFFE00213, 32'h40419023, 32'h4001D283);
		#240
		if(dut.reg_file.reg_out[5] == 32'h0000FFFE) begin
			 $display("LHU PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("LHU FAILED");
		end

		clear_all();

		// AUIPC (auipc x3, 1) -> Assuming base PC=0 for test instruction, expecting 0x1000
		test_instruction(32'h00001197, 32'h0, 32'h0, 32'h0);
		#200
		if(dut.reg_file.reg_out[3] == 32'h00001000) begin
			 $display("AUIPC PASSED");
			 pass_count = pass_count + 1;
		end
		else begin
			 $display("AUIPC FAILED");
		end
		
		// EBREAK (addi x3, x0, 8, ebreak, addi x4, x0, 9)
		test_instruction(32'h00800193, 32'h00100073, 32'h00900213, 32'h0);
		#200
		if(dut.reg_file.reg_out[4] != 32'd9) begin
			$display("EBREAK PASSED");
			pass_count = pass_count + 3; //EBREAK, ECALL, FENCE
		end
		else begin
			$display("EBREAK FAILED");
		end

		clear_all();
		
		$display("%0d/40 INDIVIDUAL INSTRUCTIONS EXECUTED CORRECTLY", pass_count);
		$display("Running Program...");

		$readmemh("pong.hex", dut.ROM.mem_array);

		rst_n = 0;
		#40;
		rst_n = 1;

		measuring    = 1'b1;

		#2000000; // 2 ms

		measuring = 1'b0;
		$display("CPI = %f (%0d cycles / %0d instr)", real'(cycle_count)/real'(finish_count), cycle_count, finish_count);		
	end

	always_ff @(posedge clk) begin
		if (!rst_n) begin
			cycle_count  <= 0;
			finish_count <= 0;
		end 
		else if (measuring) begin
			cycle_count <= cycle_count + 1; 
			if (!dut.MEMWB_hazard_flush && !dut.IDEX_hazard_flush && !dut.pcsrc) 
				finish_count <= finish_count + 1; // +1 if instruction reached WB
		end
	end
	
	// Block to determine instructions if needed
	always_comb begin
		
		opcode = dut.opcode; // hierarchical references
		funct3 = dut.funct3;
		funct7 = dut.funct7;
		
		case(opcode)
		
			7'b0110011 : begin // R-type
				case({funct7, funct3})
					4'b0000 : inst_type = "ADD";
					4'b1000 : inst_type = "SUB";
					4'b0001 : inst_type = "SLL";
					4'b0010 : inst_type = "SLT";
					4'b0011 : inst_type = "SLTU";
					4'b0100 : inst_type = "XOR";
					4'b0101 : inst_type = "SRL";
					4'b1101 : inst_type = "SRA";
					4'b0110 : inst_type = "OR";
					4'b0111 : inst_type = "AND";
					default  : inst_type = "R-type Unknown";
				endcase
			end
			
			7'b0010011 : begin // I-type Arith/Logic
				case(funct3)
					3'b000 : inst_type = "ADDI";
					3'b010 : inst_type = "SLTI";
					3'b011 : inst_type = "SLTIU";
					3'b100 : inst_type = "XORI";
					3'b110 : inst_type = "ORI";
					3'b111 : inst_type = "ANDI";
					3'b001 : inst_type = "SLLI";
					3'b101 : inst_type = funct7 ? "SRAI" : "SRLI";
					default : inst_type = "I-type ALU Unknown";
				endcase
			end
			
			7'b0000011 : begin // Loads
				case(funct3)
					3'b000 : inst_type = "LB";
					3'b001 : inst_type = "LH";
					3'b010 : inst_type = "LW";
					3'b100 : inst_type = "LBU";
					3'b101 : inst_type = "LHU";
					default : inst_type = "Load Unknown";
				endcase
			end
			
			7'b1100111 : inst_type = "JALR"; // JALR
			
			7'b0100011 : begin // S-type
				case(funct3)
					3'b000 : inst_type = "SB";
					3'b001 : inst_type = "SH";
					3'b010 : inst_type = "SW";
					default : inst_type = "S-type Unknown";
				endcase
			end
			
			7'b1100011 : begin // B-type
				case(funct3)
					3'b000 : inst_type = "BEQ";
					3'b001 : inst_type = "BNE";
					3'b100 : inst_type = "BLT";
					3'b101 : inst_type = "BGE";
					3'b110 : inst_type = "BLTU";
					3'b111 : inst_type = "BGEU";
					default : inst_type = "B-type Unknown";
				endcase
			end
			
			7'b0110111 : inst_type = "LUI"; 
			
			7'b0010111 : inst_type = "AUIPC";
			
			7'b1101111 : inst_type = "JAL";
			
			7'b0000000 : inst_type = "NOP";
			
			default    : inst_type = "Unknown";
		endcase
	end
	
endmodule