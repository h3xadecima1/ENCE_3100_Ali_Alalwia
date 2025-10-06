# Lab 4 – Verilog Counters and Display on FPGA

**Course:** ENEE / Digital Systems Laboratory  
**Lab Number:** 4 – Counters  
**Board:** Altera DE2-series (MAX10 FPGA adaptation)  
**Student:** Ali Alalwia
**Date:** 10/06/2025 

---

## Objective
The purpose of this lab is to design and implement counters in Verilog using three approaches:  
1. Structural (T flip-flops)  
2. Behavioral (`Q <= Q + 1`)  
3. Parameterized Library Modules (LPM)  

The counters are then applied to drive 7-segment displays, including a digit counter and a scrolling “HELLO” message.

---

## Equipment
- FPGA Development Board (Altera DE2-series / MAX10)  
- Quartus Prime Software  
- USB Blaster Programmer  
- Verilog HDL  
- 7-Segment Displays (HEX0–HEX5)  

---

## Part I – 8-bit Counter using T Flip-Flops

An 8-bit synchronous counter was built using T flip-flops.  
- **Inputs:** Clock, Enable, Clear  
- **Outputs:** HEX0–HEX1 display the count in hexadecimal.  

### Code Snippet
```verilog
module TFlipFlop (
    input  T, clk, clr,
    output reg Q
);
  always @(posedge clk or negedge clr) begin
    if (!clr)
      Q <= 0;
    else if (T)
      Q <= ~Q;
  end
endmodule
```

Counter Instantiation:
```verilog
TFlipFlop t0(SW[1], w_clk, SW[9], w_Q[0]);
TFlipFlop t1(SW[1], w_clk, SW[9], w_Q[1]);
// ... up to t7 for 8 bits
```

Display:
```verilog
seg7Decoder Ones(w_Q[3:0], HEX0);
seg7Decoder Tens(w_Q[7:4], HEX1);
```

<img src="img/part1.gif" alt="part1" width="500"/>
 

---

## Part II – 16-bit Counter using Behavioral Verilog

This design uses a register and the increment operator.

### Code Snippet
```verilog
reg [15:0] Q;
always @(posedge w_clk or negedge SW[9]) begin
  if (!SW[9])
    Q <= 0;
  else
    Q <= Q + 1;
end

seg7Decoder Ones(Q[3:0], HEX0);
seg7Decoder Tens(Q[7:4], HEX1);
```

<img src="img/part2.gif" alt="part2" width="500"/>
  

---

## Part III – Counter using Library of Parameterized Modules (LPM)

Implemented using Altera’s optimized LPM block.

### Code Snippet
```verilog
Counter_LPM CLPM (
    .clk_en(SW[0]),
    .clock(w_clk),
    .sclr(SW[9]),
    .q(w_Q)
);

seg7Decoder Ones(w_Q[3:0], HEX0);
seg7Decoder Tens(w_Q[7:4], HEX1);
```

<img src="img/part3.gif" alt="part3" width="500"/>

---

## Part IV – Digit Counter with 1Hz Tick

A 50 MHz clock was divided to generate a 1 Hz tick. The counter cycles through digits 0–9 on HEX0.

### Code Snippet
```verilog
// Clock divider
reg [25:0] cnt;
reg tick;
always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
  if (!rst_n) begin
    cnt <= 0; tick <= 0;
  end else if (cnt == 50_000_000-1) begin
    cnt <= 0; tick <= 1;
  end else begin
    cnt <= cnt + 1; tick <= 0;
  end
end

// Digit counter
reg [3:0] digit;
always @(posedge MAX10_CLK1_50 or negedge rst_n) begin
  if (!rst_n)
    digit <= 0;
  else if (tick)
    digit <= (digit == 9) ? 0 : digit + 1;
end

seg7Decoder h0(.i_bin(digit), .o_HEX(HEX0));
```

<img src="img/part4.gif" alt="part4" width="500"/>

---

## Part V – Scrolling “HELLO” Display

Implements a ticker-tape scrolling message across HEX displays.  

### Code Snippet
```verilog
// Message buffer
reg [2:0] msg [0:4];
initial begin
  msg[0]=3'd0; msg[1]=3'd1; msg[2]=3'd2;
  msg[3]=3'd2; msg[4]=3'd3; // HELLO
end

// Index shift
reg [2:0] i;
always @(posedge CLOCK_50 or negedge rst_n) begin
  if (!rst_n) i <= 0;
  else if (tick) i <= (i==3'd4) ? 0 : i + 1;
end

// Display two letters
seg7_letter L (.code(msg[i]), .HEX(HEX1));
seg7_letter R (.code(msg[(i==3'd4)? 0 : i+1]), .HEX(HEX0));
```

<img src="img/part5.gif" alt="part5" width="500"/> 

---

## Conclusions
- Structural design (flip-flops) shows fundamentals but uses more resources.  
- Behavioral design (`Q <= Q + 1`) is simple and practical.  
- LPM counter is most resource-efficient.  
- Counters can be applied in real designs such as digit tickers and scrolling displays.  

---

## Future Work
- Extend scrolling to multiple words.  
- Implement counters with FSM control.  
- Explore higher-speed counter applications.  
