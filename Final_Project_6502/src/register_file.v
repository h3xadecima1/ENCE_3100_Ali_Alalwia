`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : register_file.v
// Description : CPU registers (A, X, Y, PC, SP, P)
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
// REGISTER FILE — 6502 Core Integration (WOZMON-ready)
// ================================================================
module register_file (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        load_A,
    input  wire        load_X,
    input  wire        load_Y,
    input  wire        load_P,
    input  wire        load_SP,
    input  wire        load_PC,
    input  wire        inc_PC,
    input  wire        dec_SP,
    input  wire        inc_SP,
    input  wire [7:0]  data_in,
    input  wire [7:0]  alu_result,
    input  wire        set_NZVC,
    input  wire        set_D,
    input  wire        clr_D,
    input  wire        set_I,
    input  wire        clr_I,
    input  wire        set_B,
    input  wire        clr_B,
    input  wire        set_C,
    input  wire        clr_C,
    input  wire        alu_C,
    input  wire        alu_V,
    output reg  [7:0]  A_out,
    output reg  [7:0]  X_out,
    output reg  [7:0]  Y_out,
    output wire [7:0]  P_out,
    output reg  [7:0]  SP_out,
    output reg  [15:0] PC_out,
    output wire        N_flag,
    output wire        V_flag,
    output wire        D_flag,
    output wire        I_flag,
    output wire        Z_flag,
    output wire        C_flag
);
    // Registers
    always @(posedge clk or negedge reset_n)
        if (!reset_n) A_out <= 8'h00;
        else if (load_A) A_out <= alu_result;

    always @(posedge clk or negedge reset_n)
        if (!reset_n) X_out <= 8'h00;
        else if (load_X) X_out <= alu_result;

    always @(posedge clk or negedge reset_n)
        if (!reset_n) Y_out <= 8'h00;
        else if (load_Y) Y_out <= alu_result;

    always @(posedge clk or negedge reset_n)
        if (!reset_n) SP_out <= 8'hFF;
        else if (load_SP) SP_out <= alu_result;
        else if (inc_SP) SP_out <= SP_out + 1;
        else if (dec_SP) SP_out <= SP_out - 1;

    // Force reset vector FF00 for WOZMON
    always @(posedge clk or negedge reset_n)
        if (!reset_n) PC_out <= 16'hFF00;
        else if (load_PC) PC_out <= {8'h00, alu_result};
        else if (inc_PC) PC_out <= PC_out + 1;

    status_flags u_flags (
        .clk(clk), .reset_n(reset_n),
        .alu_N(alu_result[7]),
        .alu_Z(alu_result == 8'h00),
        .alu_V(alu_V),
        .alu_C(alu_C),
        .set_NZVC(set_NZVC),
        .set_D(set_D), .clr_D(clr_D),
        .set_I(set_I), .clr_I(clr_I),
        .set_B(set_B), .clr_B(clr_B),
        .set_C(set_C), .clr_C(clr_C),
        .load_from_stack(1'b0),
        .data_in_from_stack(8'h00),
        .data_out_to_stack(),
        .P_out(P_out),
        .N_flag(N_flag), .V_flag(V_flag),
        .D_flag(D_flag), .I_flag(I_flag),
        .Z_flag(Z_flag), .C_flag(C_flag)
    );
endmodule
`default_nettype wire
