module MEMWB_buffer(
	input logic regwrite_i, memtoreg_i, clk, rst_n,
	input logic [31:0] memdata_i,
	input logic [31:0] ALU_result_i,
	input logic [4:0] rd_addr_i,
	output logic regwrite_o, memtoreg_o,
	output logic [31:0] memdata_o,
	output logic [31:0] ALU_result_o,
	output logic [4:0] rd_addr_o
	);
	
	always_ff @(posedge clk) begin
		if(!rst_n) begin	
			regwrite_o <= 1'b0;
			memtoreg_o <= 1'b0;
			memdata_o <= 32'b0;
			ALU_result_o <= 32'b0;
			rd_addr_o <= 32'b0;
		end
		else begin
			regwrite_o <= regwrite_i;
			memtoreg_o <= memtoreg_i;
			memdata_o <= memdata_i;
			ALU_result_o <= ALU_result_i;
			rd_addr_o <= rd_addr_i;
		end
	end
endmodule
	