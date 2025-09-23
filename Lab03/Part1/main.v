
module main (
    input  [9:0] SW,    // SW[1]=S, SW[0]=R
    output  [9:0] LEDR   // LEDR[0]=Q
);
    // Invert KEY0 since it is active-low
    wire Clk = SW[0];

    // Instantiate the latch
    part1 u_latch (
        .Clk(Clk),
        .R  (SW[1]),
        .S  (SW[2]),
        .Q  (LEDR[0])
    );
endmodule
