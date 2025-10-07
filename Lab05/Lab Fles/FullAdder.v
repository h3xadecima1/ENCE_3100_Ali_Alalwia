
`default_nettype none

module FullAdder(
	input i_a,
	input i_b,
	input i_cin,
	output o_sum,
	output o_cout
);

	// Logic equations
    assign o_sum  = i_a ^ i_b ^ i_cin;                 		// XOR for sum
    assign o_cout = (i_a & i_b) | (i_a & i_cin) | (i_b & i_cin); // carry propagate

endmodule

`default_nettype wire
