`timescale 1ns / 1ps
`default_nettype none

// ======================================================
// UART Debugger for DE10-Lite
// Sends "A=5 B=3 S=8 C=0" via UART (115200 baud)
// Triggered on each rising edge of manual step clock (SW9)
// ======================================================
module UART_Debugger #(
    parameter CLK_FREQ = 50000000, // 50 MHz system clock
    parameter BAUD     = 115200
)(
    input  wire        clk_fast,   // system clock (50 MHz)
    input  wire        clk_step,   // manual step pulse (from SW9)
    input  wire [3:0]  A,          // Accumulator A
    input  wire [3:0]  B,          // Accumulator B
    input  wire [3:0]  BUS,        // ALU result or internal bus
    input  wire        CARRY,      // carry flag
    output wire        uart_tx     // serial output
);

    // --------------------------------------------------
    // UART Transmitter instance
    // --------------------------------------------------
    wire tx_busy;
    reg  tx_start = 0;
    reg  [7:0] tx_data = 8'd0;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) UART_TX (
        .clk(clk_fast),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(uart_tx),
        .tx_busy(tx_busy)
    );

    // --------------------------------------------------
    // Helper: Nibble to ASCII (0–9 → '0'–'9', A–F → 'A'–'F')
    // --------------------------------------------------
    function [7:0] nibble_to_ascii(input [3:0] nib);
        begin
            if (nib < 10)
                nibble_to_ascii = 8'd48 + nib;  // '0'–'9'
            else
                nibble_to_ascii = 8'd55 + nib;  // 'A'–'F'
        end
    endfunction

    // --------------------------------------------------
    // Edge detector for SW9 clock pulse
    // --------------------------------------------------
    reg prev_step = 0;
    reg trigger_send = 0;
    always @(posedge clk_fast) begin
        prev_step   <= clk_step;
        trigger_send <= (clk_step && !prev_step); // rising edge detect
    end

    // --------------------------------------------------
    // UART Send FSM
    // --------------------------------------------------
    reg [7:0] buffer [0:31];
    reg [5:0] index = 0;
    reg [2:0] state = 0;
    reg [15:0] idle_counter = 0;

    always @(posedge clk_fast) begin
        case (state)
            //---------------------------------------------------
            // State 0: Wait for rising edge (manual clock pulse)
            //---------------------------------------------------
            0: begin
                tx_start <= 0;
                if (trigger_send && !tx_busy) begin
                    // Build message string: "A=5 B=3 S=8 C=0\r\n"
                    buffer[0]  <= "A";
                    buffer[1]  <= "=";
                    buffer[2]  <= nibble_to_ascii(A);
                    buffer[3]  <= " ";
                    buffer[4]  <= "B";
                    buffer[5]  <= "=";
                    buffer[6]  <= nibble_to_ascii(B);
                    buffer[7]  <= " ";
                    buffer[8]  <= "S";
                    buffer[9]  <= "=";
                    buffer[10] <= nibble_to_ascii(BUS);
                    buffer[11] <= " ";
                    buffer[12] <= "C";
                    buffer[13] <= "=";
                    buffer[14] <= (CARRY) ? "1" : "0";
                    buffer[15] <= "\r";
                    buffer[16] <= "\n";
                    buffer[17] <= 8'd0; // string terminator
                    index <= 0;
                    state <= 1;
                end
            end

            //---------------------------------------------------
            // State 1: Send one byte at a time
            //---------------------------------------------------
            1: begin
                if (!tx_busy) begin
                    if (buffer[index] != 8'd0) begin
                        tx_data  <= buffer[index];
                        tx_start <= 1'b1;
                        index    <= index + 1;
                    end else begin
                        tx_start <= 0;
                        state    <= 2; // Done sending
                    end
                end else begin
                    tx_start <= 0;
                end
            end

            //---------------------------------------------------
            // State 2: Small delay before next trigger
            //---------------------------------------------------
            2: begin
                idle_counter <= idle_counter + 1;
                if (idle_counter > 16'd2000) begin
                    idle_counter <= 0;
                    state <= 0;
                end
            end
        endcase
    end

endmodule

`default_nettype wire
