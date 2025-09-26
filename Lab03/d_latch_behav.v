// d_latch_behav.v — Behavioral gated D latch (uses a single LUT)
module d_latch_behav(input D, input Clk, output reg Q);
  always @ (D, Clk) if (Clk) Q = D;
endmodule