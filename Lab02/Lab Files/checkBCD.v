
`default_nettype none

module checkBCD(
	input  [3:0] i_a,
	input  [3:0] i_b,
	output o_error
);

	// Combinational Logic only
	assign o_error = i_a[3]&i_a[2]|i_a[1]&i_a[3]|i_b[3]&i_b[2]|i_b[1]&i_b[3];
	
endmodule
