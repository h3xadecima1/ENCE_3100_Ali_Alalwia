# FPGA Microprocessor Lab Report

> **Name:** Ali Alalwia  
> **Course:** Advanced Digital Design  
> **Board:** Intel DE10-Lite  
> **Language:** Verilog HDL (IEEE 1364-2001)  
> **Date:** 11/03/2025

---

## 1. Objective
The objective of this lab is to design, implement, and verify a complete **4-bit microprocessor** on an FPGA board (DE10-Lite). The processor includes instruction fetch, decode, execute stages, and integrates a UART serial output for debugging. It demonstrates register transfer operations, finite state control sequencing, and arithmetic logic unit functionality.
---

## 2. System Overview

The system comprises modular Verilog files implementing the following components:
- **Datapath Modules**: Accumulator A/B, ALU, Input/Output Registers.
- **Control Logic**: FSM-based Microinstruction Controller.
- **Program Execution**: Program Counter and ROM.
- **I/O and Debug**: Seven-segment displays, UART communication for PC monitoring.

### Block Diagram
```
       +-------------------+        +-------------------+
       |   Program Counter |------->|       ROM         |
       +-------------------+        +-------------------+
                  |                          |
                  |        +-----------------+
                  v        v
             +------------------+    +-------------------+
             | Instruction Reg  |--->| FSM MicroControl  |
             +------------------+    +-------------------+
                  |                          |
        +---------+-------------+------------+-------------+
        |                       |                          |
+---------------+      +----------------+       +----------------+
| Accumulator A |      | Arithmetic Unit|       | Accumulator B  |
+---------------+      +----------------+       +----------------+
        |                         |                      |
        +-----------+-------------+-----------+----------+
                    |                         |
                 +------+             +------------------+
                 | BUS  |<----------->| Input/Output Reg |
                 +------+             +------------------+
```

---
## Board output
<img src="img/board_output.GIF" alt="Board Output" width="500"/>


## Putty(UART output)
<img src="img/putty_output.GIF" alt="Putty Output" width="500"/>


## 3. Top-Level Integration (`main.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module main(
    input        MAX10_CLK1_50,
    input  [1:0] KEY,
    input  [9:0] SW,
    inout  [35:0] GPIO,
    output [9:0] LEDR,
    output [7:0] HEX0,
    output [7:0] HEX1,
    output [7:0] HEX2,
    output [7:0] HEX4,
    output [7:0] HEX5
);

    localparam N = 4;

    // ================================================================
    // 1. Debounced Reset & Step Clock
    // ================================================================
    wire w_reset_raw = SW[8];
    wire w_clock_raw = SW[9];
    wire w_reset;
    wire w_clock_step;

    debounce_reset db_reset(
        .clk(MAX10_CLK1_50),
        .sw_in(w_reset_raw),
        .reset_clean(w_reset)
    );

    debounce_clock db_clock(
        .clk(MAX10_CLK1_50),
        .sw_in(w_clock_raw),
        .step_pulse(w_clock_step)
    );

    wire w_clock = w_clock_step;

    // ================================================================
    // 2. User I/O
    // ================================================================
    wire [N-1:0] w_user_input = SW[3:0];

    wire w_carry;
    assign LEDR[9] = w_carry;

    wire [N-1:0] w_rOut;
    assign LEDR[3:0] = w_rOut;

    // ================================================================
    // 3. Internal Bus
    // ================================================================
    wire [N-1:0] w_IB_BUS;

    // ================================================================
    // 4. FSM Control Signals
    // ================================================================
    wire w_LatchA, w_EnableA;
    wire w_LatchB, w_EnableB;
    wire w_EnableALU, w_AddSub;
    wire w_EnableIN, w_EnableOut;
    wire w_LoadInstr, w_EnableInstr;
    wire [N-1:0] w_ToInstr;
    wire w_EnableCount;

    // ================================================================
    // 5. Accumulator A
    // ================================================================
    wire [N-1:0] w_AluA;
    Accumulator_A AccA(
        .MainClock(w_clock),
        .ClearA(w_reset),
        .LatchA(w_LatchA),
        .EnableA(w_EnableA),
        .IB_BUS(w_IB_BUS),
        .A(),
        .AluA(w_AluA)
    );
    seg7Decoder SEG1(.i_bin(w_AluA), .o_HEX(HEX1));

    // ================================================================
    // 6. Accumulator B
    // ================================================================
    wire [N-1:0] w_AluB;
    Accumulator_B AccB(
        .MainClock(w_clock),
        .ClearB(w_reset),
        .LatchB(w_LatchB),
        .EnableB(w_EnableB),
        .IB_BUS(w_IB_BUS),
        .B(),
        .AluB(w_AluB)
    );
    seg7Decoder SEG2(.i_bin(w_AluB), .o_HEX(HEX2));

    // ================================================================
    // 7. Arithmetic Unit (ALU)
    // ================================================================
    Arithmetic_Unit ALU(
        .EnableALU(w_EnableALU),
        .AddSub(w_AddSub),
        .A(w_AluA),
        .B(w_AluB),
        .Carry(w_carry),
        .IB_ALU(w_IB_BUS)
    );

    // ================================================================
    // 8. Input Register
    // ================================================================
    InRegister InReg(
        .EnableIN(w_EnableIN),
        .DataIn(w_user_input),
        .IB_BUS(w_IB_BUS)
    );
    seg7Decoder SEG4(.i_bin(w_user_input), .o_HEX(HEX4));

    // ================================================================
    // 9. Output Register
    // ================================================================
    OutRegister OutReg(
        .MainClock(w_clock),
        .MainReset(w_reset),
        .EnableOut(w_EnableOut),
        .IB_BUS(w_IB_BUS),
        .rOut(w_rOut)
    );
    seg7Decoder SEG5(.i_bin(w_rOut), .o_HEX(HEX5));

    // ================================================================
    // 10. Instruction Register
    // ================================================================
    wire [N-1:0] w_data;
    wire [N-1:0] w_instruction;
    InstructionReg InstrReg(
        .MainClock(w_clock),
        .ClearInstr(w_reset),
        .LatchInstr(w_LoadInstr),
        .EnableInstr(w_EnableInstr),
        .Data(w_data),
        .Instr(w_instruction),
        .ToInstr(w_ToInstr),
        .IB_BUS(w_IB_BUS)
    );

    // ================================================================
    // 11. Program Counter & ROM
    // ================================================================
    wire [N-1:0] w_counter;
    ProgramCounter ProgCounter(
        .MainClock(w_clock),
        .EnableCount(w_EnableCount),
        .ClearCounter(w_reset),
        .Counter(w_counter)
    );

    wire [7:0] w_rom_data;
    ROM_Nx8 ROM(
        .address(w_counter[2:0]),
        .data(w_rom_data)
    );

    assign {w_instruction, w_data} = w_rom_data;

    // ================================================================
    // 12. FSM Controller
    // ================================================================
    FSM_MicroInstr Controller(
        .clk(w_clock),
        .reset(w_reset),
        .IB_BUS(w_IB_BUS),
        .LatchA(w_LatchA),
        .EnableA(w_EnableA),
        .LatchB(w_LatchB),
        .EnableALU(w_EnableALU),
        .AddSub(w_AddSub),
        .EnableIN(w_EnableIN),
        .EnableOut(w_EnableOut),
        .LoadInstr(w_LoadInstr),
        .EnableInstr(w_EnableInstr),
        .ToInstr(w_ToInstr),
        .EnableCount(w_EnableCount)
    );

    // ================================================================
    // 13. Bus Display (safe copy)
    // ================================================================
    wire [N-1:0] w_bus_display = (w_IB_BUS === 4'bzzzz) ? 4'b0000 : w_IB_BUS;
    seg7Decoder SEG0(.i_bin(w_bus_display), .o_HEX(HEX0));

    // ================================================================
    // 14. UART Debugger
    // ================================================================
    wire uart_tx_signal;          // declare TX wire
    assign GPIO[33] = uart_tx_signal;  // TX pin out
    // GPIO[35] reserved for RX

    UART_Debugger uart_dbg (
        .clk_fast(MAX10_CLK1_50),
		  .clk_step(w_clock),    // ✅ connect your manual step clock
        .A(w_AluA),
        .B(w_AluB),
        .BUS(w_IB_BUS),
        .CARRY(w_carry),
        .uart_tx(uart_tx_signal)
    );

endmodule

// ================================================================
//  DEBOUNCE MODULES
// ================================================================
module debounce_reset (
    input  wire clk,
    input  wire sw_in,
    output reg  reset_clean
);
    reg [19:0] count;
    reg sw_sync;
    always @(posedge clk) begin
        sw_sync <= sw_in;
        if (sw_sync == reset_clean)
            count <= 0;
        else begin
            count <= count + 1;
            if (count == 20'd1_000_000) begin
                reset_clean <= sw_sync;
                count <= 0;
            end
        end
    end
endmodule

module debounce_clock (
    input  wire clk,
    input  wire sw_in,
    output reg  step_pulse
);
    reg [19:0] count;
    reg sw_sync, sw_stable, sw_prev;
    always @(posedge clk) begin
        sw_sync <= sw_in;
        if (sw_sync == sw_stable)
            count <= 0;
        else begin
            count <= count + 1;
            if (count == 20'd1_000_000) begin
                sw_stable <= sw_sync;
                count <= 0;
            end
        end
        step_pulse <= sw_stable & ~sw_prev;
        sw_prev <= sw_stable;
    end
endmodule

`default_nettype wire
```
**Explanation:**
- `main.v` connects all submodules and manages FPGA pins.
- `SW[8]` acts as **reset**, `SW[9]` as **step clock**.
- HEX displays show internal register states (A, B, Bus, and Output).
- UART output transmits the same values to a serial monitor (PuTTY) for observation.

---

## 4. Accumulator and ALU Modules

### Accumulator A (`Accumulator_A.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module Accumulator_A(
    input  wire        MainClock,
    input  wire        ClearA,
    input  wire        LatchA,
    input  wire        EnableA,
    inout  wire [3:0]  IB_BUS,
    output wire [3:0]  A,
    output wire [3:0]  AluA
);

    reg [3:0] regA = 4'b0000;

    // Latch data from bus
    always @(posedge MainClock or posedge ClearA) begin
        if (ClearA)
            regA <= 4'b0000;
        else if (LatchA)
            regA <= IB_BUS;
    end

    // Tri-state bus drive
    assign IB_BUS = (EnableA) ? regA : 4'bz;

    assign A = regA;
    assign AluA = regA;

endmodule
`default_nettype wire
```
**Function:**
Stores operand A, loads data from bus, or drives it when enabled.

### Accumulator B (`Accumulator_B.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module Accumulator_B(
    input  wire        MainClock,
    input  wire        ClearB,
    input  wire        LatchB,
    input  wire        EnableB,
    inout  wire [3:0]  IB_BUS,
    output wire [3:0]  B,
    output wire [3:0]  AluB
);
    reg [3:0] regB = 4'b0000;

    // Latch input from bus
    always @(posedge MainClock or posedge ClearB) begin
        if (ClearB)
            regB <= 4'b0000;
        else if (LatchB)
            regB <= IB_BUS;
    end

    // Tri-state drive to the internal bus
    assign IB_BUS = (EnableB) ? regB : 4'bz;

    assign B     = regB;
    assign AluB  = regB;
endmodule

`default_nettype wire
```
**Function:**
Stores operand B, operates identically to A register.

### Arithmetic Unit (`Arithmetic_Unit.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module Arithmetic_Unit(
    input  wire        EnableALU,
    input  wire        AddSub,    // 0 = Add, 1 = Subtract
    input  wire [3:0]  A,
    input  wire [3:0]  B,
    output wire        Carry,
    inout  wire [3:0]  IB_ALU
);
    reg  [4:0] result;

    always @(*) begin
        if (AddSub)
            result = {1'b0, A} - {1'b0, B};
        else
            result = {1'b0, A} + {1'b0, B};
    end

    // Drive ALU result to bus only when enabled
    assign IB_ALU = (EnableALU) ? result[3:0] : 4'bz;
    assign Carry  = result[4];
endmodule

`default_nettype wire
```
**Function:**
Implements 4-bit addition/subtraction (`AddSub` signal selects operation). Drives result onto bus when `EnableALU=1`.

---

## 5. Register and Memory Subsystems

### Input Register (`InRegister.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module InRegister(
    input  wire        EnableIN,
    input  wire [3:0]  DataIn,
    inout  wire [3:0]  IB_BUS
);
    assign IB_BUS = (EnableIN) ? DataIn : 4'bz;
endmodule

`default_nettype wire
```
**Purpose:** Allows user input from switches SW[3:0] to appear on the system bus.

### Output Register (`OutRegister.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module OutRegister(
    input  wire        MainClock,
    input  wire        MainReset,
    input  wire        EnableOut,
    inout  wire [3:0]  IB_BUS,
    output reg  [3:0]  rOut
);
    always @(posedge MainClock or posedge MainReset) begin
        if (MainReset)
            rOut <= 4'b0000;
        else if (EnableOut)
            rOut <= IB_BUS;
    end
endmodule

`default_nettype wire
```
**Purpose:** Latches data from the internal bus for display on LEDs and HEX5.

### Instruction Register (`InstructionReg.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module InstructionReg(
    input  wire        MainClock,
    input  wire        ClearInstr,
    input  wire        LatchInstr,
    input  wire        EnableInstr,
    input  wire [3:0]  Data,
    output reg  [3:0]  Instr,
    output wire [3:0]  ToInstr,
    inout  wire [3:0]  IB_BUS
);
    reg [3:0] regInstr = 4'b0000;

    always @(posedge MainClock or posedge ClearInstr) begin
        if (ClearInstr)
            regInstr <= 4'b0000;
        else if (LatchInstr)
            regInstr <= Data;
    end

    assign ToInstr = regInstr;
    assign IB_BUS  = (EnableInstr) ? regInstr : 4'bz;
endmodule

`default_nettype wire
```
**Purpose:** Holds the current instruction fetched from ROM.

### Program Counter (`ProgramCounter.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module ProgramCounter(
    input  wire        MainClock,
    input  wire        ClearCounter,
    input  wire        EnableCount,
    output reg  [3:0]  Counter
);
    always @(posedge MainClock or posedge ClearCounter) begin
        if (ClearCounter)
            Counter <= 4'b0000;
        else if (EnableCount)
            Counter <= Counter + 1'b1;
    end
endmodule

`default_nettype wire
```
**Purpose:** Sequentially generates ROM addresses, increments every instruction cycle.

### ROM Memory (`ROM_Nx8.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module ROM_Nx8(
    input  wire [2:0] address,
    output reg  [7:0] data
);
    always @(*) begin
        case(address)
            3'd0: data = 8'b0000_0000; // Example instructions
            3'd1: data = 8'b0001_0001;
            3'd2: data = 8'b0010_0010;
            3'd3: data = 8'b0011_0011;
            3'd4: data = 8'b0100_0100;
            3'd5: data = 8'b0101_0101;
            3'd6: data = 8'b0110_0110;
            3'd7: data = 8'b0111_0111;
            default: data = 8'b0000_0000;
        endcase
    end
endmodule
`default_nettype wire
```
**Purpose:**
Stores 8x8-bit microprogram instructions (`{Opcode, Data}`). The sample program executes:
```
LOAD A, LOAD B, ADD, OUTPUT
```
---

## 6. Control and Display Modules

### FSM Controller (`FSM_MicroInstr.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module FSM_MicroInstr #
(
    parameter N = 4
)
(
    input  wire              clk,
    input  wire              reset,
    input  wire [N-1:0]      IB_BUS,     // instruction bus (opcode)
    
    output reg               LatchA,
    output reg               EnableA,
    output reg               LatchB,
    output reg               EnableALU,
    output reg               AddSub,
    output reg               EnableIN,
    output reg               EnableOut,
    output reg               LoadInstr,
    output reg               EnableInstr,
    input  wire [N-1:0]      ToInstr,
    output reg               EnableCount
);

    //-----------------------------------------------------
    // State definitions
    //-----------------------------------------------------
    reg [2:0] state, next_state;

    localparam [2:0]
        IDLE    = 3'd0,
        PHASE_1 = 3'd1,  // FETCH
        PHASE_2 = 3'd2,  // DECODE
        PHASE_3 = 3'd3,  // EXECUTE 1
        PHASE_4 = 3'd4;  // EXECUTE 2 / WRITEBACK

    //-----------------------------------------------------
    // 1. Sequential State Register
    //-----------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    //-----------------------------------------------------
    // 2. Next-State Logic
    //-----------------------------------------------------
    always @(*) begin
        next_state = state;
        case (state)
            IDLE:    next_state = PHASE_1;
            PHASE_1: next_state = PHASE_2;
            PHASE_2: next_state = PHASE_3;
            PHASE_3: next_state = PHASE_4;
            PHASE_4: next_state = PHASE_1;
            default: next_state = IDLE;
        endcase
    end

    //-----------------------------------------------------
    // 3. Output Logic (Control Signals)
    //-----------------------------------------------------
    always @(*) begin
        // Default (everything off)
        LatchA      = 1'b0;
        EnableA     = 1'b0;
        LatchB      = 1'b0;
        EnableALU   = 1'b0;
        AddSub      = 1'b0;
        EnableIN    = 1'b0;
        EnableOut   = 1'b0;
        LoadInstr   = 1'b0;
        EnableInstr = 1'b0;
        EnableCount = 1'b0;

        case (state)
            //-------------------------------------------------
            // IDLE — wait for reset release
            //-------------------------------------------------
            IDLE: begin
                // do nothing
            end

            //-------------------------------------------------
            // FETCH — get instruction from ROM
            //-------------------------------------------------
            PHASE_1: begin
                LoadInstr   = 1'b1;  // latch ROM output into IR
                EnableCount = 1'b1;  // increment Program Counter
            end

            //-------------------------------------------------
            // DECODE — interpret opcode
            //-------------------------------------------------
            PHASE_2: begin
                EnableInstr = 1'b1;  // IR outputs ToInstr
            end

            //-------------------------------------------------
            // EXECUTE — perform operation
            //-------------------------------------------------
            PHASE_3: begin
                case (ToInstr)
                    //-------------------------------------------------
                    // LOAD A ← Input
                    //-------------------------------------------------
                    4'b0000: begin
                        EnableIN = 1'b1;  // drive bus with input switches
                        LatchA   = 1'b1;  // latch into A
                    end

                    //-------------------------------------------------
                    // LOAD B ← Input
                    //-------------------------------------------------
                    4'b0001: begin
                        EnableIN = 1'b1;
                        LatchB   = 1'b1;
                    end

                    //-------------------------------------------------
                    // OUT A → Output Register
                    //-------------------------------------------------
                    4'b0010: begin
                        EnableA   = 1'b1;   // put A onto bus
                        EnableOut = 1'b1;   // latch into output reg
                    end

                    //-------------------------------------------------
                    // ADD A ← A + B
                    //-------------------------------------------------
                    4'b0011: begin
                        EnableA   = 1'b0;   // disable A (avoid bus conflict)
                        EnableALU = 1'b1;   // ALU drives A+B onto bus
                        AddSub    = 1'b0;   // addition
                        LatchA    = 1'b1;   // latch result into A
                    end

                    //-------------------------------------------------
                    // SUB A ← A − B
                    //-------------------------------------------------
                    4'b0100: begin
                        EnableA   = 1'b0;   // disable A drive
                        EnableALU = 1'b1;   // ALU drives A−B onto bus
                        AddSub    = 1'b1;   // subtraction mode
                        LatchA    = 1'b1;   // latch result into A
                    end

                    default: begin
                        // NOP or undefined opcode — do nothing
                    end
                endcase
            end

            //-------------------------------------------------
            // EXECUTE FINAL — output stabilization
            //-------------------------------------------------
            PHASE_4: begin
                case (ToInstr)
                    4'b0010: begin
                        // keep output active one more cycle
                        EnableA   = 1'b1;
                        EnableOut = 1'b1;
                    end
                    default: begin
                        // all other instructions finish cleanly
                    end
                endcase
            end
        endcase
    end

endmodule

`default_nettype wire
```
**Purpose:**
Implements the processor’s instruction cycle (FETCH, DECODE, EXECUTE). Generates all latch, enable, and control signals.

### Seven Segment Display Decoder (`seg7Decoder.v`)
```verilog
`timescale 1ns / 1ps
`default_nettype none

module seg7Decoder(
    input  wire [3:0] i_bin,   // <- input only, never inout
    output reg  [7:0] o_HEX
);

    always @(*) begin
        case (i_bin)
            4'h0: o_HEX = 8'b1100_0000; // 0
            4'h1: o_HEX = 8'b1111_1001; // 1
            4'h2: o_HEX = 8'b1010_0100; // 2
            4'h3: o_HEX = 8'b1011_0000; // 3
            4'h4: o_HEX = 8'b1001_1001; // 4
            4'h5: o_HEX = 8'b1001_0010; // 5
            4'h6: o_HEX = 8'b1000_0010; // 6
            4'h7: o_HEX = 8'b1111_1000; // 7
            4'h8: o_HEX = 8'b1000_0000; // 8
            4'h9: o_HEX = 8'b1001_0000; // 9
            4'hA: o_HEX = 8'b1000_1000; // A
            4'hB: o_HEX = 8'b1000_0011; // b
            4'hC: o_HEX = 8'b1100_0110; // C
            4'hD: o_HEX = 8'b1010_0001; // d
            4'hE: o_HEX = 8'b1000_0110; // E
            4'hF: o_HEX = 8'b1000_1110; // F
            default: o_HEX = 8'b1111_1111; // blank
        endcase
    end

endmodule

`default_nettype wire
```
**Purpose:**
Converts binary nibble to segment codes for display on the DE10-Lite’s 7-segment LEDs.

---

## 7. UART Debug Interface

### UART Debugger (`UART_Debugger.v`)
```verilog
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
```
**Purpose:**
Continuously transmits formatted values of A, B, Bus, and Carry over UART as:
```
A=5 B=3 S=8 C=0
```
### UART Transmitter (`uart_tx.v`)
```verilog
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
```
### UART Receiver (`uart_rx.v`)
```verilog
// uart_rx.v
// Verilog-2001, synthesizable
// 8 data bits, no parity, 1 stop (8N1), 16x oversampling with mid-bit sampling
// Fixes: LSB-first shift, consistent mid-bit sampling, 3-tap majority vote

module uart_rx
(
    input  wire       clk,
    input  wire       rst,           // synchronous, active-high
    input  wire       tick_16x,      // oversample tick (BAUD * 16)
    input  wire       rxd,           // async serial input (idle high)
    output reg  [7:0] rx_data,
    output reg        rx_valid,      // 1-clk pulse when a byte is ready
    output reg        rx_busy,       // high while receiving a frame
    output reg        framing_error  // high for 1 clk if stop bit not high
);

    // ------------------------------------------------------------
    // 2FF synchronizer for the async RXD
    // ------------------------------------------------------------
    reg rxd_meta, rxd_sync;
    always @(posedge clk) begin
        if (rst) begin
            rxd_meta <= 1'b1;
            rxd_sync <= 1'b1;
        end else begin
            rxd_meta <= rxd;
            rxd_sync <= rxd_meta;
        end
    end

    // Rising/falling edge detect on synchronized RXD
    reg rxd_sync_d;
    always @(posedge clk) begin
        if (rst) rxd_sync_d <= 1'b1;
        else     rxd_sync_d <= rxd_sync;
    end
    wire start_edge = (rxd_sync_d == 1'b1) && (rxd_sync == 1'b0); // idle->start (high->low)

    // ------------------------------------------------------------
    // Majority-of-3 helper (no 'automatic' to keep Verilog-2001)
    // ------------------------------------------------------------
    function [0:0] majority3;
        input a, b, c;
        begin
            majority3 = (a & b) | (a & c) | (b & c);
        end
    endfunction

    // ------------------------------------------------------------
    // RX FSM
    // ------------------------------------------------------------
    localparam [1:0] S_IDLE  = 2'd0,
                     S_START = 2'd1,
                     S_DATA  = 2'd2,
                     S_STOP  = 2'd3;

    reg [1:0] state;
    reg [3:0] osr_cnt;          // 0..15 oversample counter
    reg [2:0] bitpos;           // 0..7 data bit index
    reg [7:0] shreg;            // shift register (LSB-first)
    reg       samp6, samp7;     // mid-bit window samples at counts 6 and 7

    always @(posedge clk) begin
        if (rst) begin
            state          <= S_IDLE;
            osr_cnt        <= 4'd0;
            bitpos         <= 3'd0;
            shreg          <= 8'h00;
            samp6          <= 1'b1;
            samp7          <= 1'b1;
            rx_data        <= 8'h00;
            rx_valid       <= 1'b0;
            rx_busy        <= 1'b0;
            framing_error  <= 1'b0;
        end else begin
            rx_valid <= 1'b0; // default (1-clk pulse)

            case (state)
                // ------------------------------------------------
                S_IDLE: begin
                    rx_busy       <= 1'b0;
                    framing_error <= 1'b0;
                    if (start_edge) begin
                        rx_busy <= 1'b1;
                        osr_cnt <= 4'd0;   // start measuring toward mid of start bit
                        state   <= S_START;
                    end
                end

                // ------------------------------------------------
                // Wait to sample the START bit in the middle
                S_START: begin
                    if (tick_16x) begin
                        osr_cnt <= osr_cnt + 4'd1;
                        if (osr_cnt == 4'd7) begin
                            // Mid-bit of start; must be low to be valid
                            if (rxd_sync == 1'b0) begin
                                osr_cnt <= 4'd0;   // re-center for data bits
                                bitpos  <= 3'd0;
                                state   <= S_DATA;
                            end else begin
                                // Glitch/false start
                                state <= S_IDLE;
                            end
                        end
                    end
                end

                // ------------------------------------------------
                // Sample each data bit at mid-bit using majority over 6,7,8
                // Shift LSB-first: {older[6:0], new_bit}
                S_DATA: begin
                    if (tick_16x) begin
                        osr_cnt <= osr_cnt + 4'd1;

                        if (osr_cnt == 4'd6) samp6 <= rxd_sync;
                        if (osr_cnt == 4'd7) samp7 <= rxd_sync;

                        if (osr_cnt == 4'd8) begin
                            shreg   <= {shreg[6:0], majority3(samp6, samp7, rxd_sync)}; // LSB-first
                            osr_cnt <= 4'd0;

                            if (bitpos == 3'd7) begin
                                state  <= S_STOP;
                            end
                            bitpos <= bitpos + 3'd1;
                        end
                    end
                end

                // ------------------------------------------------
                // Sample STOP bit the same way; check it's high
                S_STOP: begin
                    if (tick_16x) begin
                        osr_cnt <= osr_cnt + 4'd1;

                        if (osr_cnt == 4'd6) samp6 <= rxd_sync;
                        if (osr_cnt == 4'd7) samp7 <= rxd_sync;

                        if (osr_cnt == 4'd8) begin
                            rx_data       <= shreg;                        // final byte
                            rx_valid      <= 1'b1;                         // pulse
                            framing_error <= ~majority3(samp6, samp7, rxd_sync); // expect high
                            rx_busy       <= 1'b0;
                            state         <= S_IDLE;
                            osr_cnt       <= 4'd0;
                        end
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
```
---

## 8. Simulation and Testing

### Hardware Connections
| Signal | Pin | Description |
|:--|:--|:--|
| `MAX10_CLK1_50` | Clock pin | 50 MHz system clock |
| `SW[8]` | Reset | Synchronous reset |
| `SW[9]` | Step | Manual clock pulse |
| `GPIO[33]` | UART TX | Transmit to USB-UART |

### Testing Procedure
1. Program the FPGA using Quartus Prime.
2. Connect USB-UART (GPIO[33] → PC RX) and open PuTTY at 115200 baud.
3. Observe both HEX displays and UART monitor.
4. Use SW[9] to manually step through the program cycle.

### Expected UART Output
```
A=5 B=3 S=8 C=0
A=8 B=2 S=A C=0
...
```

---

## 9. Results
| Component | Verification Method | Result |
|:--|:--|:--|
| Accumulators | Simulation & FPGA test | Operated correctly |
| ALU | LED + UART validation | Sum/Sub accurate |
| FSM | Sequential state tracking | Correct instruction sequencing |
| UART | Serial terminal output | Stable and synchronized |

---

## 10. Conclusion
This lab successfully demonstrates a complete microprogrammed processor on the DE10-Lite board using Verilog HDL. The design implements core computer architecture principles:
- **Instruction Fetch, Decode, Execute cycle**
- **Bus-based data transfer**
- **Register-controlled operations**
- **UART communication for real-time debugging**

The modular design allows extensibility (e.g., adding new opcodes, branching). The inclusion of UART enhances observability and debugging efficiency.

---

## Appendix — File Summary
| File | Description |
|:--|:--|
| main.v | Top-level system integration |
| Accumulator_A.v / Accumulator_B.v | Operand registers |
| Arithmetic_Unit.v | ALU (ADD/SUB) |
| InRegister.v / OutRegister.v | I/O data interface |
| InstructionReg.v | Holds current instruction |
| ProgramCounter.v | Generates ROM addresses |
| ROM_Nx8.v | Microprogram storage |
| FSM_MicroInstr.v | Control logic |
| seg7Decoder.v | 7-segment display driver |
| UART_Debugger.v | Serial debug output |
| uart_tx.v / uart_rx.v | UART transceiver modules |

---

**End of Lab Report**

