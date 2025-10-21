module display_controller(
	input	[9:0] counter_1,
	input	[9:0] counter_2,
	input [1:0] state_displays,
	output reg [7:0] HEX0,
	output reg [7:0] HEX1,
	output reg [7:0] HEX2,
	output reg [7:0] HEX3,
	output reg [7:0] HEX4,
	output reg [7:0] HEX5
);

	wire [7:0] w_HEX0, w_HEX1, w_HEX2, w_HEX3, w_HEX4, w_HEX5;

	// BIN to BCD Converter and Seg7 Decoder MODULES
	// **************************************************
	
	always @(*) begin
	
		HEX0 = 8'hFF;
		HEX1 = 8'hFF;
		HEX2 = 8'hFF;
		HEX3 = 8'hFF;
		HEX4 = 8'hFF;
		HEX5 = 8'hFF;
	
		case(state_displays)
		
			2'b00: begin
				HEX0 = 8'b11000000; // O
				HEX1 = 8'b10000010; // G
				HEX2 = 8'hFF;
				HEX3 = 8'hFF;
				HEX4 = 8'hFF;
				HEX5 = 8'hFF;
			end
			
			2'b01: begin
				HEX0 = w_HEX0;
				HEX1 = w_HEX1;
				HEX2 = w_HEX2;
				HEX3 = w_HEX3;
				HEX4 = w_HEX4;
				HEX5 = w_HEX5;
				
				HEX0[7] = 1'b1;
				HEX1[7] = 1'b1;
				HEX2[7] = 1'b1;
				HEX3[7] = 1'b0;
				HEX4[7] = 1'b1;
				HEX5[7] = 1'b1;
			end
			
			2'b10: begin
				HEX1 = 8'b10001100;  // P
				HEX2 = 8'b10000110;  // E
				HEX3 = 8'b10101011;  // n
				HEX4 = 8'b11000000;  // O
				HEX5 = 8'b10100001;  // d
				
				if(counter_1 == 10'd0)
					HEX0 = 8'b10100100;  // 2
				else
					HEX0 = 8'b11111001;  // 1
			end
			
		endcase
	
	end
	
	wire [3:0] w_ones1, w_tens1, w_hundreds1;
	wire [3:0] w_ones2, w_tens2, w_hundreds2;
	
	bin10_to_bcd3 bin2BCD_1 (
    .bin(counter_1),         // 0..1023
    .hundreds(w_hundreds1),
    .tens(w_tens1),
    .ones(w_ones1),
    .overflow()
	);
	 
	BCD_Decoder Seg7_0(
		.i_bin(w_ones1),
		.o_HEX(w_HEX0)
	);
	
	BCD_Decoder Seg7_1(
		.i_bin(w_tens1),
		.o_HEX(w_HEX1)
	);
	
	BCD_Decoder Seg7_2(
		.i_bin(w_hundreds1),
		.o_HEX(w_HEX2)
	);
	
	bin10_to_bcd3 bin2BCD_2 (
    .bin(counter_2),         // 0..1023
    .hundreds(w_hundreds2),
    .tens(w_tens2),
    .ones(w_ones2),
    .overflow()
	 );
	 
	BCD_Decoder Seg7_3(
		.i_bin(w_ones2),
		.o_HEX(w_HEX3)
	);
	
	BCD_Decoder Seg7_4(
		.i_bin(w_tens2),
		.o_HEX(w_HEX4)
	);
	
	BCD_Decoder Seg7_5(
		.i_bin(w_hundreds2),
		.o_HEX(w_HEX5)
	);

endmodule
