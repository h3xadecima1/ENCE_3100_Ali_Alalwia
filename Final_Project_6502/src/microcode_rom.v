`timescale 1ns/1ps
`include "decode_constants.vh"
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : microcode_rom.v
// Description : 40-bit micro-instruction ROM
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

// ====================================================================
// MICROCODE ROM – 6502 Complete Control Table (Phase 1 scaffolding)
// ====================================================================
//
// Each micro-instruction is 32 bits wide:
//
//  [ 0] LOAD_A
//  [ 1] LOAD_X
//  [ 2] LOAD_Y
//  [ 3] LOAD_P
//  [ 4] LOAD_SP
//  [ 5] LOAD_PC
//  [ 6] MEM_READ
//  [ 7] MEM_WRITE
//  [ 8] INC_PC
//  [12:9] ALU_OP
//  [13] SET_NZVC
//  [31:14] Reserved for expansion
//
// ====================================================================
module microcode_rom (
    input  wire [7:0] opcode,
    input  wire [2:0] phase,
    output reg  [39:0] micro_word
);

    // --- default: NOP ---
    always @(*) begin
        micro_word = 32'b0;
        case (opcode)

        // =============================================================
        // UNIVERSAL FETCH SEQUENCE
        // =============================================================
        // Cycle 1 : Fetch opcode from PC
        // Cycle 2 : Increment PC
        // Cycle 3 : Decode + prepare operands
        // =============================================================
        8'h00, 8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07,
        8'h08, 8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F,
        8'h10, 8'h11, 8'h12, 8'h13, 8'h14, 8'h15, 8'h16, 8'h17,
        8'h18, 8'h19, 8'h1A, 8'h1B, 8'h1C, 8'h1D, 8'h1E, 8'h1F,
        8'h20, 8'h21, 8'h22, 8'h23, 8'h24, 8'h25, 8'h26, 8'h27,
        8'h28, 8'h29, 8'h2A, 8'h2B, 8'h2C, 8'h2D, 8'h2E, 8'h2F,
        8'h30, 8'h31, 8'h32, 8'h33, 8'h34, 8'h35, 8'h36, 8'h37,
        8'h38, 8'h39, 8'h3A, 8'h3B, 8'h3C, 8'h3D, 8'h3E, 8'h3F,
        8'h40, 8'h41, 8'h42, 8'h43, 8'h44, 8'h45, 8'h46, 8'h47,
        8'h48, 8'h49, 8'h4A, 8'h4B, 8'h4C, 8'h4D, 8'h4E, 8'h4F,
        8'h50, 8'h51, 8'h52, 8'h53, 8'h54, 8'h55, 8'h56, 8'h57,
        8'h58, 8'h59, 8'h5A, 8'h5B, 8'h5C, 8'h5D, 8'h5E, 8'h5F,
        8'h60, 8'h61, 8'h62, 8'h63, 8'h64, 8'h65, 8'h66, 8'h67,
        8'h68, 8'h69, 8'h6A, 8'h6B, 8'h6C, 8'h6D, 8'h6E, 8'h6F,
        8'h70, 8'h71, 8'h72, 8'h73, 8'h74, 8'h75, 8'h76, 8'h77,
        8'h78, 8'h79, 8'h7A, 8'h7B, 8'h7C, 8'h7D, 8'h7E, 8'h7F,
        8'h80, 8'h81, 8'h82, 8'h83, 8'h84, 8'h85, 8'h86, 8'h87,
        8'h88, 8'h89, 8'h8A, 8'h8B, 8'h8C, 8'h8D, 8'h8E, 8'h8F,
        8'h90, 8'h91, 8'h92, 8'h93, 8'h94, 8'h95, 8'h96, 8'h97,
        8'h98, 8'h99, 8'h9A, 8'h9B, 8'h9C, 8'h9D, 8'h9E, 8'h9F,
        8'hA0, 8'hA1, 8'hA2, 8'hA3, 8'hA4, 8'hA5, 8'hA6, 8'hA7,
        8'hA8, 8'hA9, 8'hAA, 8'hAB, 8'hAC, 8'hAD, 8'hAE, 8'hAF,
        8'hB0, 8'hB1, 8'hB2, 8'hB3, 8'hB4, 8'hB5, 8'hB6, 8'hB7,
        8'hB8, 8'hB9, 8'hBA, 8'hBB, 8'hBC, 8'hBD, 8'hBE, 8'hBF,
        8'hC0, 8'hC1, 8'hC2, 8'hC3, 8'hC4, 8'hC5, 8'hC6, 8'hC7,
        8'hC8, 8'hC9, 8'hCA, 8'hCB, 8'hCC, 8'hCD, 8'hCE, 8'hCF,
        8'hD0, 8'hD1, 8'hD2, 8'hD3, 8'hD4, 8'hD5, 8'hD6, 8'hD7,
        8'hD8, 8'hD9, 8'hDA, 8'hDB, 8'hDC, 8'hDD, 8'hDE, 8'hDF,
        8'hE0, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE6, 8'hE7,
        8'hE8, 8'hE9, 8'hEA, 8'hEB, 8'hEC, 8'hED, 8'hEE, 8'hEF,
        8'hF0, 8'hF1, 8'hF2, 8'hF3, 8'hF4, 8'hF5, 8'hF6, 8'hF7,
        8'hF8, 8'hF9, 8'hFA, 8'hFB, 8'hFC, 8'hFD, 8'hFE, 8'hFF:
        begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD]  = 1'b1; // fetch opcode
                3'd1: micro_word[`BIT_INC_PC]  = 1'b1; // increment PC
                3'd2: micro_word[`BIT_MEM_RD]  = 1'b1; // fetch operand
            endcase
        end

        // =============================================================
        // NOP (EA) — baseline no-op
        // =============================================================
        8'hEA: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD]  = 1'b1;
                3'd1: micro_word[`BIT_INC_PC]  = 1'b1;
            endcase
        end
		
		
		        // =============================================================
        // LOAD / STORE GROUP
        // =============================================================

        // -------------------------------------------------------------
        // LDA  – Load Accumulator
        // -------------------------------------------------------------
        8'hA9: begin // LDA #imm
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    micro_word[`BIT_LOAD_A]  = 1'b1;
                    micro_word[`BIT_SET_NZVC]= 1'b1;
                end
            endcase
        end

        8'hA5, 8'hB5, 8'hAD, 8'hBD, 8'hB9, 8'hA1, 8'hB1: begin // zp, zpX, abs, absX, absY, (indX), (indY)
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;   // fetch operand low
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;   // advance PC
                3'd2: micro_word[`BIT_MEM_RD] = 1'b1;   // read value
                3'd3: begin
                    micro_word[`BIT_LOAD_A]  = 1'b1;
                    micro_word[`BIT_SET_NZVC]= 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // LDX – Load X Register
        // -------------------------------------------------------------
        8'hA2: begin // #imm
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    micro_word[`BIT_LOAD_X]  = 1'b1;
                    micro_word[`BIT_SET_NZVC]= 1'b1;
                end
            endcase
        end

        8'hA6, 8'hB6, 8'hAE, 8'hBE: begin // zp, zpY, abs, absY
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd3: begin
                    micro_word[`BIT_LOAD_X]  = 1'b1;
                    micro_word[`BIT_SET_NZVC]= 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // LDY – Load Y Register
        // -------------------------------------------------------------
        8'hA0: begin // #imm
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    micro_word[`BIT_LOAD_Y]  = 1'b1;
                    micro_word[`BIT_SET_NZVC]= 1'b1;
                end
            endcase
        end

        8'hA4, 8'hB4, 8'hAC, 8'hBC: begin // zp, zpX, abs, absX
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd3: begin
                    micro_word[`BIT_LOAD_Y]  = 1'b1;
                    micro_word[`BIT_SET_NZVC]= 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // STA – Store Accumulator
        // -------------------------------------------------------------
        8'h85, 8'h95, 8'h8D, 8'h9D, 8'h99, 8'h81, 8'h91: begin // zp, zpX, abs, absX, absY, (indX), (indY)
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;  // fetch address
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1; // write A to memory
            endcase
        end

        // -------------------------------------------------------------
        // STX – Store X Register
        // -------------------------------------------------------------
        8'h86, 8'h96, 8'h8E: begin // zp, zpY, abs
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // STY – Store Y Register
        // -------------------------------------------------------------
        8'h84, 8'h94, 8'h8C: begin // zp, zpX, abs
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // LAX – Illegal (LDA + LDX)
        // -------------------------------------------------------------
        8'hA7, 8'hB7, 8'hAF, 8'hBF, 8'hA3, 8'hB3, 8'hAB: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd3: begin
                    micro_word[`BIT_LOAD_A]  = 1'b1;
                    micro_word[`BIT_LOAD_X]  = 1'b1;
                    micro_word[`BIT_SET_NZVC]= 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // SAX – Illegal (STA & STX AND)
        // -------------------------------------------------------------
        8'h87, 8'h97, 8'h8F, 8'h83: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end
		
		        // =============================================================
        // ARITHMETIC / LOGICAL GROUP
        // =============================================================

        // -------------------------------------------------------------
        // ADC – Add with Carry
        // -------------------------------------------------------------
        8'h69, 8'h65, 8'h75, 8'h6D, 8'h7D, 8'h79, 8'h61, 8'h71: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0000; // ADD
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // SBC – Subtract with Carry
        // -------------------------------------------------------------
        8'hE9, 8'hE5, 8'hF5, 8'hED, 8'hFD, 8'hF9, 8'hE1, 8'hF1: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0001; // SUB
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // AND – Logical AND
        // -------------------------------------------------------------
        8'h29, 8'h25, 8'h35, 8'h2D, 8'h3D, 8'h39, 8'h21, 8'h31: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0010; // AND
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // ORA – Logical OR
        // -------------------------------------------------------------
        8'h09, 8'h05, 8'h15, 8'h0D, 8'h1D, 8'h19, 8'h01, 8'h11: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0011; // OR
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // EOR – Logical XOR
        // -------------------------------------------------------------
        8'h49, 8'h45, 8'h55, 8'h4D, 8'h5D, 8'h59, 8'h41, 8'h51: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0100; // XOR
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // CMP – Compare A
        // -------------------------------------------------------------
        8'hC9, 8'hC5, 8'hD5, 8'hCD, 8'hDD, 8'hD9, 8'hC1, 8'hD1: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0001; // SUB
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // CPX – Compare X
        // -------------------------------------------------------------
        8'hE0, 8'hE4, 8'hEC: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0001;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // CPY – Compare Y
        // -------------------------------------------------------------
        8'hC0, 8'hC4, 8'hCC: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0001;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // DCP – Illegal (DEC + CMP)
        // -------------------------------------------------------------
        8'hC7, 8'hD7, 8'hCF, 8'hDF, 8'hDB, 8'hD3, 8'hC3: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0110; // DEC
                    micro_word[`BIT_MEM_WRITE] = 1'b1;
                end
                3'd3: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0001; // SUB
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // ISC – Illegal (INC + SBC)
        // -------------------------------------------------------------
        8'hE7, 8'hF7, 8'hEF, 8'hFF, 8'hFB, 8'hF3, 8'hE3: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0101; // INC
                    micro_word[`BIT_MEM_WRITE] = 1'b1;
                end
                3'd3: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0001; // SUB
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end
		
		        // =============================================================
        // SHIFT / ROTATE GROUP
        // =============================================================

        // -------------------------------------------------------------
        // ASL – Arithmetic Shift Left
        // -------------------------------------------------------------
        8'h0A: begin // Accumulator
            case (phase)
                3'd0: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1001; // custom: ASL
                3'd1: begin
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end
        8'h06, 8'h16, 8'h0E, 8'h1E: begin // Memory
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1001;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // LSR – Logical Shift Right
        // -------------------------------------------------------------
        8'h4A: begin // Accumulator
            case (phase)
                3'd0: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1010;
                3'd1: begin
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end
        8'h46, 8'h56, 8'h4E, 8'h5E: begin // Memory
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1010;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // ROL – Rotate Left
        // -------------------------------------------------------------
        8'h2A: begin
            case (phase)
                3'd0: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1011;
                3'd1: begin
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end
        8'h26, 8'h36, 8'h2E, 8'h3E: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1011;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // ROR – Rotate Right
        // -------------------------------------------------------------
        8'h6A: begin
            case (phase)
                3'd0: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1100;
                3'd1: begin
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end
        8'h66, 8'h76, 8'h6E, 8'h7E: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1100;
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // Illegal – SLO (ASL + ORA)
        // -------------------------------------------------------------
        8'h07, 8'h17, 8'h0F, 8'h1F, 8'h1B, 8'h13, 8'h03: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1001; // ASL
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
                3'd3: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0011;   // OR
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // Illegal – RLA (ROL + AND)
        // -------------------------------------------------------------
        8'h27, 8'h37, 8'h2F, 8'h3F, 8'h3B, 8'h33, 8'h23: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1011; // ROL
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
                3'd3: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0010;   // AND
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // Illegal – SRE (LSR + EOR)
        // -------------------------------------------------------------
        8'h47, 8'h57, 8'h4F, 8'h5F, 8'h5B, 8'h53, 8'h43: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1010; // LSR
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
                3'd3: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0100;   // XOR
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // -------------------------------------------------------------
        // Illegal – RRA (ROR + ADC)
        // -------------------------------------------------------------
        8'h67, 8'h77, 8'h6F, 8'h7F, 8'h7B, 8'h73, 8'h63: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b1100; // ROR
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
                3'd3: begin
                    {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0000;   // ADD
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end
		
		
		        // =============================================================
        // FLOW CONTROL / BRANCH / STACK GROUP
        // =============================================================

        // -------------------------------------------------------------
        // JMP  – Jump Absolute / Indirect
        // -------------------------------------------------------------
        8'h4C, 8'h6C: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;          // fetch address low
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_MEM_RD] = 1'b1;          // fetch address high
                3'd3: micro_word[`BIT_LOAD_PC] = 1'b1;         // load PC
            endcase
        end

        // -------------------------------------------------------------
        // JSR – Jump to Subroutine
        // -------------------------------------------------------------
        8'h20: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;          // fetch addr low
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_DEC_SP] = 1'b1;          // push PCH
                3'd3: micro_word[`BIT_DEC_SP] = 1'b1;          // push PCL
                3'd4: micro_word[`BIT_LOAD_PC] = 1'b1;         // jump
            endcase
        end

        // -------------------------------------------------------------
        // RTS – Return from Subroutine
        // -------------------------------------------------------------
        8'h60: begin
            case (phase)
                3'd0: micro_word[`BIT_INC_SP] = 1'b1;          // pull PCL
                3'd1: micro_word[`BIT_INC_SP] = 1'b1;          // pull PCH
                3'd2: micro_word[`BIT_LOAD_PC] = 1'b1;
                3'd3: micro_word[`BIT_INC_PC] = 1'b1;          // advance to next
            endcase
        end

        // -------------------------------------------------------------
        // RTI – Return from Interrupt
        // -------------------------------------------------------------
        8'h40: begin
            case (phase)
                3'd0: micro_word[`BIT_INC_SP] = 1'b1;          // pull P
                3'd1: micro_word[`BIT_INC_SP] = 1'b1;          // pull PCL
                3'd2: micro_word[`BIT_INC_SP] = 1'b1;          // pull PCH
                3'd3: micro_word[`BIT_LOAD_PC] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // BRK – Software Interrupt
        // -------------------------------------------------------------
        8'h00: begin
            case (phase)
                3'd0: micro_word[`BIT_INC_PC] = 1'b1;
                3'd1: micro_word[`BIT_DEC_SP] = 1'b1;          // push PCH
                3'd2: micro_word[`BIT_DEC_SP] = 1'b1;          // push PCL
                3'd3: micro_word[`BIT_DEC_SP] = 1'b1;          // push P
                3'd4: micro_word[`BIT_SET_B]  = 1'b1;
                3'd5: micro_word[`BIT_LOAD_PC]= 1'b1;          // jump to vector
            endcase
        end

        // -------------------------------------------------------------
        // Conditional Branches (relative offset)
        // -------------------------------------------------------------
        8'h10, 8'h30, 8'h50, 8'h70, 8'h90, 8'hB0, 8'hD0, 8'hF0: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;          // fetch offset
                3'd1: micro_word[`BIT_INC_PC] = 1'b1;
                3'd2: micro_word[`BIT_LOAD_PC] = 1'b1;         // if condition true
            endcase
        end

        // -------------------------------------------------------------
        // Flag Control Instructions
        // -------------------------------------------------------------
        8'h18: micro_word[`BIT_CLR_C] = 1'b1;   // CLC
        8'h38: micro_word[`BIT_SET_C] = 1'b1;   // SEC
        8'h58: micro_word[`BIT_CLR_I] = 1'b1;   // CLI
        8'h78: micro_word[`BIT_SET_I] = 1'b1;   // SEI
        8'hB8: micro_word[`BIT_CLR_V] = 1'b1;   // CLV
        8'hD8: micro_word[`BIT_CLR_D] = 1'b1;   // CLD
        8'hF8: micro_word[`BIT_SET_D] = 1'b1;   // SED
		
		
		        // =============================================================
        // PHASE 6 — STACK, TRANSFER & INCREMENT GROUP
        // =============================================================

        // -------------------------------------------------------------
        // INC — Increment Memory
        // -------------------------------------------------------------
        8'hE6, 8'hF6, 8'hEE, 8'hFE: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0101; // INC
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
                3'd3: micro_word[`BIT_SET_NZVC] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // DEC — Decrement Memory
        // -------------------------------------------------------------
        8'hC6, 8'hD6, 8'hCE, 8'hDE: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: {micro_word[`BIT_ALU_OP3:`BIT_ALU_OP0]} = 4'b0110; // DEC
                3'd2: micro_word[`BIT_MEM_WRITE] = 1'b1;
                3'd3: micro_word[`BIT_SET_NZVC] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // TAX, TXA, TAY, TYA — Register Transfers
        // -------------------------------------------------------------
        8'hAA: begin micro_word[`BIT_LOAD_X] = 1'b1; micro_word[`BIT_SET_NZVC] = 1'b1; end // TAX
        8'h8A: begin micro_word[`BIT_LOAD_A] = 1'b1; micro_word[`BIT_SET_NZVC] = 1'b1; end // TXA
        8'hA8: begin micro_word[`BIT_LOAD_Y] = 1'b1; micro_word[`BIT_SET_NZVC] = 1'b1; end // TAY
        8'h98: begin micro_word[`BIT_LOAD_A] = 1'b1; micro_word[`BIT_SET_NZVC] = 1'b1; end // TYA

        // -------------------------------------------------------------
        // TSX / TXS — Stack Pointer Transfers
        // -------------------------------------------------------------
        8'hBA: begin micro_word[`BIT_LOAD_X]  = 1'b1; micro_word[`BIT_SET_NZVC] = 1'b1; end // TSX
        8'h9A: begin micro_word[`BIT_LOAD_SP] = 1'b1; end                                   // TXS

        // -------------------------------------------------------------
        // Stack Push / Pull Instructions
        // -------------------------------------------------------------
        // PHA — Push Accumulator
        8'h48: begin
            case (phase)
                3'd0: micro_word[`BIT_DEC_SP] = 1'b1;
                3'd1: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // PLA — Pull Accumulator
        8'h68: begin
            case (phase)
                3'd0: micro_word[`BIT_INC_SP] = 1'b1;
                3'd1: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd2: begin
                    micro_word[`BIT_LOAD_A]   = 1'b1;
                    micro_word[`BIT_SET_NZVC] = 1'b1;
                end
            endcase
        end

        // PHP — Push Processor Status
        8'h08: begin
            case (phase)
                3'd0: micro_word[`BIT_DEC_SP] = 1'b1;
                3'd1: micro_word[`BIT_MEM_WRITE] = 1'b1;
            endcase
        end

        // PLP — Pull Processor Status
        8'h28: begin
            case (phase)
                3'd0: micro_word[`BIT_INC_SP] = 1'b1;
                3'd1: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd2: micro_word[`BIT_LOAD_P] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // NOP — No Operation (and “illegal” NOPs)
        // -------------------------------------------------------------
        8'hEA, 8'h1A, 8'h3A, 8'h5A, 8'h7A, 8'hDA, 8'hFA: begin
            case (phase)
                3'd0: micro_word[`BIT_INC_PC] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // RESET VECTOR SEQUENCE (FFFC–FFFD)
        // -------------------------------------------------------------
        8'hFF: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;          // low vector
                3'd1: micro_word[`BIT_MEM_RD] = 1'b1;          // high vector
                3'd2: micro_word[`BIT_LOAD_PC] = 1'b1;
            endcase
        end

        // -------------------------------------------------------------
        // IRQ / BRK VECTOR (FFFE–FFFF)
        // -------------------------------------------------------------
        8'hFE: begin
            case (phase)
                3'd0: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd1: micro_word[`BIT_MEM_RD] = 1'b1;
                3'd2: micro_word[`BIT_LOAD_PC] = 1'b1;
            endcase
        end

        default: micro_word = 32'b0;
        endcase
    end
endmodule
`default_nettype wire
