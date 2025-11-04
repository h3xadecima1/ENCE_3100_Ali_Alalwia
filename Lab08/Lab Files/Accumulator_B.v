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
