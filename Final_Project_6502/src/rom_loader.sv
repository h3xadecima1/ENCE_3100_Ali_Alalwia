`timescale 1ns/1ps
`default_nettype none
// ============================================================
// Project     : 6502 FPGA Processor System
// File        : rom_loader.v
// Description : Loads HEX files into ROM/RAM
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

module rom_loader #( 
    parameter FILENAME = "program.hex", 
    parameter BASE_ADDR = 16'h0000 
) (
    // Simulation-only interface
`ifndef SYNTHESIS
    output reg [7:0] memory [0:65535]
`endif
);
`ifndef SYNTHESIS
    integer fd, code, i;
    reg [7:0] temp;

    initial begin
        fd = $fopen(FILENAME, "rb");
        if (fd == 0) begin
            $display("ERROR: Could not open file %s", FILENAME);
            $finish;
        end

        i = 0;
        while (!$feof(fd)) begin
            code = $fread(temp, fd);
            memory[BASE_ADDR + i] = temp;
            i = i + 1;
        end
        $fclose(fd);
        $display("ROM loaded from %s at base address %h", FILENAME, BASE_ADDR);
    end
`endif
endmodule

`default_nettype wire
