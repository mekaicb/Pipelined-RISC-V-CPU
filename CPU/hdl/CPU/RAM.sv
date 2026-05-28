module RAM(
	input logic memwrite, memread, clk,
	input logic [31:0] addr_in,
	input logic [31:0] data_i,
	input logic [2:0] funct3,
	output logic [31:0] data_o
	);
	
	logic [31:0] eff_addr, data;
	logic [7:0] mem_array[0:131071]; // byte sized memory array of 131072 bytes 
	localparam offset = 32'h10000; // Starts after ROM. ROM = 0-64kB, 64kB = 0z00010000 (Type param for internal constants)
	
	always_comb begin
		eff_addr = addr_in - offset;
		data = 32'b0;
		
		if(memread) begin
			case(funct3)
				3'b000 : begin // LB
					data = mem_array[eff_addr[16:0]]; // 17 addr bits to address any of the 131071 bytes
					data_o = {{24{data[7]}}, data[7:0]}; // Sign extended
				end
				3'b001 : begin // LH
					data = {mem_array[eff_addr[16:0]+1], mem_array[eff_addr[16:0]]}; // Little endian: Lower address = Lower byte, even though it reads before in memory
					data_o = {{16{data[15]}}, data[15:0]};
				end
				3'b010 : begin // LW
					data_o = {mem_array[eff_addr[16:0]+3], mem_array[eff_addr[16:0]+2], mem_array[eff_addr[16:0]+1], mem_array[eff_addr[16:0]]};
				end
				3'b100 : begin // LBU
					data = mem_array[eff_addr[16:0]]; 
					data_o = {{24{1'b0}}, data[7:0]};
				end
				3'b101 : begin // LHU
					data = {mem_array[eff_addr[16:0]+1], mem_array[eff_addr[16:0]]}; // Little endian: Lower address = Lower byte, even though it reads before in memory
					data_o = {{16{1'b0}}, data[15:0]};
				end
				default : begin
					data_o = 32'b0;
				end	
			endcase
		end
		else begin
			data_o = 32'b0;
		end
	end
		
	always_ff @(posedge clk) begin // Writes must be in always_ff not always_comb
		if (memwrite) begin
			case(funct3)
				3'b000 : begin // SB
					mem_array[eff_addr[16:0]] <= data_i[7:0];
				end
				3'b001 : begin // SH
					mem_array[eff_addr[16:0]] <= data_i[7:0];
					mem_array[eff_addr[16:0]+1] <= data_i[15:8];
				end
				3'b010 : begin // SW
					mem_array[eff_addr[16:0]] <= data_i[7:0];
					mem_array[eff_addr[16:0]+1] <= data_i[15:8];
					mem_array[eff_addr[16:0]+2] <= data_i[23:16];
					mem_array[eff_addr[16:0]+3] <= data_i[31:24];
				end
				default : ; // do nothing
			endcase
		end
	end
endmodule
	
