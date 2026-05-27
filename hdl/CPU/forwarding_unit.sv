module forwarding_unit(
	input logic [4:0] IDEX_rs1_addr, IDEX_rs2_addr, EXMEM_rd_addr, MEMWB_rd_addr,
	input logic EXMEM_regwrite, MEMWB_regwrite,
	output logic [1:0] forward_A, forward_B
	);
	
	logic [4:0] x0;
	logic FA, FB;
	
	always_comb begin
		forward_A = 2'b00;
		forward_B = 2'b00;
		FA = 1'b0;
		FB = 1'b0;
		
		x0 = 5'b0; // Zero register should not be included in forwards
	
		if((IDEX_rs1_addr != x0) && EXMEM_regwrite && (EXMEM_rd_addr == IDEX_rs1_addr)) begin // 1a
			forward_A = 2'b10; // Forward ALU result
			FA = 1;
		end
		if((IDEX_rs2_addr != x0) && EXMEM_regwrite && (EXMEM_rd_addr == IDEX_rs2_addr)) begin // 1b
			forward_B = 2'b10;
			FB = 1;
		end
		
		if(!FA && (IDEX_rs1_addr != x0) && MEMWB_regwrite && (MEMWB_rd_addr == IDEX_rs1_addr)) begin // 2a
			forward_A = 2'b01; // Forward WB MUX result
		end
		if(!FB && (IDEX_rs2_addr != x0) && MEMWB_regwrite && (MEMWB_rd_addr == IDEX_rs2_addr)) begin // 2b
			forward_B = 2'b01; 
		end	

	end
	
endmodule	

/*
1a: EXMEM.rd = IDEX.rs1 
1b: EXMEM_rd = IDEX.rs2 
2a: MEMWB_rd = IDEX.rs1
2b: MEMWB_rd = IDEX.rs2

Only a hazard if write is enabled.

Only check for 2a/2b if 1a/1b didnt already forward

*/