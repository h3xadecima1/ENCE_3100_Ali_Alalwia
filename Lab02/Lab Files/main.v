
`default_nettype none

module main(
	input 	[9:0] 	SW,
	input             CLOCK_50,
	output 	[9:0] 	LEDR,
	output	[7:0]		HEX0,
	output	[7:0]		HEX1,
	output	[7:0]		HEX2,
	output   [7:0]    HEX3,
	output   [7:0]    HEX4,
	output   [7:0]    HEX5
);

	// Part I
	//******************
	
	//seg7_dec sg0(SW[3], SW[2], SW[1], SW[0], HEX0);
	
	
	//******************
	
	
	// Part II
	//******************
	
	/*
	wire w_z;
	wire [3:0] w_m;
	wire [3:0] w_a;
	
	// comparator (i_v3, i_v2, i_v1, i_v0, o_z)
	comparator comp0 (SW[3], SW[2], SW[1], SW[0], w_z);
	
	//circuit_A (i_v2, i_v1, i_v0, o_a0, o_a1, o_a2)
	circuit_A circA (SW[2], SW[1], SW[0], w_a[0], w_a[1], w_a[2]);
	
	// circuit_B (i_z, o_seg[7:0])
	circuit_B circB(w_z, HEX1);
	
	// mux_2_1_1bit (i_a, i_b, i_sel, o_m)
	mux_2_1_1bit mux3 (SW[3], 0, w_z, w_m[3]);
	mux_2_1_1bit mux2 (SW[2], w_a[2], w_z, w_m[2]);
	mux_2_1_1bit mux1 (SW[1], w_a[1], w_z, w_m[1]);
	mux_2_1_1bit mux0 (SW[0], w_a[0], w_z, w_m[0]);

	// seg7_dec (i_m3, i_m2, i_m1, i_m0, o_seg[7:0])
	seg7_dec seg0 (w_m[3], w_m[2], w_m[1], w_m[0], HEX0);
	
	// bin_to_dec b2d(SW[3], SW[2], SW[1], SW[0], HEX0, HEX1); // test part 2 as a module
	
	*/
	
	//******************
	
	// Part III
	//******************
	
	/*
	//FA fa0 (SW[0], SW[1], SW[2], LEDR[1], LEDR[0]);  // test FA first
	
	//adder_4bit ([3:0]i_a, [3:0]i_b, i_cin, o_cout, [3:0]o_s)
	adder_4bit ad0 (SW[3:0], SW[7:4], SW[8], LEDR[4], LEDR[3:0]);
	*/
	
	//******************
	
	// Part IV
	//******************
	
	/*
	wire [3:0] w_s;
   wire w_cout;

   // adder_4bit ([3:0]i_a, [3:0]i_b, i_cin, o_cout, [3:0]o_s)
   adder_4bit add0 (SW[3:0], SW[7:4], SW[8], w_cout, w_s);

   // Display SW[3:0] on HEX0–HEX1
   bin_to_dec_v2 bin2dec_sw0 (SW[3], SW[2], SW[1], SW[0],1'b0,HEX0, HEX1);

   // Display SW[7:4] on HEX2–HEX3
   bin_to_dec_v2 bin2dec_sw1 (SW[7], SW[6], SW[5], SW[4],1'b0,HEX2, HEX3);
 
   // Display adder result (w_s + carry) on HEX4–HEX5
   bin_to_dec_v2 bin2dec_sum (w_s[3], w_s[2], w_s[1], w_s[0],w_cout,HEX4, HEX5);

   // Error check
   checkBCD cb0 (SW[3:0], SW[7:4], LEDR[9]);
	*/
	
	//******************
	
	// Part V
	//******************
	
	// TODO
	
	//******************
	
	// Part VI
	//******************
	
	// TODO
	/*
    reg [3:0] A0 = 0, A1 = 0;
    reg [3:0] B0 = 0, B1 = 0;

    // Update selected bank continuously
    always @(posedge CLOCK_50) begin
        if (SW[9] == 1'b0) begin
            A0 <= SW[3:0];
            B0 <= SW[7:4];
        end else begin
            A1 <= SW[3:0];
            B1 <= SW[7:4];
        end
    end

    // ------------------------------------------------------------
    // Two-digit adder (pseudo-code style)
    // ------------------------------------------------------------
    wire [3:0] S0, S1;
    wire       S2;

    bcd_add2_if adder (
        .A0(A0), .A1(A1),
        .B0(B0), .B1(B1),
        .S0(S0), .S1(S1), .S2(S2)
    );

    // ------------------------------------------------------------
    // Display mapping
    // ------------------------------------------------------------
    hex7seg d0 (.val(A0), .seg(HEX0)); // A0
    hex7seg d1 (.val(A1), .seg(HEX1)); // A1
    hex7seg d2 (.val(B0), .seg(HEX2)); // B0
    hex7seg d3 (.val(B1), .seg(HEX3)); // B1
    hex7seg d4 (.val(S0), .seg(HEX4)); // S0
    hex7seg d5 (.val(S1), .seg(HEX5)); // S1

    assign LEDR[9]   = S2;   // hundreds carry
    assign LEDR[8:0] = 9'b0;

	//******************
	*/
	// Part VII (Mandatory for Graduate Students)
	//******************
	
	// TODO
	
	//******************

endmodule
