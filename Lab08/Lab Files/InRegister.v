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
