// ms_dff.v — Master–Slave DFF from two gated D latches
module ms_dff(input D, input Clk, output Q);
  wire Qm;
  // master opens when Clk=1, slave opens when Clk=0
  d_latch_keep MASTER(.D(D),  .Clk(Clk),   .Q(Qm));
  d_latch_keep SLAVE (.D(Qm), .Clk(~Clk),  .Q(Q));
endmodule