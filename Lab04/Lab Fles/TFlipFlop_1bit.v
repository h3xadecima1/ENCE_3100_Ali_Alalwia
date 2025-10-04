module TFlipFlop_1bit(
	input i_T,
	input i_clk,
	input i_clear,
	output reg o_Q
);

	wire w_D;

	// Combinational Logic
	assign w_D = (o_Q & ~i_T) | (i_T & ~o_Q);
	
	// Sequential Logic
	always @(posedge i_clk) begin
		if(i_clear)
			o_Q <= 1'd0;
		else
			o_Q <= w_D;
	end

endmodule

`default_nettype none

