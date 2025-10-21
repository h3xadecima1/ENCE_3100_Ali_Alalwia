module main(
	// Pinout Assignment
	input 				MAX10_CLK1_50,
	input		[9:0]		SW,
	input 	[1:0]		KEY,
	output	[9:0]		LEDR,
	output	[7:0]		HEX0,
	output	[7:0]		HEX1,
	output	[7:0]		HEX2,
	output	[7:0]		HEX3,
	output	[7:0]		HEX4,
	output	[7:0]		HEX5
);

	wire w_clk;
	assign w_clk = MAX10_CLK1_50;

	// CHESS TIMER - STATE MACHINE
	// **************************************************
	
	wire [9:0] w_counter1, w_counter2;
	wire [1:0] w_en_counters;
	wire [1:0] w_load_counters;
	wire [1:0] w_state_displays;
	
	FSM_ChessTimer ChessTimer_Control (
		.clk(w_clk),
		.reset(SW[9]),
		.buttons(SW[1:0]),
		.counter_1(w_counter1),
		.counter_2(w_counter2),
		.load_counters(w_load_counters),
		.en_counters(w_en_counters),
		.state_displays(w_state_displays)
	);
	
	
	// COUNTERS
	// **************************************************
	
	wire w_count;
	
	counter_1s Count_1sec(
		.i_clk(w_clk),
		.i_reset(SW[9]),
		.i_enable(1'b1),
		.o_tick(),
		.o_strobe(w_count)
	);
	
	counter_Nbits Counter_1
	(
		.i_clk(w_count),
		.i_reset(w_load_counters[0]),
		.i_enable(w_en_counters[0]),
		.i_data(10'd5), //10'd999
		.i_dir(1'b0),
		.o_count(w_counter1)
	);
	
	counter_Nbits Counter_2
	(
		.i_clk(w_count),
		.i_reset(w_load_counters[1]),
		.i_enable(w_en_counters[1]),
		.i_data(10'd5), //10'd999
		.i_dir(1'b0),
		.o_count(w_counter2)
	);
	
	// DISPLAY CONTROLLER 
	// **************************************************
	
	display_controller DispTime(
	.counter_1(w_counter1),
	.counter_2(w_counter2),
	.state_displays(w_state_displays),
	.HEX0(HEX0),
	.HEX1(HEX1),
	.HEX2(HEX2),
	.HEX3(HEX3),
	.HEX4(HEX4),
	.HEX5(HEX5)
	);
	
endmodule
