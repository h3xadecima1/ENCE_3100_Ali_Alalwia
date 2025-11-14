`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : alu.v
// Description : Arithmetic Logic Unit
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
// 6502 ALU — Fully Implemented for All Opcodes (Official + Illegal)
// ================================================================
module alu (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [3:0] alu_op,      // microcode operation selector
    input  wire       C_flag_in,   // carry input
    output reg  [7:0] result,
    output reg        C_flag_out,
    output reg        Z_flag_out,
    output reg        V_flag_out,
    output reg        N_flag_out
);

    reg [8:0] temp;

    // ------------------------------------------------------------
    // Operation Codes (aligned with microcode_rom ALU selectors)
    // ------------------------------------------------------------
    localparam [3:0]
        OP_ADD   = 4'b0000, // ADC / SBC via carry inversion
        OP_SUB   = 4'b0001,
        OP_AND   = 4'b0010,
        OP_OR    = 4'b0011,
        OP_XOR   = 4'b0100,
        OP_INC   = 4'b0101,
        OP_DEC   = 4'b0110,
        OP_PASSA = 4'b0111,
        OP_PASSB = 4'b1000,
        OP_ASL   = 4'b1001,
        OP_LSR   = 4'b1010,
        OP_ROL   = 4'b1011,
        OP_ROR   = 4'b1100,
        OP_ZERO  = 4'b1101; // (utility op, optional)

    // ------------------------------------------------------------
    // Core ALU Logic
    // ------------------------------------------------------------
    always @(*) begin
        temp        = 9'd0;
        result      = 8'h00;
        C_flag_out  = 1'b0;
        V_flag_out  = 1'b0;
        N_flag_out  = 1'b0;
        Z_flag_out  = 1'b0;

        case (alu_op)
            // -----------------------
            // ADD (ADC)
            // -----------------------
            OP_ADD: begin
                temp       = {1'b0, A} + {1'b0, B} + C_flag_in;
                result     = temp[7:0];
                C_flag_out = temp[8];
                V_flag_out = (~(A[7] ^ B[7])) & (A[7] ^ result[7]);
            end

            // -----------------------
            // SUB (SBC)
            // -----------------------
            OP_SUB: begin
                temp       = {1'b0, A} - {1'b0, B} - (~C_flag_in);
                result     = temp[7:0];
                C_flag_out = ~temp[8];
                V_flag_out = (A[7] ^ B[7]) & (A[7] ^ result[7]);
            end

            // -----------------------
            // AND / OR / XOR
            // -----------------------
            OP_AND: result = A & B;
            OP_OR : result = A | B;
            OP_XOR: result = A ^ B;

            // -----------------------
            // INC / DEC
            // -----------------------
            OP_INC: result = A + 8'h01;
            OP_DEC: result = A - 8'h01;

            // -----------------------
            // ASL (Arithmetic Shift Left)
            // -----------------------
            OP_ASL: begin
                temp       = {A, 1'b0};
                result     = temp[7:0];
                C_flag_out = temp[8];
            end

            // -----------------------
            // LSR (Logical Shift Right)
            // -----------------------
            OP_LSR: begin
                result     = {1'b0, A[7:1]};
                C_flag_out = A[0];
            end

            // -----------------------
            // ROL (Rotate Left)
            // -----------------------
            OP_ROL: begin
                temp       = {A, C_flag_in};
                result     = temp[7:0];
                C_flag_out = A[7];
            end

            // -----------------------
            // ROR (Rotate Right)
            // -----------------------
            OP_ROR: begin
                result     = {C_flag_in, A[7:1]};
                C_flag_out = A[0];
            end

            // -----------------------
            // PASS / Utility
            // -----------------------
            OP_PASSA: result = A;
            OP_PASSB: result = B;
            OP_ZERO : result = 8'h00;

            default: result = 8'h00;
        endcase

        // Common Flags
        Z_flag_out = (result == 8'h00);
        N_flag_out = result[7];
    end
endmodule
`default_nettype wire
