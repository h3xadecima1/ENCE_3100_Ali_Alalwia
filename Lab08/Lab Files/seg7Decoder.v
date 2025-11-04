`timescale 1ns / 1ps
`default_nettype none

module seg7Decoder(
    input  wire [3:0] i_bin,   // <- input only, never inout
    output reg  [7:0] o_HEX
);

    always @(*) begin
        case (i_bin)
            4'h0: o_HEX = 8'b1100_0000; // 0
            4'h1: o_HEX = 8'b1111_1001; // 1
            4'h2: o_HEX = 8'b1010_0100; // 2
            4'h3: o_HEX = 8'b1011_0000; // 3
            4'h4: o_HEX = 8'b1001_1001; // 4
            4'h5: o_HEX = 8'b1001_0010; // 5
            4'h6: o_HEX = 8'b1000_0010; // 6
            4'h7: o_HEX = 8'b1111_1000; // 7
            4'h8: o_HEX = 8'b1000_0000; // 8
            4'h9: o_HEX = 8'b1001_0000; // 9
            4'hA: o_HEX = 8'b1000_1000; // A
            4'hB: o_HEX = 8'b1000_0011; // b
            4'hC: o_HEX = 8'b1100_0110; // C
            4'hD: o_HEX = 8'b1010_0001; // d
            4'hE: o_HEX = 8'b1000_0110; // E
            4'hF: o_HEX = 8'b1000_1110; // F
            default: o_HEX = 8'b1111_1111; // blank
        endcase
    end

endmodule

`default_nettype wire
