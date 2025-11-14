`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : control_unit.v
// Description : Microcode-driven control logic
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
// CONTROL UNIT – 6502 Microcode-Driven (Phase-Aware Version)
// ================================================================
// • Drives ALU, memory interface, and register load signals
// • Uses a 2-bit phase counter for FETCH → DECODE → EXECUTE timing
// • Connects to microcode_rom.v (256×40-bit ROM)
// ================================================================

module control_unit (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        rdy,

    // Fetched opcode from instruction fetch
    input  wire [7:0]  opcode,

    // Outputs to datapath
    output reg  [3:0]  alu_op,
    output reg         mem_read_req,
    output reg         mem_write_req,
    output reg         load_A,
    output reg         load_X,
    output reg         load_Y,
    output reg         load_P,
    output reg         load_SP,
    output reg         load_PC,
    output reg         inc_PC,
    output reg         dec_SP,
    output reg         inc_SP,
    output reg  [7:0]  cycle_count,
    output reg  [3:0]  addr_mode_code
);

    // ----------------------------------------------------------------
    // 2-bit Phase Counter (0 → 1 → 2 → 0 ...)
    // ----------------------------------------------------------------
    reg [2:0] phase;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            phase <= 2'd0;
        else if (rdy)
            phase <= (phase == 2'd2) ? 2'd0 : phase + 2'd1;
    end

    // ----------------------------------------------------------------
    // Microcode ROM Connection
    // ----------------------------------------------------------------
    wire [39:0] micro_word;

    microcode_rom u_micro (
        .opcode(opcode),
        .phase(phase),
        .micro_word(micro_word)
    );

    // ----------------------------------------------------------------
    // Decode 40-bit micro_word into Control Signals
    // ----------------------------------------------------------------
    always @(*) begin
        cycle_count    = micro_word[39:32];
        addr_mode_code = micro_word[31:28];
        alu_op         = micro_word[27:24];
        mem_read_req   = micro_word[23];
        mem_write_req  = micro_word[22];
        load_A         = micro_word[21];
        load_X         = micro_word[20];
        load_Y         = micro_word[19];
        load_SP        = micro_word[18];
        load_PC        = micro_word[17];
        load_P         = micro_word[16];
        inc_PC         = micro_word[15];
        dec_SP         = micro_word[14];
        inc_SP         = micro_word[13];
    end

endmodule
`default_nettype wire
