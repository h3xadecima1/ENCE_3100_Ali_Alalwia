
`default_nettype none

module comparator(
	input 	i_v3,
	input 	i_v2,
	input 	i_v1,
	input 	i_v0,
	output 	o_z
);

	// Combinational Logic only
	assign o_z = i_v3&i_v2|i_v1&i_v3;

endmodule

