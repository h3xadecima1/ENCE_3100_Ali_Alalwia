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
