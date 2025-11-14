`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : main_fpga.v
// Description : Top Level Wrapper
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

module main_fpga (
    input  wire CLOCK_50,      // 50 MHz base clock
    input  wire [1:0] KEY,     // KEY[0]=Reset, KEY[1]=Step
    input  wire [9:0] SW,      // SW[0]=Run/Step
    output wire [9:0] LEDR,    // LEDs for A + activity
    output wire [6:0] HEX0, HEX1, HEX2, HEX3,
    inout  wire [35:0] GPIO,   // GPIO header (33=TX, 35=RX)
    // VGA signals
    output wire VGA_HS, VGA_VS,
    output wire [3:0] VGA_R, VGA_G, VGA_B
);

    // ------------------------------------------------------------
    // Reset and Clock Setup
    // ------------------------------------------------------------
    wire reset_n   = KEY[0];      // active-high reset
    wire step_mode = SW[0];       // 1 = manual step, 0 = auto
    wire clk_run;
    wire clk_step;
    wire clk_sys;

    // Slow 1 Hz clock for auto mode (for debugging)
    clock_divider #(.DIVIDER(25_000_000)) u_div (
        .clk_in(CLOCK_50),
        .clk_out(clk_run)
    );

    // One-pulse generator for step button
    step_pulse u_step (
        .clk_in(CLOCK_50),
        .btn(KEY[1]),
        .pulse_out(clk_step)
    );

    // Select CPU clock
    assign clk_sys = (step_mode) ? clk_step : clk_run;

    // ------------------------------------------------------------
    // VGA pixel clock (25.175 MHz via PLL)
    // ------------------------------------------------------------
    wire clk_25;  // 25.175 MHz pixel clock from PLL
    wire pll_locked;

    pll_vga u_pll (
        .inclk0(CLOCK_50),
        .c0(clk_25),
        .locked(pll_locked)
    );

    // Ignore locked (you verified PLL works)
    assign LEDR[0] = 1'b1; // always on (PLL good)

    // ------------------------------------------------------------
    // CPU + Memory + UART + VGA Bus Wiring
    // ------------------------------------------------------------
    wire [15:0] address_bus;
    wire [7:0]  data_bus;
    wire        mem_read;
    wire        mem_write;
    wire        rdy = 1'b1;

    wire [7:0]  dbg_A, dbg_X, dbg_Y, dbg_P;
    wire [15:0] dbg_PC;

    wire uart_tx_sig;

    wire [10:0] vga_addr;
    wire [7:0]  vga_data;

    // ------------------------------------------------------------
    // Memory Interface (RAM + ROM + UART + VRAM)
    // ------------------------------------------------------------
    memory_interface u_memif (
        .clk(clk_sys),
        .reset_n(reset_n),
        .address(address_bus),
        .data_out(data_bus),
        .mem_read_req(mem_read),
        .mem_write_req(mem_write),
        .data_bus(data_bus),
        .uart_rx(GPIO[35]),       // from USB dongle
        .uart_tx(uart_tx_sig),    // to USB dongle
        .vga_addr(vga_addr),
        .vga_data(vga_data)
    );

    // UART TX → GPIO[33]
    assign GPIO[33] = uart_tx_sig;

    // ------------------------------------------------------------
    // 6502 CPU Core Wrapper
    // ------------------------------------------------------------
    main u_main (
        .clk(clk_sys),
        .reset_n(reset_n),
        .rdy(rdy),
        .address_bus(address_bus),
        .data_bus(data_bus),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .dbg_A(dbg_A),
        .dbg_X(dbg_X),
        .dbg_Y(dbg_Y),
        .dbg_P(dbg_P),
        .dbg_PC(dbg_PC),
        .dbg_opcode(),
        .dbg_phase(),
        .dbg_addr(),
        .dbg_rw()
    );

    // ------------------------------------------------------------
    // VGA Display Controller (Text Mode)
    // ------------------------------------------------------------
    vga_text u_vga (
        .clk_25mhz(clk_25),
        .reset_n(reset_n),
        .vram_addr(vga_addr),
        .vram_data(vga_data),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .vga_r(VGA_R),
        .vga_g(VGA_G),
        .vga_b(VGA_B)
    );

    // ------------------------------------------------------------
    // LEDs and HEX display for debugging
    // ------------------------------------------------------------
    assign LEDR[9]   = mem_write;
    assign LEDR[8]   = mem_read;
    assign LEDR[7:1] = dbg_A[6:0];

    hex_display u_hex0 (.value(dbg_PC[3:0]),   .segments(HEX0));
    hex_display u_hex1 (.value(dbg_PC[7:4]),   .segments(HEX1));
    hex_display u_hex2 (.value(dbg_PC[11:8]),  .segments(HEX2));
    hex_display u_hex3 (.value(dbg_PC[15:12]), .segments(HEX3));

endmodule
`default_nettype wire
