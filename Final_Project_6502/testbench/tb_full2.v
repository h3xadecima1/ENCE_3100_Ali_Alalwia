`timescale 1ns/1ps
`default_nettype none
// ================================================================
// Apple-1 (A-ONE) 6502 CPU Simulation Testbench
// Continuous-run version (ModelSim compatible)
// ================================================================
module tb_full2;

    // ============================================================
    // Clock & Reset
    // ============================================================
    reg clk = 0;
    reg reset_n = 0;

    // 1 MHz clock (period = 1 µs = 1000 ns)
    always #500 clk = ~clk;

    // ============================================================
    // CPU Debug / Bus Wires
    // ============================================================
    wire [15:0] address_bus, dbg_PC, dbg_addr;
    wire [7:0]  data_bus, dbg_A, dbg_X, dbg_Y, dbg_P, dbg_opcode;
    wire [2:0]  dbg_phase;
    wire        dbg_rw;
    wire        mem_read, mem_write;

    // ============================================================
    // Instantiate 6502 Top-Level
    // ============================================================
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
        .dbg_PC(dbg_PC),
        .dbg_opcode(dbg_opcode),
        .dbg_phase(dbg_phase),
        .dbg_addr(dbg_addr),
        .dbg_rw(dbg_rw)
    );

    // ============================================================
    // Simulation Control
    // ============================================================
    initial begin
        $display("=== Starting 6502 A-ONE (Apple-1) Simulation ===");
        $display("ROM expected: vwoz.hex");
        reset_n = 0;
        #2000;
        reset_n = 1;
        $display("=== Reset Released ===");

        // Run indefinitely (can break manually in ModelSim)
        forever begin
            #1000000; // 1 ms tick
        end
    end

    // ============================================================
    // Instruction Trace (optional, comment to speed sim)
    // ============================================================
    reg [15:0] last_PC;
    always @(posedge clk) begin
        if (reset_n && (dbg_PC != last_PC)) begin
            $display("PC=%04h  OPC=%02h  A=%02h X=%02h Y=%02h P=%02h",
                      dbg_PC, dbg_opcode, dbg_A, dbg_X, dbg_Y, dbg_P);
            last_PC <= dbg_PC;
        end
    end

    // ============================================================
    // UART Output Monitor (Wozmon output at $D012)
    // ============================================================
    always @(posedge clk) begin
        if (uut.u_memif.mem_write_req && uut.u_memif.address == 16'hD012) begin
            $write("%c", uut.u_memif.data_out);
        end
    end

    // ============================================================
    // Keyboard Input Simulation
    // ============================================================
    integer fin;
    reg [7:0] char_in;

    initial begin
        fin = $fopen("input.txt", "r");
        if (fin)
            $display("[INFO] Keyboard input file 'input.txt' opened successfully.");
        else
            $display("[WARN] input.txt not found. No keyboard input will be sent.");

        // Wait a short time for monitor startup
        #100000; // 100 µs

        while (!$feof(fin)) begin
            char_in = $fgetc(fin);
            if (char_in == 8'h0A) char_in = 8'h0D; // LF → CR
            // Simulate typing into keyboard buffer ($D010)
            uut.u_memif.ram[16'h0010] = char_in;
            $write("%c", char_in);
            #50000; // 50 µs between keystrokes
        end
        $fclose(fin);
    end

endmodule
`default_nettype wire
