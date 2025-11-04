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
