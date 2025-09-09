module mux_8_1(
    
	 input s,
	 input [7:0]x,
	 input [7:0]y,
	 output[7:0]m
);
    mux_2_1 m0(
    .s(s),
	 .x(x[0]),
	 .y(y[0]),
	 .m(m[0])
    );
	 mux_2_1 m1(
    .s(s),
	 .x(x[1]),
	 .y(y[1]),
	 .m(m[1])
    );
	 mux_2_1 m2(
    .s(s),
	 .x(x[2]),
	 .y(y[2]),
	 .m(m[2])
    );
	 mux_2_1 m3(
    .s(s),
	 .x(x[3]),
	 .y(y[3]),
	 .m(m[3])
    );
	 mux_2_1 m4(
    .s(s),
	 .x(x[4]),
	 .y(y[4]),
	 .m(m[4])
    );
	 mux_2_1 m5(
    .s(s),
	 .x(x[5]),
	 .y(y[5]),
	 .m(LEDR[5])
    );
	 mux_2_1 m6(
    .s(s),
	 .x(x[6]),
	 .y(y[6]),
	 .m(m[6])
    );
	 mux_2_1 m7(
    .s(s),
	 .x(x[7]),
	 .y(y[7]),
	 .m(m[7])
    );
    

endmodule