// d_latch_keep.v — Gated D latch with preserved internal nodes
module d_latch_keep(input D, input Clk, output Q); //d_latch_keep
  wire S_g, R_g, Qa, Qb /* synthesis keep */;
  assign S_g =  D & Clk;
  assign R_g = ~D & Clk;
  assign Qa  = ~(R_g | Qb);
  assign Qb  = ~(S_g | Qa);
  assign Q   = Qa;
endmodule

