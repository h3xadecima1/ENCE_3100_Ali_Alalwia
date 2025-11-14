// ============================================================
// Project     : 6502 FPGA Processor System
// File        : interrupt_logic.v
// Description : IRQ/NMI/RES vector logic
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

module interrupt_logic (
    input  wire clk,
    input  wire reset_n,
    input  wire irq_n,
    input  wire nmi_n,
    input  wire [7:0] P,
    output reg  take_irq,
    output reg  take_nmi
);
    reg nmi_prev;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            take_irq <= 0;
            take_nmi <= 0;
            nmi_prev <= 1;
        end else begin
            // IRQ triggers if I flag clear (bit 2 = 0)
            take_irq <= (!irq_n && !P[2]);

            // NMI triggers on falling edge
            take_nmi <= (nmi_prev && !nmi_n);
            nmi_prev <= nmi_n;
        end
    end
endmodule

`default_nettype wire
