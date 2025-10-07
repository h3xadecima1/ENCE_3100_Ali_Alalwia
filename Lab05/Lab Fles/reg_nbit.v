module reg_nbit #
(
	parameter N = 8 // default width
)
(
	input 		[N-1:0] 	i_R,
	input 					i_clk,
	input						i_rst,
	output reg	[N-1:0]	o_Q
);

	//TODO
	always@(posedge i_clk)
	begin
		if (i_rst)
		o_Q <= {N{1'b0}};
		else
		o_Q <= i_R;
	end

endmodule
