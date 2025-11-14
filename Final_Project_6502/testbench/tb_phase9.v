// ===============================================================
// Testbench: tb_phase9.v (Apple-1 WozMon Firmware Simulation)
// Target:    6502 CPU (main.v top-level)
// ===============================================================

`timescale 1ns/1ps
`default_nettype none

module tb_phase9;

    // ------------------------------------------------------------
    // Clock and Reset
    // ------------------------------------------------------------
    reg clk = 0;
    reg reset_n = 0;

    wire [15:0] address_bus;
    wire [7:0]  data_bus;
    wire mem_read, mem_write;
    wire [7:0] dbg_A, dbg_X, dbg_Y, dbg_P;
    wire [15:0] dbg_PC;

    // ------------------------------------------------------------
    // Instantiate main 6502 core
    // ------------------------------------------------------------
    main uut (
        .clk(clk),
        .reset_n(reset_n),
        .rdy(1'b1),
        .address_bus(address_bus),
        .data_bus(data_bus),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .dbg_A(dbg_A),
        .dbg_X(dbg_X),
        .dbg_Y(dbg_Y),
        .dbg_P(dbg_P),
        .dbg_PC(dbg_PC)
    );

    // ------------------------------------------------------------
    // Clock generator (100 MHz)
    // ------------------------------------------------------------
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // ROM Loader – loads Apple 1 Monitor (WozMon)
    // ------------------------------------------------------------
    rom_loader #(
        .FILENAME("6502_functional_test.hex"),
        .BASE_ADDR(16'hFF00)
    ) u_romload (
        .memory(uut.u_memif.memory)
    );

    // ------------------------------------------------------------
    // Patch Reset Vector to $FF00
    // ------------------------------------------------------------
    initial begin
        #5000;
        uut.u_memif.memory[16'hFFFC] = 8'h00; // low
        uut.u_memif.memory[16'hFFFD] = 8'hFF; // high
        $display("[RESET VECTOR PATCHED] => Start Address = $FF00");
    end

    // ------------------------------------------------------------
    // Reset sequence
    // ------------------------------------------------------------
    initial begin
        $display("\n===================================");
        $display("6502 CPU SIMULATION — WOZMON MODE");
        $display("===================================\n");

        reset_n = 0;
        #100;
        reset_n = 1;
        $display("[T=%0t ns] RESET released.", $time);
    end

    // ------------------------------------------------------------
    // Enhanced Trace Logger
    // ------------------------------------------------------------
    integer trace_fd;
    reg [15:0] prev_pc;
    integer cycle = 0;

    initial begin
        trace_fd = $fopen("trace.log", "w");
        $fwrite(trace_fd, "TIME(ns)   PC   OPC  INSTR                A   X   Y   P   (Cycles)\n");
        $fwrite(trace_fd, "--------------------------------------------------------------\n");
        prev_pc = 16'hFFFF;
    end

    always @(posedge clk) begin
        if (reset_n) begin
            cycle <= cycle + 1;
            if (dbg_PC != prev_pc && mem_read) begin
                prev_pc <= dbg_PC;
                $fwrite(trace_fd,
                    "%08dns  %04h  %02h  %-20s  A=%02h X=%02h Y=%02h P=%02h  (%0d cycles)\n",
                    $time, dbg_PC,
                    uut.u_memif.memory[dbg_PC],
                    format_instruction(dbg_PC, uut.u_memif.memory[dbg_PC]),
                    dbg_A, dbg_X, dbg_Y, dbg_P,
                    opcode_cycles(uut.u_memif.memory[dbg_PC])
                );
            end
        end
    end

    // ------------------------------------------------------------
    // Stop simulation after 2 ms, dump memory
    // ------------------------------------------------------------
    initial begin
        #2000000; // 2 ms sim
        $display("\n===================================");
        $display("6502 SIMULATION COMPLETE");
        $display("===================================");
        $display("Trace written to trace.log");
        $display("Memory snapshot saved to memory_dump.hex");
        $display("===================================\n");
        $writememh("memory_dump.hex", uut.u_memif.memory);
        $finish;
    end

    // ------------------------------------------------------------
    // Instruction Mnemonics
    // ------------------------------------------------------------
    function [128*8:1] format_instruction;
        input [15:0] pc;
        input [7:0] opcode;
        begin
            case (opcode)
                8'hA9: format_instruction = "LDA #imm";
                8'hA2: format_instruction = "LDX #imm";
                8'hA0: format_instruction = "LDY #imm";
                8'h85: format_instruction = "STA zp";
                8'h20: format_instruction = "JSR abs";
                8'h4C: format_instruction = "JMP abs";
                8'h00: format_instruction = "BRK";
                8'hEA: format_instruction = "NOP";
                default: format_instruction = "???";
            endcase
        end
    endfunction

    // ------------------------------------------------------------
    // Opcode Cycle Timing Table
    // ------------------------------------------------------------
    function integer opcode_cycles;
        input [7:0] opcode;
        begin
            case (opcode)
                // Load/Store
                8'hA9,8'hA2,8'hA0: opcode_cycles = 2;
                8'h85: opcode_cycles = 3;
                // Jump/Branch
                8'h20: opcode_cycles = 6;
                8'h4C: opcode_cycles = 3;
                8'h00: opcode_cycles = 7;
                8'hEA: opcode_cycles = 2;
                default: opcode_cycles = 2;
            endcase
        end
    endfunction

endmodule
`default_nettype wire
