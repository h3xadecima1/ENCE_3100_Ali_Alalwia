
`default_nettype none

module counter_16bit(
	input i_clk,
	input i_clear,
	output reg [15:0] o_Q
);

	always @(posedge i_clk) begin
		if (i_clear)
			o_Q <= 16'd0;
		else
			o_Q <= o_Q + 16'd1;
	end

endmodule

