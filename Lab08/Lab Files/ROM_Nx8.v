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
