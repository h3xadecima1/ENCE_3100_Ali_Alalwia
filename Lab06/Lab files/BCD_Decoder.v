
`default_nettype none

module BCD_Decoder(
	input 		[3:0] i_bin,
	output reg	[6:0] o_HEX
);

	// combinational logic
	always @(*) begin
	
		o_HEX = 7'b1111111;  // default
	
		case(i_bin)
			4'd0: o_HEX = 7'b1000000;
			4'd1: o_HEX = 7'b1111001;
			4'd2: o_HEX = 7'b0100100;
			4'd3: o_HEX = 7'b0110000;
			4'd4: o_HEX = 7'b0011001;
			4'd5: o_HEX = 7'b0010010;
			4'd6: o_HEX = 7'b0000010;
			4'd7: o_HEX = 7'b1111000;
			4'd8: o_HEX = 7'b0000000;
			4'd9: o_HEX = 7'b0011000;
		endcase
	end

endmodule

`default_nettype wire
