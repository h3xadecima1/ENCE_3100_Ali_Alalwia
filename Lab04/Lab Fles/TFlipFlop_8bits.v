module TFlipFlop_8bits(
	input i_enable,
	input i_clk,
	input i_clear,
	output [7:0] o_Q
);

	wire [6:0] w_and;
	
	assign w_and[0] = i_enable & o_Q[0];
	assign w_and[1] = w_and[0] & o_Q[1];
	assign w_and[2] = w_and[1] & o_Q[2];
	assign w_and[3] = w_and[2] & o_Q[3];
	assign w_and[4] = w_and[3] & o_Q[4];
	assign w_and[5] = w_and[4] & o_Q[5];
	assign w_and[6] = w_and[5] & o_Q[6];

	// TFlipFlop_1bit(i_T,i_clk,i_clear,o_Q);
	
	TFlipFlop_1bit TF0 (i_enable, i_clk, i_clear, o_Q[0]);
	TFlipFlop_1bit TF1 (w_and[0], i_clk, i_clear, o_Q[1]);
	TFlipFlop_1bit TF2 (w_and[1], i_clk, i_clear, o_Q[2]);
	TFlipFlop_1bit TF3 (w_and[2], i_clk, i_clear, o_Q[3]);
	TFlipFlop_1bit TF4 (w_and[3], i_clk, i_clear, o_Q[4]);
	TFlipFlop_1bit TF5 (w_and[4], i_clk, i_clear, o_Q[5]);
	TFlipFlop_1bit TF6 (w_and[5], i_clk, i_clear, o_Q[6]);
	TFlipFlop_1bit TF7 (w_and[6], i_clk, i_clear, o_Q[7]);

endmodule

`default_nettype none

