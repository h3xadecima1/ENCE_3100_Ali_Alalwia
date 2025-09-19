
`default_nettype none

module bin_to_dec(
	input 			i_v3,
	input 			i_v2,
	input 			i_v1,
	input 			i_v0,
	output [7:0] 	o_seg0,
	output [7:0] 	o_seg1
);

	wire w_z;
	wire [3:0] w_m;
	wire [3:0] w_a;
	
	// comparator (i_v3, i_v2, i_v1, i_v0, o_z)
	comparator comp0 (i_v3, i_v2, i_v1, i_v0, w_z);
	
	//circuit_A (i_v2, i_v1, i_v0, o_a0, o_a1, o_a2)
	circuit_A circA (i_v2, i_v1, i_v0, w_a[0], w_a[1], w_a[2]);
	
	// circuit_B (i_z, o_seg[7:0])
	circuit_B circB(w_z, o_seg1);
	
	// mux_2_1_1bit (i_a, i_b, i_sel, o_m)
	mux_2_1_1bit mux3 (i_v3, 0, w_z, w_m[3]);
	mux_2_1_1bit mux2 (i_v2, w_a[2], w_z, w_m[2]);
	mux_2_1_1bit mux1 (i_v1, w_a[1], w_z, w_m[1]);
	mux_2_1_1bit mux0 (i_v0, w_a[0], w_z, w_m[0]);

	// seg7_dec (i_m3, i_m2, i_m1, i_m0, o_seg[7:0])
	seg7_dec seg0 (w_m[3], w_m[2], w_m[1], w_m[0], o_seg0);

endmodule
