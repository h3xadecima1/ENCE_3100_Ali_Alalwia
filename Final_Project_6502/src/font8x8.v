`timescale 1ns/1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : font8x8.v
// Description : Stores a fixed 8×8 pixel bitmap font
//
// Author      : Ali G
// Created On  : 11-13-2025
// Version     : 1.0
// Target      : Intel MAX 10 / DE10-Lite FPGA
//
// License:
//   This source code is provided for educational and research
//   purposes only. Redistribution and modification are permitted
//   provided that proper credit is given to the original author.
//
// ============================================================

module font8x8(
    input  wire [7:0] char_code,
    input  wire [2:0] row,
    output reg  [7:0] pixels
);
    always @(*) begin
        case (char_code)
            "A": case(row)
                0: pixels=8'b00011000;
                1: pixels=8'b00111100;
                2: pixels=8'b01100110;
                3: pixels=8'b01111110;
                4: pixels=8'b01100110;
                5: pixels=8'b01100110;
                6: pixels=8'b00000000;
                default: pixels=0; endcase
            " ": pixels = 8'b00000000;
            default: pixels = 8'b00000000;
        endcase
    end
endmodule
`default_nettype wire
