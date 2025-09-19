
`default_nettype none

module seg7_dec(
	input 			i_m3,
	input 			i_m2,
	input 			i_m1,
	input 			i_m0,
	output [7:0]	o_seg
);

	// Combinational Logic only
	assign o_seg[0] = ~i_m3&~i_m2&~i_m1&i_m0|i_m2&~i_m1&~i_m0;
	assign o_seg[1] =  (i_m2 & ~i_m1 & i_m0) | (i_m2 & i_m1 & ~i_m0);
	assign o_seg[2] = ~i_m2&i_m1&~i_m0;
	assign o_seg[3] = ~i_m3&~i_m2&~i_m1&i_m0|i_m2&~i_m1&~i_m0|i_m2&i_m1&i_m0;
	assign o_seg[4] =  i_m0|i_m2&~i_m1;
	assign o_seg[5] = ~i_m3&~i_m2&i_m0|~i_m2&i_m1|i_m1&i_m0;
	assign o_seg[6] = ~i_m3&~i_m2&~i_m1|i_m2&i_m1&i_m0;
	assign o_seg[7] = 1;

endmodule
