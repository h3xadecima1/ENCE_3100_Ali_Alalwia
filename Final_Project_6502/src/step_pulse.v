`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : step_pulse.v
// Description : Step clock generator
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
// step_pulse.v – Debounced one-shot pulse on button press
// ================================================================
module step_pulse (
    input  wire clk_in,       // 50 MHz clock
    input  wire btn,          // raw push-button
    output reg  pulse_out = 0 // single pulse
);
    reg [2:0] sync = 3'b111;
    reg [19:0] debounce = 0;
    reg btn_state = 1'b1;
    reg btn_prev  = 1'b1;

    always @(posedge clk_in) begin
        // Synchronize to clock
        sync <= {sync[1:0], btn};

        // Debounce: 20-bit counter ≈ 20 ms
        if (sync[2] != btn_state) begin
            debounce <= debounce + 1;
            if (debounce == 20'd1_000_000) begin
                btn_state <= sync[2];
                debounce <= 0;
            end
        end else debounce <= 0;

        // Rising-edge detect
        pulse_out <= (!btn_state && btn_prev);
        btn_prev  <= btn_state;
    end
endmodule
`default_nettype wire
