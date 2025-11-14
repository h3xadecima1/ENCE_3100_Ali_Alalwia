`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : status_flags.v
// Description : Processor Status Register (NV-BDIZC)
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
// STATUS FLAGS REGISTER – NMOS 6502 Accurate Implementation
// ================================================================
//
// Bit | Name | Description
// ----+------+---------------------------------------------
//  7  | N    | Negative (ALU result bit 7)
//  6  | V    | Overflow
//  5  | 1    | Unused (always reads 1)
//  4  | B    | Break (set on BRK or PHP pushes only)
//  3  | D    | Decimal mode
//  2  | I    | Interrupt disable
//  1  | Z    | Zero
//  0  | C    | Carry
//
// Inputs:
//   - alu_NZVC: flags from ALU (computed dynamically)
//   - control signals from control_unit for explicit set/clear
//   - push/pop interface (for PHP/PLP/RTI)
//
// ================================================================

module status_flags (
    input  wire        clk,
    input  wire        reset_n,

    // From ALU (for automatic updates)
    input  wire        alu_N,
    input  wire        alu_Z,
    input  wire        alu_V,
    input  wire        alu_C,

    // Control inputs
    input  wire        set_NZVC,   // load N,Z,V,C from ALU result
    input  wire        set_D,
    input  wire        clr_D,
    input  wire        set_I,
    input  wire        clr_I,
    input  wire        set_B,
    input  wire        clr_B,
    input  wire        set_C,
    input  wire        clr_C,

    // Stack operations
    input  wire        load_from_stack,  // PLP or RTI
    input  wire [7:0]  data_in_from_stack,

    // Output to stack (PHP, BRK)
    output wire [7:0]  data_out_to_stack,

    // Current processor status output
    output reg  [7:0]  P_out,

    // Individual bits
    output wire        N_flag,
    output wire        V_flag,
    output wire        D_flag,
    output wire        I_flag,
    output wire        Z_flag,
    output wire        C_flag
);

    // ----------------------------------------------------------------
    // Initial Reset
    // ----------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            P_out <= 8'b00100100; // Default after RESET: IRQ disabled
        else begin
            // --- load flags from stack (PLP / RTI) ---
            if (load_from_stack)
                // note: bits 5 always =1, bit 4 ignored except BRK return
                P_out <= (data_in_from_stack & 8'b11001111) | 8'b00100000;
            else begin
                // --- explicit set/clear ---
                if (set_D)  P_out[3] <= 1'b1;
                if (clr_D)  P_out[3] <= 1'b0;
                if (set_I)  P_out[2] <= 1'b1;
                if (clr_I)  P_out[2] <= 1'b0;
                if (set_B)  P_out[4] <= 1'b1;
                if (clr_B)  P_out[4] <= 1'b0;
                if (set_C)  P_out[0] <= 1'b1;
                if (clr_C)  P_out[0] <= 1'b0;

                // --- automatic load from ALU (ADC/SBC/logic ops) ---
                if (set_NZVC) begin
                    P_out[7] <= alu_N; // N
                    P_out[6] <= alu_V; // V
                    P_out[1] <= alu_Z; // Z
                    P_out[0] <= alu_C; // C
                end
            end
        end
    end

    // ----------------------------------------------------------------
    // Output packing (for PHP/BRK pushes)
    // bit 5 always 1, bit 4 depends on BRK
    // ----------------------------------------------------------------
    assign data_out_to_stack = { P_out[7:6], 1'b1, P_out[4], P_out[3:0] };

    // ----------------------------------------------------------------
    // Individual flag signals for convenience
    // ----------------------------------------------------------------
    assign N_flag = P_out[7];
    assign V_flag = P_out[6];
    assign D_flag = P_out[3];
    assign I_flag = P_out[2];
    assign Z_flag = P_out[1];
    assign C_flag = P_out[0];

endmodule
`default_nettype wire
