`timescale 1ns/1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : stack_unit.v
// Description : Stack pointer + push/pull logic
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

module stack_unit (
    input  wire       clk,
    input  wire       reset_n,
    input  wire [7:0] SP_in,
    input  wire       push,
    input  wire       pull,
    input  wire       inc_SP,
    input  wire       dec_SP,
    output reg  [7:0] SP_out
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            SP_out <= 8'hFD;  // default reset value for 6502
        else begin
            if (dec_SP)
                SP_out <= SP_in - 8'd1;
            else if (inc_SP)
                SP_out <= SP_in + 8'd1;
            else
                SP_out <= SP_in;
        end
    end

endmodule

`default_nettype wire
