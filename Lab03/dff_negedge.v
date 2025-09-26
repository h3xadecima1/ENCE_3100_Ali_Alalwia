module dff_negedge(input D, input Clk, input rst_n, output reg Q);
  always @(negedge Clk or negedge rst_n)
    if (!rst_n) Q <= 1'b0; else Q <= D;
endmodule