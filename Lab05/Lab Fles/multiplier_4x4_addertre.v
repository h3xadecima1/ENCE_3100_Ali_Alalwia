module multiplier_4x4_addertree(
    input  [3:0]  i_A,
    input  [3:0]  i_B,
    output [7:0]  o_P,
    output        o_Overflow
);
    // Partial products (shifted)
    wire [7:0] pp [3:0];
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_pp
            assign pp[i] = {4'b0000, (i_A & {4{i_B[i]}})} << i;
        end
    endgenerate

    // Adder tree
    wire [7:0] s0 = pp[0] + pp[1];
    wire [7:0] s1 = pp[2] + pp[3];
    assign o_P = s0 + s1;

    assign o_Overflow = |o_P[7:4];
endmodule
