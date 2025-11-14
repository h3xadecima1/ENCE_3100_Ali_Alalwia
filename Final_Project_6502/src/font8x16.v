// ============================================================
// Project     : 6502 FPGA Processor System
// File        : font8x16.v
// Description : Stores a fixed 8×16 pixel bitmap font
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
//=============================================================

// ============================================================
// 8x16 Monospaced Character Font ROM
// For use with VGA text controllers (80x30 or 40x25 displays)
// Each character = 8 pixels wide × 16 pixels tall
// Input: ASCII code (8-bit) and row (4-bit)
// Output: 8-bit pixel pattern for that row
// ============================================================

`timescale 1ns / 1ps
`default_nettype none

module font8x16 (
    input  wire        clk,         // pixel clock (25 MHz)
    input  wire [7:0]  char_code,   // ASCII code (0x00–0x7F)
    input  wire [3:0]  row,         // which row (0–15) of the character
    output reg  [7:0]  bits         // 8 pixels for this row (MSB = left)
);

    // ROM: 128 characters × 16 rows = 2048 bytes
    reg [7:0] font_rom [0:2047];

    initial begin
        // You can load from an external font file if available:
        // $readmemh("font8x16.hex", font_rom);

        // For demonstration: simple built-in glyphs for common chars.
        // In practice, you’d load a full 8x16 ASCII font (2048 bytes).
        // Space (0x20)
        font_rom[16*8'h20 +  0] = 8'b00000000;
        font_rom[16*8'h20 +  1] = 8'b00000000;
        font_rom[16*8'h20 +  2] = 8'b00000000;
        font_rom[16*8'h20 +  3] = 8'b00000000;
        font_rom[16*8'h20 +  4] = 8'b00000000;
        font_rom[16*8'h20 +  5] = 8'b00000000;
        font_rom[16*8'h20 +  6] = 8'b00000000;
        font_rom[16*8'h20 +  7] = 8'b00000000;
        font_rom[16*8'h20 +  8] = 8'b00000000;
        font_rom[16*8'h20 +  9] = 8'b00000000;
        font_rom[16*8'h20 + 10] = 8'b00000000;
        font_rom[16*8'h20 + 11] = 8'b00000000;
        font_rom[16*8'h20 + 12] = 8'b00000000;
        font_rom[16*8'h20 + 13] = 8'b00000000;
        font_rom[16*8'h20 + 14] = 8'b00000000;
        font_rom[16*8'h20 + 15] = 8'b00000000;

        // Character 'A' (0x41)
        font_rom[16*8'h41 +  0] = 8'b00011000;
        font_rom[16*8'h41 +  1] = 8'b00111100;
        font_rom[16*8'h41 +  2] = 8'b01100110;
        font_rom[16*8'h41 +  3] = 8'b01100110;
        font_rom[16*8'h41 +  4] = 8'b01111110;
        font_rom[16*8'h41 +  5] = 8'b01100110;
        font_rom[16*8'h41 +  6] = 8'b01100110;
        font_rom[16*8'h41 +  7] = 8'b00000000;
        font_rom[16*8'h41 +  8] = 8'b00000000;
        font_rom[16*8'h41 +  9] = 8'b00000000;
        font_rom[16*8'h41 + 10] = 8'b00000000;
        font_rom[16*8'h41 + 11] = 8'b00000000;
        font_rom[16*8'h41 + 12] = 8'b00000000;
        font_rom[16*8'h41 + 13] = 8'b00000000;
        font_rom[16*8'h41 + 14] = 8'b00000000;
        font_rom[16*8'h41 + 15] = 8'b00000000;

        // Character 'B' (0x42)
        font_rom[16*8'h42 +  0] = 8'b01111100;
        font_rom[16*8'h42 +  1] = 8'b01100110;
        font_rom[16*8'h42 +  2] = 8'b01100110;
        font_rom[16*8'h42 +  3] = 8'b01111100;
        font_rom[16*8'h42 +  4] = 8'b01100110;
        font_rom[16*8'h42 +  5] = 8'b01100110;
        font_rom[16*8'h42 +  6] = 8'b01111100;
        font_rom[16*8'h42 +  7] = 8'b00000000;
        font_rom[16*8'h42 +  8] = 8'b00000000;
        font_rom[16*8'h42 +  9] = 8'b00000000;
        font_rom[16*8'h42 + 10] = 8'b00000000;
        font_rom[16*8'h42 + 11] = 8'b00000000;
        font_rom[16*8'h42 + 12] = 8'b00000000;
        font_rom[16*8'h42 + 13] = 8'b00000000;
        font_rom[16*8'h42 + 14] = 8'b00000000;
        font_rom[16*8'h42 + 15] = 8'b00000000;

        // Character 'C' (0x43)
        font_rom[16*8'h43 +  0] = 8'b00111100;
        font_rom[16*8'h43 +  1] = 8'b01100110;
        font_rom[16*8'h43 +  2] = 8'b01100000;
        font_rom[16*8'h43 +  3] = 8'b01100000;
        font_rom[16*8'h43 +  4] = 8'b01100000;
        font_rom[16*8'h43 +  5] = 8'b01100110;
        font_rom[16*8'h43 +  6] = 8'b00111100;
        font_rom[16*8'h43 +  7] = 8'b00000000;
        font_rom[16*8'h43 +  8] = 8'b00000000;
        font_rom[16*8'h43 +  9] = 8'b00000000;
        font_rom[16*8'h43 + 10] = 8'b00000000;
        font_rom[16*8'h43 + 11] = 8'b00000000;
        font_rom[16*8'h43 + 12] = 8'b00000000;
        font_rom[16*8'h43 + 13] = 8'b00000000;
        font_rom[16*8'h43 + 14] = 8'b00000000;
        font_rom[16*8'h43 + 15] = 8'b00000000;
    end

    always @(posedge clk)
        bits <= font_rom[{char_code, row}];

endmodule

`default_nettype wire
