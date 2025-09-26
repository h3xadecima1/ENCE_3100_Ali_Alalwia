
module main (
    input  [9:0] SW,    // SW[1]=S, SW[0]=R
	 input  [1:0] KEY,   // KEY[0]=Clock button, KEY[1]=active-low reset
    output [9:0] LEDR,   // LEDR[0]=Q
	 output [7:0] HEX0, HEX1
	 
);
    // Invert KEY0 since it is active-low

    // Part1
	 /*
	 wire Clk = SW[0];
    part1 u_latch (
        .Clk(Clk),
        .R  (SW[1]),
        .S  (SW[2]),
        .Q  (LEDR[0])
    );
	 */
	 // Part2
	 /*
  wire Clk = ~KEY[0];
  wire Q;
  d_latch_keep u(.D(SW[0]), .Clk(Clk), .Q(Q));
  assign LEDR[0] = Q;
  assign LEDR[9:1] = 0;
  */
  
  // Part3
  /*
  wire Clk = ~KEY[0];
  wire Q;
  ms_dff u(.D(SW[0]), .Clk(Clk), .Q(Q));
  assign LEDR[0] = Q;
  assign LEDR[9:1] = 0;
  */
  // Part4
  /*
  wire D   = SW[0];
  wire Clk = ~KEY[0];
  wire rst_n = KEY[1];

  wire Qa, Qb, Qc;
  d_latch_behav uA(.D(D), .Clk(Clk), .Q(Qa));
  dff_posedge   uB(.D(D), .Clk(Clk), .rst_n(rst_n), .Q(Qb));
  dff_negedge   uC(.D(D), .Clk(Clk), .rst_n(rst_n), .Q(Qc));

  assign LEDR[0] = Qa;  // gated latch output
  assign LEDR[1] = Qb;  // +edge DFF
  assign LEDR[2] = Qc;  // -edge DFF
  assign LEDR[9:3] = 0;
  */
  //Part5
  /*
   wire rst_n = KEY[0];
   wire Clk   = ~KEY[1];     // make a press into a rising edge clock

  reg [7:0] A, B;
  always @(posedge Clk or negedge rst_n) begin
    if (!rst_n) begin
      A <= 8'h00; B <= 8'h00;
    end else begin
      if (!SW[9]) A <= SW[7:0];  // SW[9]=0: load A
      else        B <= SW[7:0];  // SW[9]=1: load B
    end
  end

  wire [7:0] shown = (SW[9]) ? B : A; // choose which to display
  seg7 h0(.x(shown[3:0]), .HEX(HEX0));
  seg7 h1(.x(shown[7:4]), .HEX(HEX1));

  assign LEDR[7:0] = SW[7:0]; // show live switch value
  assign LEDR[9:8] = {1'b0, SW[9]}; // SW[9] indicator on LEDR[8]
  */
endmodule
