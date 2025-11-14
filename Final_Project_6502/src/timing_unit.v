`timescale 1ns / 1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : timing_unit.v
// Description : CPU cycle timing generator
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
// TIMING / INTERRUPT UNIT — NMOS 6502 compatible
// ================================================================
module timing_unit (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        rdy,
    input  wire        irq_n,
    input  wire        nmi_n,

    output reg         irq_pending,
    output reg         nmi_pending,
    output reg         nmi_edge
);
    // Edge detection for NMI (active-low)
    reg nmi_sync, nmi_prev;

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            nmi_sync    <= 1'b1;
            nmi_prev    <= 1'b1;
            nmi_edge    <= 1'b0;
            nmi_pending <= 1'b0;
            irq_pending <= 1'b0;
        end else begin
            // Synchronize and detect NMI falling edge
            nmi_sync <= nmi_n;
            nmi_prev <= nmi_sync;
            if(nmi_prev && !nmi_sync) begin
                nmi_edge    <= 1'b1;
                nmi_pending <= 1'b1;
            end else nmi_edge <= 1'b0;

            // IRQ pending if line is low and not masked
            if(!irq_n) irq_pending <= 1'b1;

            // Simple RDY pause: when rdy = 0, nothing changes externally.
            if(!rdy) begin
                nmi_pending <= nmi_pending; // hold
                irq_pending <= irq_pending; // hold
            end
        end
    end
endmodule
`default_nettype wire
