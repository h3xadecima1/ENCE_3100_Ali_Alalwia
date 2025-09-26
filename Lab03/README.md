# Lab 3 — Latches, Flip-Flops, and Registers (DE10-Lite)

## Objective
The purpose of this lab is to explore **basic storage elements** using Verilog on the DE10-Lite FPGA board.  
We build RS latches, D latches, Master–Slave flip-flops, and registers, then display results on LEDs and 7-segment displays.  
This shows how memory elements are implemented at the **gate level** and in **behavioral Verilog**.

---

## Part I — Gated RS Latch

### Explanation
An **RS latch** stores a single bit of information using Set (S) and Reset (R) inputs.  
When the clock is high, the latch responds to R and S. When the clock is low, the latch holds its state.

We implemented this in **two styles**: gate-level instantiation and Boolean expressions.

### Gate-level code
```verilog
module part1_gate(input Clk, input R, input S, output Q);
  wire R_g, S_g, Qa, Qb /* synthesis keep */;
  and (R_g, R, Clk);
  and (S_g, S, Clk);
  nor (Qa, R_g, Qb);
  nor (Qb, S_g, Qa);
  assign Q = Qa;
endmodule
```

### Expression style
```verilog
module part1_expr(input Clk, input R, input S, output Q);
  wire R_g, S_g, Qa, Qb /* synthesis keep */;
  assign R_g = R & Clk;
  assign S_g = S & Clk;
  assign Qa  = ~(R_g | Qb);
  assign Qb  = ~(S_g | Qa);
  assign Q = Qa;
endmodule
```

### Top-level mapping
```verilog
module top_part1(
  input  [9:0] SW,    // SW[0]=R, SW[1]=S
  input  [1:0] KEY,   // KEY[0]=Clk (active-low)
  output [9:0] LEDR
);
  wire Clk = ~KEY[0];
  wire Q_gate, Q_expr;

  part1_gate u0(.Clk(Clk), .R(SW[0]), .S(SW[1]), .Q(Q_gate));
  part1_expr u1(.Clk(Clk), .R(SW[0]), .S(SW[1]), .Q(Q_expr));

  assign LEDR[0] = Q_gate;
  assign LEDR[1] = Q_expr;
endmodule
```

**What we see:** Both implementations produce identical behavior. The LED lights up or clears depending on the R/S input when clock is pressed.

---

## Part II — Gated D Latch

### Explanation
The **D latch** is derived from an RS latch. Instead of having separate S and R, it takes a single data input `D`.  
- When Clk=1 → output follows D.  
- When Clk=0 → output holds its last value.

### Code
```verilog
module d_latch_keep(input D, input Clk, output Q);
  wire S_g, R_g, Qa, Qb /* synthesis keep */;
  assign S_g =  D & Clk;
  assign R_g = ~D & Clk;
  assign Qa  = ~(R_g | Qb);
  assign Qb  = ~(S_g | Qa);
  assign Q   = Qa;
endmodule

module top_part2(
  input  [9:0] SW,   // SW[0]=D
  input  [1:0] KEY,  // KEY[0]=Clk
  output [9:0] LEDR
);
  wire Clk = ~KEY[0];
  wire Q;
  d_latch_keep u(.D(SW[0]), .Clk(Clk), .Q(Q));
  assign LEDR[0] = Q;
endmodule
```

**What we see:** LED follows the switch when clock=1 and holds the last value when clock=0.

---

## Part III — Master–Slave D Flip-Flop

### Explanation
A **Master–Slave D flip-flop** uses two D latches:  
- The master is transparent when Clk=1.  
- The slave is transparent when Clk=0.  
Together, the output changes only on the **falling edge** of the clock.

### Code
```verilog
module ms_dff(input D, input Clk, output Q);
  wire Qm;
  d_latch_keep MASTER(.D(D),  .Clk(Clk),   .Q(Qm));
  d_latch_keep SLAVE (.D(Qm), .Clk(~Clk),  .Q(Q));
endmodule

module top_part3(
  input  [9:0] SW,   // SW[0]=D
  input  [1:0] KEY,  // KEY[0]=Clk
  output [9:0] LEDR
);
  wire Clk = ~KEY[0];
  wire Q;
  ms_dff u(.D(SW[0]), .Clk(Clk), .Q(Q));
  assign LEDR[0] = Q;
endmodule
```

**What we see:** The output LED only changes when the button clock makes a falling edge transition.

---

## Part IV — Behavioral Latch & Edge-Triggered Flip-Flops

### Explanation
Here we compare three storage elements:
- A **behavioral D latch** (updates whenever Clk=1).
- A **positive-edge triggered DFF** (updates on rising edge).
- A **negative-edge triggered DFF** (updates on falling edge).

### Code
```verilog
module d_latch_behav(input D, input Clk, output reg Q);
  always @ (D, Clk) if (Clk) Q = D;
endmodule

module dff_posedge(input D, input Clk, input rst_n, output reg Q);
  always @(posedge Clk or negedge rst_n)
    if (!rst_n) Q <= 1'b0; else Q <= D;
endmodule

module dff_negedge(input D, input Clk, input rst_n, output reg Q);
  always @(negedge Clk or negedge rst_n)
    if (!rst_n) Q <= 1'b0; else Q <= D;
endmodule

module top_part4(
  input  [9:0] SW,   // SW[0]=D
  input  [1:0] KEY,  // KEY[0]=Clk, KEY[1]=reset
  output [9:0] LEDR
);
  wire D   = SW[0];
  wire Clk = ~KEY[0];
  wire rst_n = KEY[1];

  wire Qa, Qb, Qc;
  d_latch_behav uA(.D(D), .Clk(Clk), .Q(Qa));
  dff_posedge   uB(.D(D), .Clk(Clk), .rst_n(rst_n), .Q(Qb));
  dff_negedge   uC(.D(D), .Clk(Clk), .rst_n(rst_n), .Q(Qc));

  assign LEDR[0] = Qa; // behavioral latch
  assign LEDR[1] = Qb; // posedge DFF
  assign LEDR[2] = Qc; // negedge DFF
endmodule
```

**What we see:**  
- `Qa` changes whenever Clk=1.  
- `Qb` changes on rising edges.  
- `Qc` changes on falling edges.  

This illustrates differences between **level-sensitive latches** and **edge-triggered flip-flops**.

---

## Part V — Registers and HEX Display

### Explanation
Registers are used to **store multi-bit values**. We built two 8-bit registers (A and B) using switches.  
- `SW[7:0]` provide data input.  
- `SW[9]` selects which register to update (A or B).  
- `KEY[1]` loads data into the selected register.  
- `KEY[0]` resets both registers.  
- The stored value is displayed on HEX0 and HEX1.

### Code
```verilog
module seg7(input [3:0] x, output reg [7:0] HEX);
  always @* case (x)
    4'h0: HEX=8'b1100_0000; 4'h1: HEX=8'b1111_1001;
    4'h2: HEX=8'b1010_0100; 4'h3: HEX=8'b1011_0000;
    4'h4: HEX=8'b1001_1001; 4'h5: HEX=8'b1001_0010;
    4'h6: HEX=8'b1000_0010; 4'h7: HEX=8'b1111_1000;
    4'h8: HEX=8'b1000_0000; 4'h9: HEX=8'b1001_0000;
    4'hA: HEX=8'b1000_1000; 4'hB: HEX=8'b1000_0011;
    4'hC: HEX=8'b1100_0110; 4'hD: HEX=8'b1010_0001;
    4'hE: HEX=8'b1000_0110; 4'hF: HEX=8'b1000_1110;
  endcase
endmodule

module top_part5_de10lite(
  input  [9:0] SW,    // SW[7:0]=data, SW[9]=A/B select
  input  [1:0] KEY,   // KEY[0]=reset, KEY[1]=clk
  output [9:0] LEDR,
  output [7:0] HEX0, HEX1
);
  wire rst_n = KEY[0];
  wire Clk   = ~KEY[1];

  reg [7:0] A, B;
  always @(posedge Clk or negedge rst_n) begin
    if (!rst_n) begin
      A <= 0; B <= 0;
    end else begin
      if (!SW[9]) A <= SW[7:0];
      else        B <= SW[7:0];
    end
  end

  wire [7:0] shown = (SW[9]) ? B : A;
  seg7 h0(.x(shown[3:0]), .HEX(HEX0));
  seg7 h1(.x(shown[7:4]), .HEX(HEX1));

  assign LEDR = SW;
endmodule
```

**What we see:**  
- Data is loaded into A or B depending on SW[9].  
- HEX displays show the stored value.  
- Reset clears both registers.

---

## Conclusion
- We successfully designed and tested **RS latches, D latches, flip-flops, and registers**.  
- Learned the difference between **level-sensitive latches** and **edge-triggered flip-flops**.  
- Verified register storage by displaying values on the **7-segment displays**.  
- Results matched both simulation and hardware testing on DE10-Lite.

---
