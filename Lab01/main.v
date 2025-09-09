module main(
    //pinout assignment
	 input   [9:0] SW,
	 output  [9:0] LEDR
);
	 //assign LEDR = SW;
	 
	 mux_2_1 m0(
    .s(SW[9]),
	 .x(SW[3:0]),
	 .y(SW[7:4]),
	 .m(LEDR[0])
    );
endmodule