module barrel_shift(
	input logic [31:0] data,
	input logic [4:0] shift,
	input logic [1:0] shift_type,
	output logic [31:0] out
	);
	
	logic [31:0] s0_ll, s1_ll, s2_ll, s3_ll, s4_ll; // Vars for logical left shift
	logic [31:0] s0_lr, s1_lr, s2_lr, s3_lr, s4_lr; // Vars for logical right shift
	logic [31:0] s0_ar, s1_ar, s2_ar, s3_ar, s4_ar; // Vars for arithmetic right shift
	
	logic sign;
	
	assign sign = data[31];
	
	// Logical Left
	mux1_2to1 stage0_ll [31:0] (.in1({data[15:0], 16'b0}), .in2(data[31:0]), .sel(shift[4]), .out(s0_ll));
	mux1_2to1 stage1_ll [31:0] (.in1({s0_ll[23:0], 8'b0}), .in2(s0_ll), .sel(shift[3]), .out(s1_ll));
	mux1_2to1 stage2_ll [31:0] (.in1({s1_ll[27:0], 4'b0}), .in2(s1_ll), .sel(shift[2]), .out(s2_ll));
	mux1_2to1 stage3_ll [31:0] (.in1({s2_ll[29:0], 2'b0}), .in2(s2_ll), .sel(shift[1]), .out(s3_ll));
	mux1_2to1 stage4_ll [31:0] (.in1({s3_ll[30:0], 1'b0}), .in2(s3_ll), .sel(shift[0]), .out(s4_ll));
	
	// Logical Right
	mux1_2to1 stage0_lr [31:0] (.in1({16'b0, data[31:16]}), .in2(data), .sel(shift[4]), .out(s0_lr));
	mux1_2to1 stage1_lr [31:0] (.in1({8'b0, s0_lr[31:8]}), .in2(s0_lr), .sel(shift[3]), .out(s1_lr));
	mux1_2to1 stage2_lr [31:0] (.in1({4'b0, s1_lr[31:4]}), .in2(s1_lr), .sel(shift[2]), .out(s2_lr));
	mux1_2to1 stage3_lr [31:0] (.in1({2'b0, s2_lr[31:2]}), .in2(s2_lr), .sel(shift[1]), .out(s3_lr));
	mux1_2to1 stage4_lr [31:0] (.in1({1'b0, s3_lr[31:1]}), .in2(s3_lr), .sel(shift[0]), .out(s4_lr));
	
	// Arithmetic Right
	mux1_2to1 stage0_ar [31:0] (.in1({{16{sign}}, data[31:16]}), .in2(data), .sel(shift[4]), .out(s0_ar));
	mux1_2to1 stage1_ar [31:0] (.in1({{8{sign}}, s0_ar[31:8]}), .in2(s0_ar), .sel(shift[3]), .out(s1_ar));
	mux1_2to1 stage2_ar [31:0] (.in1({{4{sign}}, s1_ar[31:4]}), .in2(s1_ar), .sel(shift[2]), .out(s2_ar));
	mux1_2to1 stage3_ar [31:0] (.in1({{2{sign}}, s2_ar[31:2]}), .in2(s2_ar), .sel(shift[1]), .out(s3_ar));
	mux1_2to1 stage4_ar [31:0] (.in1({{1{sign}}, s3_ar[31:1]}), .in2(s3_ar), .sel(shift[0]), .out(s4_ar));
	
	always_comb begin
		case(shift_type)
			2'b00 : out = s4_ll;
			2'b01 : out = s4_lr;
			2'b10 : out = s4_ar;
			default : out = 32'b0;
		endcase
	end
endmodule