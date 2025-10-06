module main(
	input 				MAX10_CLK1_50,
	input 	[9:0] 	SW,
	input 	[1:0]		KEY,
	output 	[9:0] 	LEDR,
	output	[7:0]		HEX0,
	output	[7:0]		HEX1,
	output	[7:0]		HEX2,
	output	[7:0]		HEX3,
	output	[7:0]		HEX4,
	output	[7:0]		HEX5
);

	// Part I
	//******************
	/*
	wire w_clk;
	
	// counter_1s (Clock, Resetn, led_out);
	counter_1s C0 (MAX10_CLK1_50, SW[8], w_clk);
	
	wire [7:0] w_Q;
	
	TFlipFlop_8bits counter8bit (SW[1], w_clk, SW[9], w_Q);
		
	// seg7Decoder([3:0]i_bin, [7:0]o_HEX);
	seg7Decoder Ones(w_Q[3:0], HEX0);
	seg7Decoder Tens(w_Q[7:4], HEX1);
	*/
	
	//******************
	
	// Part II
	//******************

	/*
	wire w_clk;
	
	// counter_1s (Clock, Resetn, led_out);
	counter_1s C0 (MAX10_CLK1_50, SW[8], w_clk);
	
	wire [7:0] w_Q;
	
	// counter_16bit(i_clk,i_clear,[15:0] o_Q);
	counter_16bit(w_clk, SW[9], w_Q);
		
	// seg7Decoder([3:0]i_bin, [7:0]o_HEX);
	seg7Decoder Ones(w_Q[3:0], HEX0);
	seg7Decoder Tens(w_Q[7:4], HEX1);
	*/
	
	//******************
	
	// Part III
	//******************	
	/*
	
	wire w_clk;
	
	// counter_1s (Clock, Resetn, led_out);
	counter_1s C0 (MAX10_CLK1_50, SW[8], w_clk);
	
	wire [7:0] w_Q;
	
	//TFlipFlop_8bits counter8bit (SW[1], w_clk, SW[9], w_Q);
	
	// Counter_LPM (clk_en, clock, sclr, [7:0]q);
	Counter_LPM CLPM (SW[0], w_clk, SW[9], w_Q);
		
	// seg7Decoder([3:0]i_bin, [7:0]o_HEX);
	seg7Decoder Ones(w_Q[3:0], HEX0);
	seg7Decoder Tens(w_Q[7:4], HEX1);
	*/
		
	//******************
	
	// Part IV
	//******************
  /* 
  wire rst_n = KEY[0];

  // 1 Hz tick generator
  reg [25:0] cnt;
  reg tick;
  always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
    if (!rst_n) begin
      cnt  <= 0;
      tick <= 0;
    end else if (cnt == 50_000_000-1) begin
      cnt  <= 0;
      tick <= 1;
    end else begin
      cnt  <= cnt + 1;
      tick <= 0;
    end
  end

  // digit counter 0–9
  reg [3:0] digit;
  always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
    if (!rst_n)
      digit <= 0;
    else if (tick)
      digit <= (digit == 9) ? 0 : digit + 1;
  end

  // display on HEX0
  seg7Decoder h0(.i_bin(digit), .o_HEX(HEX0));
  */

	//******************
	
	// Part V
	//******************
	/*
	wire rst_n = KEY[0];
   wire tick;
   tick_1hz u_tick(.clk(MAX10_CLK1_50), .rst_n(rst_n), .tick(tick));

   // HELLO as codes: H=0, E=1, L=2, L=2, O=3
   reg [2:0] msg [0:4];
   initial begin
     msg[0]=3'd0; msg[1]=3'd1; msg[2]=3'd2; msg[3]=3'd2; msg[4]=3'd3;
   end

   reg [2:0] i;  // 0..4, index of left character in the window
   always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
    if (!rst_n) i <= 3'd0;
    else if (tick) i <= (i==3'd4) ? 3'd0 : i + 3'd1;
   end

   wire [2:0] left  = msg[i];
   wire [2:0] right = msg[(i==3'd4)? 3'd0 : i+3'd1];

   seg7_letter L (.code(left),  .HEX(HEX1));
   seg7_letter R (.code(right), .HEX(HEX0));
	*/
	//******************

endmodule

`default_nettype none