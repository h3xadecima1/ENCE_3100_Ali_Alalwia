// ============================================================
// Project     : 6502 FPGA Processor System
// File        : decode_constant.vh
// Description : Opcode/Decode defines
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
// decode_constants.vh — Unified Control Bit Definitions for 6502 CPU
// ================================================================

// =============== ALU OPERATION BITS ==============================
`define BIT_ALU_OP0       0
`define BIT_ALU_OP1       1
`define BIT_ALU_OP2       2
`define BIT_ALU_OP3       3
`define BIT_ALU_OP4       4

// =============== MEMORY CONTROL BITS =============================
`define BIT_MEM_RD        5
`define BIT_MEM_WRITE     6
`define BIT_INC_PC        7
`define BIT_DEC_SP        8
`define BIT_INC_SP        9

// =============== REGISTER LOAD SIGNALS ===========================
`define BIT_LOAD_A        10
`define BIT_LOAD_X        11
`define BIT_LOAD_Y        12
`define BIT_LOAD_P        13
`define BIT_LOAD_PC       14
`define BIT_LOAD_SP       15

// =============== FLAG CONTROL SIGNALS ============================
`define BIT_SET_NZVC      16
`define BIT_SET_D         17
`define BIT_CLR_D         18
`define BIT_SET_I         19
`define BIT_CLR_I         20
`define BIT_SET_B         21
`define BIT_CLR_B         22
`define BIT_SET_C         23
`define BIT_CLR_C         24
`define BIT_CLR_V         25

// =============== EXECUTION PHASE CONSTANTS =======================
`define ST_FETCH0         3'b000
`define ST_FETCH1         3'b001
`define ST_EXEC0          3'b010
`define ST_EXEC1          3'b011
`define ST_EXEC2          3'b100
`define ST_EXEC3          3'b101
`define ST_DONE           3'b110
