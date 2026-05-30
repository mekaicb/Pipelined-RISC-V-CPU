module VGA_controller(
	input logic clk, rst_n,
	output logic [9:0] x, y,
	output logic h_sync, v_sync,
	output logic video_on
	);
	
	logic x_end, y_end, y_enable;
	
	localparam
		H_ACTIVE = 640,
		HF_PORCH = 16,
		HB_PORCH = 48,
		H_SYNC = 96,
		H_MAX = H_ACTIVE + HF_PORCH + HB_PORCH + H_SYNC - 1, // 799
		
		V_ACTIVE = 480,
		VF_PORCH = 10,
		VB_PORCH = 33,
		V_SYNC = 2,
		V_MAX = V_ACTIVE + VF_PORCH + VB_PORCH + V_SYNC - 1; // 524
		
	assign x_end = (x == H_MAX);
	assign y_end = (y == V_MAX);
	assign y_enable = x_end;
	
	always_ff @(posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			x <= 10'b0;
			y <= 10'b0;
		end 
		else begin
			x <= x_end ? 10'b0 : (x + 1'b1);
			
			if(y_enable) begin
				y <= y_end ? 10'b0 : (y + 1'b1);
			end
		end		
	end
	
	always_comb begin
		h_sync = 1'b1; // Avoid latches
		v_sync = 1'b1;
		video_on = 1'b0;
		
		if(x >= (H_ACTIVE + HF_PORCH) && x < (H_ACTIVE + HF_PORCH + H_SYNC)) begin // If x counter is within 96 pixel sync window, reset counter to 0
			h_sync = 1'b0; // Active low
		end
		if(y >= (V_ACTIVE + VF_PORCH) && y < (V_ACTIVE + VF_PORCH + V_SYNC)) begin
			v_sync = 1'b0;
		end
		if((x < H_ACTIVE) && (y < V_ACTIVE)) begin
			video_on = 1'b1;
		end
	end

endmodule