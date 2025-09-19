
`default_nettype none

module circuit_B(
	input 				i_z,
	output	[7:0]		o_seg
);
	
	// Combinational Logic only
	assign o_seg[0] = i_z;
	assign o_seg[1] = 0;
	assign o_seg[2] = 0;
	assign o_seg[3] = i_z;
	assign o_seg[4] = i_z;
	assign o_seg[5] = i_z;
	assign o_seg[6] = 1;

endmodule
