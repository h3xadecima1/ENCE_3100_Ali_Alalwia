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
