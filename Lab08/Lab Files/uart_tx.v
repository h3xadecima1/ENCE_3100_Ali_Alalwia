`timescale 1ns / 1ps
`default_nettype none

// ======================================================
// UART Transmitter for DE10-Lite
// 8N1 protocol (1 start, 8 data, 1 stop)
// Parameters:
//   CLK_FREQ = System clock frequency in Hz (50 MHz default)
//   BAUD     = UART baud rate (115200 default)
// ======================================================
module uart_tx #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD     = 115200
)(
    input  wire clk,             // 50 MHz system clock
    input  wire tx_start,        // trigger signal (one pulse)
    input  wire [7:0] tx_data,   // byte to transmit
    output reg  tx = 1'b1,       // UART TX line (idle = high)
    output reg  tx_busy = 1'b0   // high while sending data
);

    // --------------------------------------------------
    // Baud Rate Generator
    // --------------------------------------------------
    localparam integer BAUD_DIV = CLK_FREQ / BAUD; // number of cycles per bit
    reg [15:0] baud_cnt = 0;
    reg baud_tick = 0;

    always @(posedge clk) begin
        if (tx_busy) begin
            if (baud_cnt >= BAUD_DIV - 1) begin
                baud_cnt <= 0;
                baud_tick <= 1;
            end else begin
                baud_cnt <= baud_cnt + 1;
                baud_tick <= 0;
            end
        end else begin
            baud_cnt <= 0;
            baud_tick <= 0;
        end
    end

    // --------------------------------------------------
    // UART Transmission State Machine
    // --------------------------------------------------
    reg [3:0] bit_index = 0;
    reg [9:0] tx_shift = 10'b1111111111; // 1 stop bit + 8 data + 1 start bit

    always @(posedge clk) begin
        if (!tx_busy) begin
            if (tx_start) begin
                // Frame: {Stop(1), Data[7:0], Start(0)}
                tx_shift <= {1'b1, tx_data, 1'b0};
                tx_busy <= 1'b1;
                bit_index <= 0;
            end
        end else if (baud_tick) begin
            tx <= tx_shift[0];                // transmit LSB first
            tx_shift <= {1'b1, tx_shift[9:1]}; // shift right, fill with stop bit
            bit_index <= bit_index + 1;

            if (bit_index == 9) begin
                tx_busy <= 1'b0;              // done sending
                tx <= 1'b1;                   // idle high
            end
        end
    end

endmodule

`default_nettype wire
