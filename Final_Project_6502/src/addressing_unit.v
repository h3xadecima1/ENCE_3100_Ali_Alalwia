`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : addressing_unit.v
// Description : Effective address calculator
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
// ADDRESSING UNIT – 6502 Effective Address Generator
// ================================================================
// Implements all 13 official addressing modes:
// ------------------------------------------------
//  1. Immediate          (#$nn)
//  2. Zero Page          ($nn)
//  3. Zero Page,X        ($nn,X)
//  4. Zero Page,Y        ($nn,Y)
//  5. Absolute           ($nnnn)
//  6. Absolute,X         ($nnnn,X)
//  7. Absolute,Y         ($nnnn,Y)
//  8. Indirect           (($nnnn))
//  9. Indexed Indirect   (($nn,X))
// 10. Indirect Indexed   (($nn),Y)
// 11. Relative           (branch displacement)
// 12. Accumulator        (A register)
// 13. Implied            (no operand)
// ================================================================

module addressing_unit (
    input  wire        clk,
    input  wire        reset_n,

    // Operand bytes from memory
    input  wire [7:0]  operand_lo,   // first fetched byte
    input  wire [7:0]  operand_hi,   // second fetched byte

    // Register inputs
    input  wire [7:0]  X_reg,
    input  wire [7:0]  Y_reg,
    input  wire [15:0] PC_in,

    // Mode selector
    input  wire [3:0]  addr_mode,    // select addressing mode

    // Effective address output
    output reg  [15:0] eff_addr,
    output reg         page_crossed, // page boundary penalty
    output reg  [7:0]  operand_value // immediate or fetched byte
);

    // ------------------------------------------------------------
    // Addressing Mode Encoding
    // ------------------------------------------------------------
    localparam [3:0]
        MODE_IMM  = 4'd0,   // Immediate
        MODE_ZP   = 4'd1,   // Zero Page
        MODE_ZPX  = 4'd2,   // Zero Page,X
        MODE_ZPY  = 4'd3,   // Zero Page,Y
        MODE_ABS  = 4'd4,   // Absolute
        MODE_ABSX = 4'd5,   // Absolute,X
        MODE_ABSY = 4'd6,   // Absolute,Y
        MODE_IND  = 4'd7,   // Indirect (JMP only)
        MODE_INDX = 4'd8,   // Indexed Indirect (X)
        MODE_INDY = 4'd9,   // Indirect Indexed (Y)
        MODE_REL  = 4'd10,  // Relative
        MODE_ACC  = 4'd11,  // Accumulator
        MODE_IMPL = 4'd12;  // Implied

    // ------------------------------------------------------------
    // Zero-page wrap-around helper (8-bit addressing)
    // ------------------------------------------------------------
    function [7:0] zp_add;
        input [7:0] base;
        input [7:0] offset;
        begin
            zp_add = (base + offset) & 8'hFF;
        end
    endfunction

    // ------------------------------------------------------------
    // Calculate effective address
    // ------------------------------------------------------------
    reg [15:0] base;  // temporary for {operand_hi, operand_lo}

    always @(*) begin
        eff_addr      = 16'h0000;
        page_crossed  = 1'b0;
        operand_value = operand_lo;
        base          = {operand_hi, operand_lo};

        case (addr_mode)
            // Immediate mode – operand is literal
            MODE_IMM: begin
                eff_addr = PC_in + 16'd1; // operand after opcode
                operand_value = operand_lo;
            end

            // Zero Page
            MODE_ZP: begin
                eff_addr = {8'h00, operand_lo};
            end

            // Zero Page,X
            MODE_ZPX: begin
                eff_addr = {8'h00, zp_add(operand_lo, X_reg)};
            end

            // Zero Page,Y
            MODE_ZPY: begin
                eff_addr = {8'h00, zp_add(operand_lo, Y_reg)};
            end

            // Absolute
            MODE_ABS: begin
                eff_addr = base;
            end

            // Absolute,X
            MODE_ABSX: begin
                eff_addr = base + X_reg;
                page_crossed = (base[15:8] != eff_addr[15:8]);
            end

            // Absolute,Y
            MODE_ABSY: begin
                eff_addr = base + Y_reg;
                page_crossed = (base[15:8] != eff_addr[15:8]);
            end

            // Indirect (used only by JMP)
            MODE_IND: begin
                // emulate JMP ($xxFF) hardware bug
                if (operand_lo == 8'hFF)
                    eff_addr = {operand_hi, 8'h00}; // bug wraps low byte
                else
                    eff_addr = base;
            end

            // Indexed Indirect (operand + X)
            MODE_INDX: begin
                eff_addr = {8'h00, zp_add(operand_lo, X_reg)};
            end

            // Indirect Indexed (operand) + Y
            MODE_INDY: begin
                eff_addr = {8'h00, operand_lo} + Y_reg;
                page_crossed = (eff_addr[15:8] != 8'h00);
            end

            // Relative – signed branch offset
            MODE_REL: begin
                eff_addr = PC_in + {{8{operand_lo[7]}}, operand_lo};
            end

            // Accumulator
            MODE_ACC: begin
                eff_addr = 16'h0000; // refers to A register
            end

            // Implied
            MODE_IMPL: begin
                eff_addr = 16'h0000;
            end

            default: begin
                eff_addr = 16'h0000;
            end
        endcase
    end

endmodule
`default_nettype wire
