module adder_nbit #
(
	parameter N = 8 // default width
)
(
	input 	[N-1:0] 	i_A,
	input 	[N-1:0] 	i_B,
	input 				i_cin,
	output	[N-1:0]	o_sum,
	output 				o_cout
);

	assign {o_cout, o_sum} = i_A + i_B + i_cin;

endmodule
