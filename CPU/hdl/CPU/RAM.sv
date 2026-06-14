module RAM(
	input logic memwrite, memread, clk,
	input logic [31:0] addr_in, // Only 13 bits are required to reach all addresses from 0 to 0x000A000+3840 words
	input logic [31:0] data_i,
	input logic [2:0] funct3,
	output logic [31:0] data_o
	);
	
	logic [2:0] byte_en, byte_en_r; // Selects which byte of the word to load from memory, or store to memory
	logic [1:0] byte_sel, byte_sel_r;
	logic [31:0] data_temp;
	
	logic [31:0] eff_addr;
	(* ramstyle = "M9K" *) logic [31:0] mem_array[0:3839]; // Word addressible 15kB RAM. (15kB = 3840 words = 15360 bytes)
	
	localparam offset = 32'h0000A000; // Start at 5kB
	
	assign eff_addr = (addr_in - offset);
	assign byte_sel = eff_addr[1:0]; // Assign byte enable to the lower two bits of the address input
	
	always_comb begin
		case(funct3)
			3'b000 : byte_en = 3'b000; // LB/SB, select byte 0
			3'b001 : byte_en = 3'b001; // LH/SH, select byte 0+1
			3'b010 : byte_en = 3'b010; // LW/SW, select full word
			3'b100 : byte_en = 3'b011; // LBU, select byte 0 & zero extend
			3'b101 : byte_en = 3'b100; // LHU, select byte 0 & zero extend
			default : byte_en = 3'b010;
		endcase
	end
	
		always_ff @(posedge clk) begin // Synchronous read
		if(memread) begin 
			data_temp <= mem_array[eff_addr[14:2]]; // Simple read 
			byte_sel_r <= byte_sel; // prevent being overwritten on the next cycle
			byte_en_r <= byte_en;
 		end
		if(memwrite) begin // Write can be complicated
			case(byte_en)
				3'b000 : begin
					case(byte_sel)
						2'b00 : mem_array[eff_addr[14:2]][7:0] <= data_i[7:0];
						2'b01 : mem_array[eff_addr[14:2]][15:8] <= data_i[7:0];
						2'b10 : mem_array[eff_addr[14:2]][23:16] <= data_i[7:0];
						2'b11 : mem_array[eff_addr[14:2]][31:24] <= data_i[7:0];
					endcase
				end
				3'b001 : begin
					case(byte_sel)
						2'b00 : mem_array[eff_addr[14:2]][15:0] <= data_i[15:0];
						2'b10 : mem_array[eff_addr[14:2]][31:16] <= data_i[15:0];
					endcase
				end
				3'b010 : begin
					mem_array[eff_addr[14:2]] <= data_i;
				end
				default : mem_array[eff_addr[14:2]] <= data_i;
			endcase
		end	
	end
	
	always_comb begin // Handles the slicing and extension of the word read from memory
		case(byte_en_r)
			3'b000 : begin // LB - Sign extend
				case(byte_sel_r)
					2'b00 : data_o = {{24{data_temp[7]}},  data_temp[7:0]};
					2'b01 : data_o = {{24{data_temp[15]}}, data_temp[15:8]};
					2'b10 : data_o = {{24{data_temp[23]}}, data_temp[23:16]};
					2'b11 : data_o = {{24{data_temp[31]}}, data_temp[31:24]};
				endcase
			end
			3'b001 : begin // LH - Sign extend
				case(byte_sel_r) // Which two bytes to select specifically
					2'b00 : data_o = {{16{data_temp[15]}}, data_temp[15:0]};
					2'b10 : data_o = {{16{data_temp[31]}}, data_temp[31:16]};
					default : data_o = {{16{data_temp[15]}}, data_temp[15:0]};
				endcase
			end
			3'b010 : begin
				data_o = data_temp; // LW
			end
			3'b011 : begin // LBU - Zero extend
				case(byte_sel_r) 
					2'b00 : data_o = {24'b0, data_temp[7:0]}; // Sign extend the byte to 32 bits
					2'b01 : data_o = {24'b0, data_temp[15:8]}; // Select the 2nd byte, place as lowest byte and zero extend to 32 bits
					2'b10 : data_o = {24'b0, data_temp[23:16]};
					2'b11 : data_o = {24'b0, data_temp[31:24]};
				endcase
			end
			3'b100 : begin // LHU - Zero extend
				case(byte_sel_r)
					2'b00 : data_o = {16'b0, data_temp[15:0]}; // Sign extend the halfword to 32 bits
					2'b10 : data_o = {16'b0, data_temp[31:16]}; // Select the 2nd halfword, zero extend to 32 bits
					default : data_o = {16'b0, data_temp[15:0]};
				endcase
			end
			default : data_o = data_temp; // default read the full word
			
		endcase
	end
endmodule
	
	
/*
	- [13:2] because we are assuming word aligned address inputs (also log2(3840) = 11.9 address bits)
	- Assuming the lowest two bits refer to the byte address
	
	- Ported ram can only do something simple like output <= input[addr]
		- Something like output <= input[addr][7:0] becomes too complicated due to the slicing, and synthesizer infers flip flops rather than ram
		- Solution is to do the slicing and extension asynchronously in a seperate block
*/

