module accumulator_sub_8bit(
	input 	[7:0] i_A,
	input				i_addsub, // 1 - sub / 0 - add
	input 			i_clk,
	input				i_rst,
	output 			o_overflow,
	output 	[7:0] o_S
);


	
   wire [7:0] w_A;
	wire  w_overflow;
	wire [7:0] w_S;
	

	// 8bit Register
	reg_nbit #(.N(8)) REG_A(
	.i_R(i_A),
	.i_clk(i_clk),
	.i_rst(i_rst),
	.o_Q(w_A)
);

	// 8bit ALU
	assign {w_overflow, w_S}  = (i_addsub == 1'b0) ? (o_S - w_A) : (w_A + o_S);
	

	// 1bit Register
	reg_nbit #(.N(1)) REG_O(
	.i_R(w_overflow),
	.i_clk(i_clk),
	.i_rst(i_rst),
	.o_Q(o_overflow)
);
	
	// 8bit Register
	reg_nbit #(.N(8)) REG_S(
	.i_R(w_S),
	.i_clk(i_clk),
	.i_rst(i_rst),
	.o_Q(o_S)
);
	
endmodule