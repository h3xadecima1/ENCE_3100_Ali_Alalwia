`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : clock_divider.v
// Description : Debug clock divider
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

// ================================================================
// clock_divider.v – Generate slower visible clock from 50 MHz input
// ================================================================
module clock_divider #(
    parameter DIVIDER = 25_000_000  // default ~2 Hz (for visible updates)
)(
    input  wire clk_in,
    output reg  clk_out = 0
);

    reg [31:0] count = 0;

    always @(posedge clk_in) begin
        if (count >= DIVIDER) begin
            count   <= 0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1;
        end
    end
endmodule
`default_nettype wire
