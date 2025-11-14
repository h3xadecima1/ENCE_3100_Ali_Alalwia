`timescale 1ns/1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : memory_interface.v
// Description : External memory bus control
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
// Memory interface with UART output ($D012) and VGA video RAM ($E000–$E3FF)
// Compatible with uart_simple.v (115200 baud @ 50 MHz)
// TX → GPIO[33] (USB dongle RX), RX → GPIO[35] (USB dongle TX), GND → JP(30)
// VGA access via vga_addr / vga_data ports
// ================================================================
module memory_interface (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] address,
    output reg  [7:0]  data_out,
    input  wire        mem_read_req,
    input  wire        mem_write_req,
    inout  wire [7:0]  data_bus,
    input  wire        uart_rx,   // from PC
    output wire        uart_tx,   // to PC

    // VGA interface (external read-only)
    input  wire [10:0] vga_addr,  // VGA address from VGA controller
    output wire [7:0]  vga_data   // Character data to VGA controller
);

    // --------------------------------------------------------
    // 2 KB General RAM ($0000–$07FF)
    // 1 KB Video RAM ($E000–$E3FF)
    // --------------------------------------------------------
    reg [7:0] ram  [0:2047];
    reg [7:0] vram [0:1023];

    // --------------------------------------------------------
    // ROM program (loaded from hex/bin file)
    // --------------------------------------------------------
    wire [7:0] rom_data;
    rom_program u_rom (
        .address(address),
        .data_out(rom_data)
    );

    // --------------------------------------------------------
    // UART (simple transmitter/receiver @115200 baud)
    // --------------------------------------------------------
    wire [7:0] rx_data;
    wire       rx_ready;
    reg  [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    uart_simple u_uart (
        .clk(clk),
        .reset_n(reset_n),
        .rx(uart_rx),
        .tx(uart_tx),
        .rx_data(rx_data),
        .rx_ready(rx_ready),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy)
    );

    // --------------------------------------------------------
    // Memory map:
    // --------------------------------------------------------
    // $0000–$07FF  → General RAM
    // $C000–$FFFF  → ROM
    // $D010        → UART RX register
    // $D012        → UART TX register
    // $E000–$E3FF  → Video RAM (VGA text)
    // --------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out <= 8'h00;
            tx_start <= 1'b0;
        end else begin
            tx_start <= 1'b0; // default

            if (mem_read_req) begin
                // ------------------- READ -------------------
                if (address < 16'h0800)
                    data_out <= ram[address];
                else if (address == 16'hD010)
                    data_out <= rx_ready ? rx_data : 8'h00;
                else if (address >= 16'hE000 && address < 16'hE400)
                    data_out <= vram[address - 16'hE000];
                else if (address >= 16'hC000)
                    data_out <= rom_data;
                else
                    data_out <= 8'hFF;
            end 
            else if (mem_write_req) begin
                // ------------------- WRITE -------------------
                if (address < 16'h0800)
                    ram[address] <= data_out;

                else if (address == 16'hD012 && !tx_busy) begin
                    tx_data  <= data_out;
                    tx_start <= 1'b1;
                end

                else if (address >= 16'hE000 && address < 16'hE400)
                    vram[address - 16'hE000] <= data_out; // VGA text buffer
            end
        end
    end

    // --------------------------------------------------------
    // VGA external read access (read-only)
    // --------------------------------------------------------
    assign vga_data = vram[vga_addr];

endmodule
`default_nettype wire
