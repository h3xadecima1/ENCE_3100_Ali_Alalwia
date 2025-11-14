`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : main.v
// Description : Top-level CPU integration
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
// MAIN — 6502 CPU Top-Level Integration (tb_main + FPGA + VGA compatible)
// ================================================================

module main (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        rdy,

    // External buses
    output wire [15:0] address_bus,
    output wire [7:0]  data_bus,
    output wire        mem_read,
    output wire        mem_write,

    // Debug outputs
    output wire [7:0]  dbg_A,
    output wire [7:0]  dbg_X,
    output wire [7:0]  dbg_Y,
    output wire [7:0]  dbg_P,
    output wire [15:0] dbg_PC,
    output wire [7:0]  dbg_opcode,
    output wire [2:0]  dbg_phase,
    output wire [15:0] dbg_addr,
    output wire        dbg_rw
);

    // ------------------------------------------------------------
    // Internal Signals
    // ------------------------------------------------------------
    wire [7:0]  alu_result;
    wire [3:0]  alu_op;
    wire [7:0]  A_out, X_out, Y_out, P_out, SP_out;
    wire [15:0] PC_out;
    wire [7:0]  data_in;
    wire        mem_read_req, mem_write_req;
    wire        alu_C, alu_V;
    wire        load_A, load_X, load_Y, load_P, load_SP, load_PC;
    wire        inc_PC, dec_SP, inc_SP;
    wire [7:0]  opcode;
    reg  [7:0]  opcode_latch;
    wire        take_irq, take_nmi;

    // VGA internal stubs
    wire [10:0] vga_addr;
    wire [7:0]  vga_data;

    // ------------------------------------------------------------
    // MEMORY INTERFACE
    // ------------------------------------------------------------
    memory_interface u_memif (
        .clk(clk),
        .reset_n(reset_n),
        .address(PC_out),
        .data_out(data_in),
        .mem_read_req(mem_read_req),
        .mem_write_req(mem_write_req),
        .data_bus(data_bus),

        // Simulation stubs for UART
        .uart_rx(1'b1),   // idle high line
        .uart_tx(),       // unconnected

        // VGA interface (added to fix port mismatch)
        .vga_addr(vga_addr),
        .vga_data(vga_data)
    );

    // Tie VGA data to zero until connected
    assign vga_data = 8'h00;

    // ------------------------------------------------------------
    // REGISTER FILE
    // ------------------------------------------------------------
    register_file u_regfile (
        .clk(clk),
        .reset_n(reset_n),
        .load_A(load_A),
        .load_X(load_X),
        .load_Y(load_Y),
        .load_P(load_P),
        .load_SP(load_SP),
        .load_PC(load_PC),
        .inc_PC(inc_PC),
        .dec_SP(dec_SP),
        .inc_SP(inc_SP),
        .data_in(data_in),
        .alu_result(alu_result),

        // Flag control stubs
        .set_NZVC(1'b0),
        .set_D(1'b0),
        .clr_D(1'b0),
        .set_I(1'b0),
        .clr_I(1'b0),
        .set_B(1'b0),
        .clr_B(1'b0),
        .set_C(1'b0),
        .clr_C(1'b0),

        .alu_C(alu_C),
        .alu_V(alu_V),

        .A_out(A_out),
        .X_out(X_out),
        .Y_out(Y_out),
        .P_out(P_out),
        .SP_out(SP_out),
        .PC_out(PC_out),

        .N_flag(),
        .V_flag(),
        .D_flag(),
        .I_flag(),
        .Z_flag(),
        .C_flag()
    );

    // ------------------------------------------------------------
    // ALU
    // ------------------------------------------------------------
    alu u_alu (
        .A(A_out),
        .B(X_out),
        .alu_op(alu_op),
        .C_flag_in(P_out[0]),
        .result(alu_result),
        .C_flag_out(alu_C),
        .Z_flag_out(),
        .V_flag_out(alu_V),
        .N_flag_out()
    );

    // ------------------------------------------------------------
    // INTERRUPT LOGIC
    // ------------------------------------------------------------
    interrupt_logic u_irq (
        .clk(clk),
        .reset_n(reset_n),
        .irq_n(1'b1),
        .nmi_n(1'b1),
        .P(P_out),
        .take_irq(take_irq),
        .take_nmi(take_nmi)
    );

    // ------------------------------------------------------------
    // CONTROL UNIT
    // ------------------------------------------------------------
    control_unit u_ctrl (
        .clk(clk),
        .reset_n(reset_n),
        .rdy(rdy),
        .opcode(opcode_latch),
        .alu_op(alu_op),
        .mem_read_req(mem_read_req),
        .mem_write_req(mem_write_req),
        .load_A(load_A),
        .load_X(load_X),
        .load_Y(load_Y),
        .load_P(load_P),
        .load_SP(load_SP),
        .load_PC(load_PC),
        .inc_PC(inc_PC),
        .dec_SP(dec_SP),
        .inc_SP(inc_SP),
        .cycle_count(),      // optional
        .addr_mode_code()    // optional
    );

    // ------------------------------------------------------------
    // OPCODE FETCH & LATCH
    // ------------------------------------------------------------
    assign opcode = data_in;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            opcode_latch <= 8'h00;
        else if (mem_read_req)
            opcode_latch <= opcode;
    end

    // ------------------------------------------------------------
    // Debug / External
    // ------------------------------------------------------------
    assign address_bus = PC_out;
    assign data_bus    = data_in;
    assign mem_read    = mem_read_req;
    assign mem_write   = mem_write_req;

    assign dbg_A       = A_out;
    assign dbg_X       = X_out;
    assign dbg_Y       = Y_out;
    assign dbg_P       = P_out;
    assign dbg_PC      = PC_out;
    assign dbg_opcode  = opcode_latch;

    assign dbg_phase   = 3'b000;
    assign dbg_addr    = address_bus;
    assign dbg_rw      = mem_read_req & ~mem_write_req;

endmodule
`default_nettype wire
