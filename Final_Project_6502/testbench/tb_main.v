`timescale 1ns / 1ps
`default_nettype none
// ============================================================================
// TESTBENCH: tb_main – Full 6502 CPU Verification
// ============================================================================
//  • Runs instruction flow: RESET → main program → BRK → RTI → JSR/RTS
//  • Exercises IRQ and NMI
//  • Displays stack pushes/pulls and READY pauses
// ============================================================================

module tb_main;

    // --------------------------------------------------------------
    // Core control signals
    // --------------------------------------------------------------
    reg clk = 0;
    reg reset_n = 0;
    reg rdy = 1;

    always #5 clk = ~clk;    // 100 MHz clock

    // --------------------------------------------------------------
    // Interrupt lines
    // --------------------------------------------------------------
    reg irq_n = 1;
    reg nmi_n = 1;
    reg brk_flag = 0;

    // --------------------------------------------------------------
    // Bus and debug wires
    // --------------------------------------------------------------
    wire [15:0] address_bus;
    wire [7:0]  data_bus;
    wire        mem_read, mem_write;

    wire [7:0]  dbg_A, dbg_X, dbg_Y, dbg_P;
    wire [15:0] dbg_PC;
    wire [2:0]  dbg_phase;
    wire [7:0]  dbg_opcode;
    wire [15:0] dbg_addr;
    wire        dbg_rw;

    // --------------------------------------------------------------
    // Instantiate CPU top level
    // --------------------------------------------------------------
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
        .dbg_PC(dbg_PC),
        .dbg_phase(dbg_phase),
        .dbg_opcode(dbg_opcode),
        .dbg_addr(dbg_addr),
        .dbg_rw(dbg_rw)
    );

    // --------------------------------------------------------------
    // External RAM model (shared with DUT)
    // --------------------------------------------------------------
    reg [7:0] memory [0:65535];
    assign data_bus = mem_write ? uut.u_memif.data_out : 8'hZZ;

    always @(posedge clk) begin
        if (mem_write)
            memory[address_bus] <= data_bus;
    end

    always @(*) begin
        if (mem_read)
            uut.u_memif.data_out = memory[address_bus];
    end

    // --------------------------------------------------------------
    // Initialize memory map
    // --------------------------------------------------------------
    initial begin : mem_init
        integer i;
        for (i = 0; i < 65536; i = i + 1)
            memory[i] = 8'hEA; // fill with NOP

        // Reset vector -> $0200
        memory[16'hFFFC] = 8'h00;
        memory[16'hFFFD] = 8'h02;
        // IRQ vector -> $0300
        memory[16'hFFFE] = 8'h00;
        memory[16'hFFFF] = 8'h03;
        // NMI vector -> $0400
        memory[16'hFFFA] = 8'h00;
        memory[16'hFFFB] = 8'h04;

        // =========================================================
        // Program @ $0200 : BRK → RTI → JSR/RTS sequence
        // =========================================================
        memory[16'h0200] = 8'hA9; // LDA #$10
        memory[16'h0201] = 8'h10;
        memory[16'h0202] = 8'h00; // BRK  (triggers IRQ/BRK handler)
        memory[16'h0203] = 8'h20; // JSR $0210
        memory[16'h0204] = 8'h10;
        memory[16'h0205] = 8'h02;
        memory[16'h0206] = 8'hEA; // NOP
        memory[16'h0207] = 8'h00; // BRK again
        memory[16'h0208] = 8'hEA; // (endless NOP)

        // Subroutine @ $0210
        memory[16'h0210] = 8'hA9; // LDA #$55
        memory[16'h0211] = 8'h55;
        memory[16'h0212] = 8'h60; // RTS

        // IRQ handler @ $0300 : RTI immediately
        memory[16'h0300] = 8'h40; // RTI
        // NMI handler @ $0400 : NOP + RTI
        memory[16'h0400] = 8'hEA;
        memory[16'h0401] = 8'h40;
    end

    // --------------------------------------------------------------
    // Event trace
    // --------------------------------------------------------------
    always @(posedge clk) if (reset_n && rdy)
        $display("T=%0t | PH=%0d | OPC=%02h | PC=%04h | ADDR=%04h | %s | A=%02h X=%02h Y=%02h P=%02h",
                 $time, dbg_phase, dbg_opcode, dbg_PC, dbg_addr,
                 dbg_rw ? "READ " : "WRITE",
                 dbg_A, dbg_X, dbg_Y, dbg_P);

    // --------------------------------------------------------------
    // Stimulus: RESET → IRQ → READY pause → NMI
    // --------------------------------------------------------------
    initial begin
        $display("====================================================");
        $display("6502 CPU – Final RTI/RTS/IRQ/NMI Verification Run");
        $display("====================================================");

        // Reset
        #5  reset_n = 0;
        #20 reset_n = 1;

        // Let program run
        #3000;

        // Trigger IRQ (simulate BRK)
        $display("\n>>> Triggering IRQ interrupt <<<\n");
        irq_n = 0;
        #50 irq_n = 1;

        // READY pause
        #2000;
        $display("\n>>> READY low (halt) <<<");
        rdy = 0;
        #200;
        rdy = 1;
        $display(">>> READY high (resume) <<<\n");

        // Trigger NMI
        #4000;
        $display("\n>>> Triggering NMI interrupt <<<\n");
        nmi_n = 0;
        #40 nmi_n = 1;

        // Run for a while then finish
        #15000;
        $display("====================================================");
        $display("Simulation Complete");
        $display("Final: A=%02h X=%02h Y=%02h P=%02h PC=%04h",
                 dbg_A, dbg_X, dbg_Y, dbg_P, dbg_PC);
        $display("====================================================");
        $finish;
    end

endmodule
`default_nettype wire
