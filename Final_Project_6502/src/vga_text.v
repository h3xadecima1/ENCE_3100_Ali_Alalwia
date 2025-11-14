`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : vga_text.v
// Description : VGA text renderer
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
// VGA Text Display Controller (640x480 @ 60 Hz)
// Includes color-bar fallback if VRAM/font not used
// ================================================================
module vga_text (
    input  wire        clk_25mhz,
    input  wire        reset_n,
    output reg  [10:0] vram_addr,
    input  wire [7:0]  vram_data,
    output wire        hsync,
    output wire        vsync,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);

    // ------------------------------------------------------------
    // VGA 640×480 @ 60 Hz timing parameters
    // ------------------------------------------------------------
    parameter H_VISIBLE = 640;
    parameter H_FRONT   = 16;
    parameter H_SYNC    = 96;
    parameter H_BACK    = 48;
    parameter H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    parameter V_VISIBLE = 480;
    parameter V_FRONT   = 10;
    parameter V_SYNC    = 2;
    parameter V_BACK    = 33;
    parameter V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // ------------------------------------------------------------
    // Horizontal/Vertical counters
    // ------------------------------------------------------------
    always @(posedge clk_25mhz or negedge reset_n) begin
        if (!reset_n) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // ------------------------------------------------------------
    // Sync pulses (active low)
    // ------------------------------------------------------------
    assign hsync = ~(h_count >= (H_VISIBLE + H_FRONT) &&
                     h_count <  (H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync = ~(v_count >= (V_VISIBLE + V_FRONT) &&
                     v_count <  (V_VISIBLE + V_FRONT + V_SYNC));

    wire visible = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    // ------------------------------------------------------------
    // Character position for text mode (80×30 grid)
    // ------------------------------------------------------------
    wire [6:0] char_x = h_count[9:3];  // 8 pixels per char
    wire [5:0] char_y = v_count[9:4];  // 16 lines per char
    wire [2:0] pixel_x = h_count[2:0];
    wire [3:0] pixel_y = v_count[3:0];

    // VRAM address
    always @(*) begin
        vram_addr = char_y * 80 + char_x;
    end

    // ------------------------------------------------------------
    // Character ROM (font8x16)
    // ------------------------------------------------------------
    wire [7:0] char_row;
    font8x16 u_font (
        .clk(clk_25mhz),
        .char_code(vram_data),
        .row(pixel_y),
        .bits(char_row)
    );

    wire pixel_on = visible && char_row[7 - pixel_x];

    // ------------------------------------------------------------
    // Normal text color output (white text on black)
    // ------------------------------------------------------------
    wire [3:0] text_r = pixel_on ? 4'hF : 4'h0;
    wire [3:0] text_g = text_r;
    wire [3:0] text_b = text_r;

    // ------------------------------------------------------------
    // DEBUG COLOR BARS (if VRAM/font not responding)
    // Comment out this section after confirming sync
    // ------------------------------------------------------------
    reg [3:0] r_test, g_test, b_test;
    always @(posedge clk_25mhz) begin
        if (!reset_n) begin
            r_test <= 0; g_test <= 0; b_test <= 0;
        end else begin
            if (h_count < 80)       begin r_test <= 4'hF; g_test <= 0;    b_test <= 0;    end
            else if (h_count < 160) begin r_test <= 0;    g_test <= 4'hF; b_test <= 0;    end
            else if (h_count < 240) begin r_test <= 0;    g_test <= 0;    b_test <= 4'hF; end
            else if (h_count < 320) begin r_test <= 4'hF; g_test <= 4'hF; b_test <= 0;    end
            else if (h_count < 400) begin r_test <= 0;    g_test <= 4'hF; b_test <= 4'hF; end
            else if (h_count < 480) begin r_test <= 4'hF; g_test <= 0;    b_test <= 4'hF; end
            else                    begin r_test <= 4'hF; g_test <= 4'hF; b_test <= 4'hF; end
        end
    end

    // ------------------------------------------------------------
    // Final VGA output mux (text or color bar)
    // ------------------------------------------------------------
    // Choose 1 to test pattern, 0 for normal text mode
    localparam USE_TEST_PATTERN = 1'b1;

    assign vga_r = visible ? (USE_TEST_PATTERN ? r_test : text_r) : 4'd0;
    assign vga_g = visible ? (USE_TEST_PATTERN ? g_test : text_g) : 4'd0;
    assign vga_b = visible ? (USE_TEST_PATTERN ? b_test : text_b) : 4'd0;

endmodule
`default_nettype wire
