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
