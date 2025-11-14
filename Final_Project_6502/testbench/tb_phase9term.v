// ===============================================================
// Testbench: tb_phase9term_full.v
// Purpose  : Fully simulate Apple-1 WozMon with simple terminal I/O
// ===============================================================

`timescale 1ns / 1ps
`default_nettype none

module tb_phase9term_full;

    // ------------------------------
    // Clock / Reset
    // ------------------------------
    reg clk = 0;
    reg reset_n = 0;
    always #5 clk = ~clk;

    wire [15:0] address_bus;
    wire [7:0]  data_bus;
    wire mem_read, mem_write;
    wire [7:0] dbg_A, dbg_X, dbg_Y, dbg_P;
    wire [15:0] dbg_PC;

    // ------------------------------
    // Instantiate CPU core
    // ------------------------------
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

    // ------------------------------
    // ROM loader for WozMon
    // ------------------------------
    rom_loader #(
        .FILENAME("wozmon.bin"),
        .BASE_ADDR(16'hFF00)
    ) u_romload (
        .memory(uut.u_memif.memory)
    );

    // ------------------------------
    // Patch reset vector to $FF00
    // ------------------------------
    initial begin
        #2000;
        uut.u_memif.memory[16'hFFFC] = 8'h00;
        uut.u_memif.memory[16'hFFFD] = 8'hFF;
        $display("[RESET VECTOR PATCHED] => Start Address = $FF00");
    end

    // ------------------------------
    // Keyboard & Display addresses
    // ------------------------------
    localparam KEYBOARD_IN  = 16'hD010;
    localparam DISPLAY_OUT  = 16'hD012;

    // Simulated keyboard input buffer
    reg [7:0] keyboard [0:15];
    integer kptr = 0;

    initial begin
        // Input “E000R<CR><CR>” to dump memory at E000
        keyboard[0] = "E";
        keyboard[1] = "0";
        keyboard[2] = "0";
        keyboard[3] = "0";
        keyboard[4] = "R";
        keyboard[5] = 8'h0D; // carriage return
        keyboard[6] = 8'h0D;
        keyboard[7] = 8'h00;
    end

    // Feed next key on read from D010
    always @(posedge clk) begin
        if (mem_read && address_bus == KEYBOARD_IN) begin
            uut.u_memif.memory[KEYBOARD_IN] = keyboard[kptr];
            if (keyboard[kptr] != 8'h00)
                kptr <= kptr + 1;
        end
    end

    // Print output chars written to D012
    always @(posedge clk) begin
        if (mem_write && address_bus == DISPLAY_OUT)
            $write("%c", uut.u_memif.memory[address_bus]);
    end

    // ------------------------------
    // Reset and run
    // ------------------------------
    initial begin
        $display("\n===================================");
        $display("APPLE-1 WOZMON TERMINAL SIMULATION");
        $display("===================================\n");
        reset_n = 0;
        #100;
        reset_n = 1;
        $display("[T=%0t ns] RESET released — Booting WOZMON...", $time);
    end

    // ------------------------------
    // Stop after some time
    // ------------------------------
    initial begin
        #10_000_000; // 10 ms
        $display("\n===================================");
        $display("WOZMON TERMINAL SIMULATION COMPLETE");
        $display("===================================");
        $writememh("memory_dump.hex", uut.u_memif.memory);
        $finish;
    end

endmodule
`default_nettype wire
