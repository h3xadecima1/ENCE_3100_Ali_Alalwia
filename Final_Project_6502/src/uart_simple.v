// ============================================================
// Project     : 6502 FPGA Processor System
// File        : uart_simple.v
// Description : Basic UART I/O
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

//-------------------------------------------------------------
// Simple UART (115200 baud @ 50 MHz)
//-------------------------------------------------------------
module uart_simple (
    input  wire clk,          // 50 MHz FPGA clock
    input  wire reset_n,
    input  wire rx,           // from USB-UART TX
    output wire tx,           // to USB-UART RX

    // RX interface
    output reg  [7:0] rx_data,
    output reg        rx_ready,
    // TX interface
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx_busy
);
    //---------------------------------------------------------
    // Baud-rate generator (50 MHz / 115200 ≈ 434)
    //---------------------------------------------------------
    localparam BAUD_DIV = 434;
    reg [8:0] baud_cnt;
    always @(posedge clk or negedge reset_n)
        if (!reset_n) baud_cnt <= 0;
        else if (baud_cnt == BAUD_DIV) baud_cnt <= 0;
        else baud_cnt <= baud_cnt + 1'b1;

    //---------------------------------------------------------
    // Transmitter
    //---------------------------------------------------------
    reg [3:0] tx_bit = 0;
    reg [9:0] tx_shift = 10'h3FF;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tx_bit <= 0; tx_busy <= 0; tx_shift <= 10'h3FF;
        end else if (!tx_busy && tx_start) begin
            tx_shift <= {1'b1, tx_data, 1'b0};  // start + 8 bits + stop
            tx_busy  <= 1;  tx_bit <= 0;
        end else if (tx_busy && baud_cnt == BAUD_DIV) begin
            tx_bit   <= tx_bit + 1;
            tx_shift <= {1'b1, tx_shift[9:1]};
            if (tx_bit == 9) tx_busy <= 0;
        end
    end
    assign tx = tx_shift[0];

    //---------------------------------------------------------
    // Receiver (very simple, polling-friendly)
    //---------------------------------------------------------
    reg [3:0] rx_bit = 0;
    reg [9:0] rx_shift;
    reg [1:0] rx_sync;
    reg       rx_busy = 0;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_ready <= 0; rx_busy <= 0;
        end else begin
            rx_sync <= {rx_sync[0], rx};
            rx_ready <= 0;
            if (!rx_busy && rx_sync[1]==0) begin
                rx_busy <= 1; rx_bit <= 0;
            end else if (rx_busy && baud_cnt==BAUD_DIV/2) begin
                rx_bit <= rx_bit + 1;
                rx_shift <= {rx_sync[1], rx_shift[9:1]};
                if (rx_bit == 9) begin
                    rx_busy <= 0;
                    rx_data  <= rx_shift[8:1];
                    rx_ready <= 1;
                end
            end
        end
    end
endmodule
