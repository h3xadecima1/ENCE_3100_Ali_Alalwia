
`default_nettype none

module counter_1s(
	input		i_clk,
	input 	i_reset,
	input 	i_enable,
	output	reg o_tick,
	output	reg o_strobe
);

	// Counter Template
	parameter DIVISOR = 50000000;  // 1 s
	reg [25:0] counter;  // 2^26 = 65,536 > 50,000

	always @(posedge i_clk)
		if(i_reset) begin
			counter <= 0;
			o_tick <= 0;
		end 
		else begin
		
			if(i_enable) begin		
				// Comparator
				if(counter == DIVISOR - 1) begin
					counter <= 0;
					o_tick <= ~o_tick;  // toggle LED
					o_strobe <= 1'b1;
				end 
				else begin
					counter <= counter + 1;
					o_strobe <= 1'b0;
				end
			end
		end

endmodule

`default_nettype wire
