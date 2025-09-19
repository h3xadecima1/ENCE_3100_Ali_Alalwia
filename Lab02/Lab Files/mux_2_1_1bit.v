
`default_nettype none

module mux_2_1_1bit(
	input 	i_a,
	input 	i_b,
	input 	i_sel,
	output 	o_m
);

	assign o_m = (~i_sel & i_a) | (i_sel & i_b);

endmodule
