`timescale 1ns / 1ps
`default_nettype none
// ================================================================
// TESTBENCH – PHASE 8 (Full Loop Program with Branch)
// Simulation-only version — safe for Quartus synthesis
// ================================================================
module tb_phase8;

`ifndef SYNTHESIS   // <---- Quartus will ignore everything inside

    // ------------------------------------------------------------
    // Clock / Reset / Interrupts
    // ------------------------------------------------------------
    reg clk = 0;
    reg reset_n = 0;
    reg rdy = 1;
    reg irq_n = 1;
    reg nmi_n = 1;

    wire [15:0] address_bus;
    wire [7:0]  data_bus;
    wire        mem_read;
    wire        mem_write;
    wire [7:0]  dbg_A, dbg_X, dbg_Y, dbg_P;
    wire [15:0] dbg_PC;

    // ------------------------------------------------------------
    // DUT (Device Under Test)
    // ------------------------------------------------------------
    main uut (
        .clk(clk),
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
        .dbg_PC(dbg_PC)
    );

    // ------------------------------------------------------------
    // ROM Program
    // ------------------------------------------------------------
    wire [7:0] rom_data;
    rom_program prog_rom (
        .address(address_bus),
        .data_out(rom_data)
    );

    // ------------------------------------------------------------
    // Hook ROM into memory interface (read path)
    // ------------------------------------------------------------
    // This dynamic assignment is valid for simulation only.
    always @(*) begin
        uut.u_memif.memory[address_bus] = rom_data;
    end

    // ------------------------------------------------------------
    // Clock Generator
    // ------------------------------------------------------------
    always #5 clk = ~clk;   // 100 MHz clock

    // ------------------------------------------------------------
    // Simulation Routine
    // ------------------------------------------------------------
    integer cycle = 0;
    event finish_sim;

    initial begin : sim_loop
        $display("\n===============================");
        $display("6502 LOOP PROGRAM SIMULATION START");
        $display("===============================\n");

        // Reset sequence
        reset_n = 0;
        #100;
        reset_n = 1;
        $display("[T=%0t ns] RESET released. CPU starting at PC=%04h\n", $time, dbg_PC);

        // Run until BRK or 200 cycles
        for (cycle = 0; cycle < 200; cycle = cycle + 1) begin
            @(posedge clk);
            $display("T=%04dns | PC=%04h A=%02h P=%02h MEM[0200]=%02h",
                     $time, dbg_PC, dbg_A, dbg_P, uut.u_memif.memory[16'h0200]);
            if (uut.u_memif.memory[16'h0200] == 8'h0A) begin
                $display("\nLoop completed successfully (A reached 0x0A)\n");
                ->finish_sim;   // trigger end event
                disable sim_loop;
            end
        end
        ->finish_sim;   // safety trigger after loop ends
    end

    // ------------------------------------------------------------
    // Finish Event Handler
    // ------------------------------------------------------------
    initial begin
        @finish_sim;
        $display("\n===============================");
        $display("6502 SIMULATION COMPLETE");
        $display("===============================");
        $display("FINAL STATE: PC=%04h A=%02h X=%02h Y=%02h P=%02h MEM[0200]=%02h",
                 dbg_PC, dbg_A, dbg_X, dbg_Y, dbg_P, uut.u_memif.memory[16'h0200]);
        $finish;
    end

`endif // SYNTHESIS

endmodule
`default_nettype wire
