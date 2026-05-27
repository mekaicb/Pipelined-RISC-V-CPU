module hazard_detection(
	input logic [4:0] IFID_rs1_addr, IFID_rs2_addr, IDEX_rd_addr,
	input logic IDEX_memread,
	output logic pcwrite, IFID_write, IDEX_hazard_flush
);

	always_comb begin
		pcwrite = 1'b0;
		IFID_write = 1'b0;
		IDEX_hazard_flush = 1'b0;
		
		if(IDEX_memread) begin
			if(IDEX_rd_addr == IFID_rs1_addr || IDEX_rd_addr == IFID_rs2_addr) begin
				pcwrite = 1'b1; // Stall PC
				IFID_write = 1'b1; // Stall IFID buffer
				IDEX_hazard_flush = 1'b1; // Flush IDEX
			end
		end
	end
		

endmodule

/*
	Module to detect Load/Store hazards
*/