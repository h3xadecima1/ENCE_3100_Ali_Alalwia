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
