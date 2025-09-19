
`default_nettype none

module FA(
	input 	i_a,
	input 	i_b,
	input 	i_cin,
	output 	o_cout,
	output 	o_s
);

	// Combinational Logic only
	assign o_s = ~i_cin&~i_a&i_b|~i_cin&i_a&~i_b|i_cin&~i_a&~i_b|i_cin&i_a&i_b;
	assign o_cout = i_a&i_b|i_cin&i_b|i_cin&i_a;

endmodule
