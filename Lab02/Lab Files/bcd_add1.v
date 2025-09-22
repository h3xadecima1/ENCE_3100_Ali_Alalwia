module bcd_add1(
    input  wire [3:0] a, b,
    input  wire       cin,
    output wire [3:0] s,
    output wire       cout
);
    wire [4:0] z  = a + b + cin;       // raw sum, 0..19
    wire       need6 = (z > 5'd9);     // detect invalid BCD
    wire [4:0] zc = z + 5'd6;          // corrected

    assign s    = need6 ? zc[3:0] : z[3:0];
    assign cout = need6;
endmodule
