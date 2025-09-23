# Lab 2 (Verilog on DE10-Lite)

## Overview
This lab explores **combinational logic design** using Verilog on the DE10-Lite FPGA.  
We design circuits to perform:

- Binary-to-decimal conversion  
- Binary-Coded Decimal (BCD) operations  
- Full adders and ripple-carry adders  
- Multi-digit BCD addition  
- Binary to BCD conversion  

All results are displayed on the **HEX7-segment displays** of the DE10-Lite board, with inputs coming from **slide switches (SW)**.

---

## Hardware Used
- **DE10-Lite FPGA Development Board**
  - Intel MAX 10 FPGA
  - 10 slide switches (SW9–SW0)
  - 6 seven-segment HEX displays (HEX5–HEX0)
  - 10 LEDs (LEDR9–0)
- Quartus Prime Lite Edition

---

## Part I – Displaying Switch Values
- **Goal**: Show values of SW[15–0] on HEX3–HEX0 (adapted for DE10-Lite).  
- Each 4-bit group drives one HEX display.  
- Digits 0–9 shown correctly; 10–15 treated as don’t-cares.

```verilog
// Example 7-segment decoder
module seg7_dec(
    input i3, i2, i1, i0,
    output [7:0] o_seg
);
    assign o_seg[0] = ~((~i3 & ~i2 & ~i1 & i0) |
                        (~i3 & i2 & ~i1 & ~i0));
    // … (remaining segments logic)
endmodule
```

<img src="img/1.gif" alt="APart1" width="500"/>

---

## Part II – Binary to Decimal Conversion (4-bit)
- **Goal**: Convert a 4-bit binary input `V` into two decimal digits `d1d0`.  
- Uses comparator, multiplexers, and circuit A.  
- Output displayed on HEX1 (tens) and HEX0 (ones).

```verilog
// Example binary-to-decimal (4-bit)
bin_to_dec b2d (
    .i_v3(SW[3]), .i_v2(SW[2]), .i_v1(SW[1]), .i_v0(SW[0]),
    .o_seg0(HEX0), .o_seg1(HEX1)
);
```

<img src="img/2.gif" alt="Part2" width="500"/>

---

## Part III – Full Adder and Ripple-Carry Adder
- **Goal**: Build a full adder, then a 4-bit ripple-carry adder.  
- **Inputs**: SW[3:0] = A, SW[7:4] = B, SW[8] = Cin.  
- **Outputs**: LEDR = inputs, HEX/LEDG = sum + carry-out.

```verilog
module FA(input a, b, cin, output s, cout);
    assign {cout, s} = a + b + cin;
endmodule

module adder_4bit(input [3:0] i_a, i_b, input i_cin,
                  output o_cout, output [3:0] o_s);
    wire c1, c2, c3;
    FA fa0(i_a[0], i_b[0], i_cin, o_s[0], c1);
    FA fa1(i_a[1], i_b[1], c1,     o_s[1], c2);
    FA fa2(i_a[2], i_b[2], c2,     o_s[2], c3);
    FA fa3(i_a[3], i_b[3], c3,     o_s[3], o_cout);
endmodule
```

<img src="img/3.gif" alt="Part3" width="500"/>


---

## Part IV – BCD Adder (Single Digit)
- **Goal**: Add two BCD digits (A and B).  
- Input: SW[3:0] and SW[7:4].  
- Carry-in: SW[8].  
- Output: BCD sum S1S0 displayed on HEX1–HEX0.  
- If input > 9, error indicated by LEDR[9].

```verilog
module bcd_adder(
    input [3:0] A, B, input Cin,
    output reg [3:0] Sum, output reg Cout
);
    reg [4:0] temp;
    always @(*) begin
        temp = A + B + Cin;
        if (temp > 9) begin
            temp = temp + 6;
            Cout = 1;
        end else Cout = 0;
        Sum = temp[3:0];
    end
endmodule
```

<img src="img/4.gif" alt="Part4" width="500"/>


---

## Part V – Two-Digit BCD Adder
- **Goal**: Add two 2-digit BCD numbers (A1A0 + B1B0).  
- Built using two instances of Part IV’s BCD adder.  
- Output: 3-digit BCD sum S2S1S0 on HEX2–HEX0.

```verilog
module bcd_2digit_adder(
    input [3:0] A0, A1, B0, B1,
    output [3:0] S0, S1, S2
);
    wire c1, c2;
    bcd_adder U0 (A0, B0, 0, S0, c1);
    bcd_adder U1 (A1, B1, c1, S1, c2);
    assign S2 = {3'b000, c2};
endmodule
```

<img src="img/5.gif" alt="Part5" width="500"/>


---

## Part VI – Two-Digit BCD Adder (Behavioral)
- **Goal**: Reimplement Part V using **if/else pseudo-code**.  
- RTL schematic differs (uses comparators + multiplexers inferred automatically).

```verilog
always @(*) begin
    T0 = A0 + B0;
    if (T0 > 9) begin
        S0 = T0 - 10;
        c1 = 1;
    end else begin
        S0 = T0;
        c1 = 0;
    end
    T1 = A1 + B1 + c1;
    if (T1 > 9) begin
        S1 = T1 - 10;
        c2 = 1;
    end else begin
        S1 = T1;
        c2 = 0;
    end
    S2 = c2;
end
```

<img src="img/6.gif" alt="Part6" width="500"/>


---

## Part VII – Binary to BCD Conversion (Mandatory for Graduate Students)
- **Goal**: Convert a **6-bit binary number (0–63)** into **two-digit decimal (BCD)**.  
- Input: SW[5:0].  
- Output: HEX1 = tens, HEX0 = ones.

```verilog
wire [5:0] bin = SW[5:0];
wire [3:0] tens, ones;

assign tens = bin / 10;
assign ones = bin % 10;

hex7seg h0(ones, HEX0);
hex7seg h1(tens, HEX1);
```

✅ Example:  
- SW = `010101` (21 decimal) → HEX1=2, HEX0=1  
- SW = `111111` (63 decimal) → HEX1=6, HEX0=3  

<img src="img/7.gif" alt="Part7" width="500"/>


---

## Lessons Learned
- Difference between **binary** and **BCD** encoding.  
- Practical FPGA use of **switches → HEX displays**.  
- Structural vs behavioral Verilog styles.  
- Binary-to-decimal conversion on limited hardware.  

---

## How to Run
1. Open Quartus Prime Lite.  
2. Create a new project.  
3. Add `main.v` and supporting modules.  
4. Assign pins according to DE10-Lite manual.  
5. Compile & program FPGA.  
6. Toggle switches and observe HEX outputs.  

```
