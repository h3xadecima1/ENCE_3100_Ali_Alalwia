module multiplier_4x4(
    input  [3:0] i_A,    // 4-bit input A
    input  [3:0] i_B,    // 4-bit input B
    output [7:0] o_P,    // 8-bit product
    output       o_Overflow
);
    wire [3:0] pp0, pp1, pp2, pp3;  // partial products
    wire [3:0] s1, s2, s3;          // sum wires
    wire [3:0] c1, c2, c3;          // carry wires

    // Partial products using AND
    assign pp0 = i_A & {4{i_B[0]}};
    assign pp1 = i_A & {4{i_B[1]}};
    assign pp2 = i_A & {4{i_B[2]}};
    assign pp3 = i_A & {4{i_B[3]}};

    // Least significant bit
    assign o_P[0] = pp0[0];

    // --- First row of adders ---
    FullAdder fa1_0(pp0[1], pp1[0], 1'b0, o_P[1], c1[0]);
    FullAdder fa1_1(pp0[2], pp1[1], c1[0], s1[0], c1[1]);
    FullAdder fa1_2(pp0[3], pp1[2], c1[1], s1[1], c1[2]);
    FullAdder fa1_3(1'b0,  pp1[3], c1[2], s1[2], c1[3]);

    // --- Second row ---
    FullAdder fa2_0(s1[0], pp2[0], 1'b0, o_P[2], c2[0]);
    FullAdder fa2_1(s1[1], pp2[1], c2[0], s2[0], c2[1]);
    FullAdder fa2_2(s1[2], pp2[2], c2[1], s2[1], c2[2]);
    FullAdder fa2_3(c1[3], pp2[3], c2[2], s2[2], c2[3]);

    // --- Third row ---
    FullAdder fa3_0(s2[0], pp3[0], 1'b0, o_P[3], c3[0]);
    FullAdder fa3_1(s2[1], pp3[1], c3[0], o_P[4], c3[1]);
    FullAdder fa3_2(s2[2], pp3[2], c3[1], o_P[5], c3[2]);
    FullAdder fa3_3(c2[3], pp3[3], c3[2], o_P[6], c3[3]);

    assign o_P[7] = c3[3];
    assign o_Overflow = c3[3];  // optional overflow indicator
endmodule
