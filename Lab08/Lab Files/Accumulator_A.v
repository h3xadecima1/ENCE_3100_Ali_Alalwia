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
