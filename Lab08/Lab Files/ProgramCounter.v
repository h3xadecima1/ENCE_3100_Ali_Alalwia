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
