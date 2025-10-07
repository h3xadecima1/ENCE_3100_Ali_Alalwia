# 💡 Lab 5 – Adders, Subtractors, and Multipliers (Verilog HDL)

**Course:** ENEE 2223 – Advanced Electronics  
**Board:** Intel/Altera DE10-Lite (MAX10 FPGA)  
**Language:** Verilog HDL  
**Student:** *[Your Name]*  
**Date:** *[Insert Date]*  

---

## 🧩 Objective
This lab demonstrates the design and implementation of arithmetic logic circuits using **Verilog HDL** on the **DE10-Lite FPGA**.  
Each section progressively builds from basic addition to more complex multiplier architectures using hierarchical and modular design principles.

You will:
- Design adders, subtractors, and multipliers using logic components.  
- Use **registers** and **clock control** for sequential data storage.  
- Display results in **binary and decimal** using **BCD and 7-segment displays**.  
- Compare **sequential vs parallel (adder-tree)** multiplier performance.

---

## ⚙️ Hardware Setup
| Component | Function |
|------------|-----------|
| **SW[9]** | Reset (active-high) |
| **SW[7:0]** | Data inputs |
| **KEY[0]** | Manual clock (debounced) |
| **LEDR[9:0]** | Binary output indicators |
| **HEX0–HEX5** | 7-segment decimal display outputs |

---

## ⚙️ Part I – 8-bit Accumulator (Adder)

### 🧠 Functional Overview
An **accumulator** is a sequential adder that stores a running sum of input values.  
Each time `KEY[0]` (the debounced clock) is pressed, the input from `SW[7:0]` is added to the current total.

### 🔩 Logical Explanation
- **Components Used:**
  - **8-bit Adder** (built using 8 full adders internally)
  - **8-bit Register** to store the accumulated value
  - **Debounce Circuit** to generate clean clock pulses
  - **Binary-to-BCD Converter** for display on HEX
  - **7-Segment Decoder** for output display

- **Logic Flow:**
  1. Input value from switches (`SW[7:0]`) enters the adder.
  2. The adder adds this value to the previous total stored in the accumulator register.
  3. On each clock pulse (KEY[0]), the new sum is written back into the register.
  4. The sum is displayed both in binary (LEDR) and decimal (HEX0–HEX2).
  5. `SW[9]` resets the register to zero.

### 🔧 Code Snippet
```verilog
accumulator_8bit Acc_8bit (
    .i_A(SW[7:0]),
    .i_clk(w_myClk),
    .i_rst(SW[9]),
    .o_overflow(LEDR[8]),
    .o_S(w_sum)
);
```

📸 *Insert diagram or simulation waveform:*  
`![Part I – Accumulator Logic](images/part1.png)`

---

## ⚙️ Part II – 8-bit Adder/Subtractor

### 🧠 Functional Overview
This module performs both **addition and subtraction** on 8-bit data depending on the control input `SW[8]`.

### 🔩 Logical Explanation
- **Components Used:**
  - **8-bit Adder/Subtractor Unit**: built using XOR gates and full adders.
  - **8-bit Register** for accumulated result storage.
  - **Control Line (SW[8])**: acts as a multiplexer control for add/sub.
  - **Binary-to-BCD Converter** and **7-segment display decoders**.

- **Logic Flow:**
  1. Each bit of B input is XORed with `SW[8]` to create either B or its 1’s complement.
  2. A carry-in equal to `SW[8]` performs subtraction when `SW[8] = 1`.
  3. The 8-bit adder computes either `A + B` or `A – B`.
  4. The result is stored in a register and updated on every clock press.
  5. Overflow is detected and displayed on `LEDR[8]`.

### 🔧 Code Snippet
```verilog
accumulator_sub_8bit Acc_sub (
    .i_A(SW[7:0]),
    .i_addsub(SW[8]),
    .i_clk(w_myClk),
    .i_rst(SW[9]),
    .o_overflow(LEDR[8]),
    .o_S(w_sum)
);
```

📸 *Insert schematic or waveform:*  
`![Part II – Adder/Subtractor Logic](images/part2.png)`

---

## ⚙️ Part III – 4×4 Multiplier

### 🧠 Functional Overview
This circuit multiplies two 4-bit binary numbers (`A = SW[7:4]`, `B = SW[3:0]`) and displays their 8-bit product.

### 🔩 Logical Explanation
- **Components Used:**
  - **AND Gates**: to generate 16 partial products (4x4 matrix of AND operations)
  - **Half Adders / Full Adders**: to sum partial products
  - **Shift Logic**: aligns bits according to binary place value
  - **Binary-to-BCD Converter** and **7-segment decoders**

- **Logic Flow:**
  1. Each bit of A is ANDed with each bit of B to form partial products.
  2. The partial products are arranged in shifted rows.
  3. Adders combine the shifted partial products.
  4. The final 8-bit product is sent to both LEDR and HEX displays.
  5. Overflow flag signals if the result exceeds 8 bits.

### 🔧 Code Snippet
```verilog
multiplier_4x4 MT_4by4 (
    .i_A(SW[7:4]),
    .i_B(SW[3:0]),
    .o_P(w_Product),
    .o_Overflow(LEDR[8])
);
```

📸 *Insert schematic or simulation waveform:*  
`![Part III – 4×4 Multiplier Logic](images/part3.png)`

---

## ⚙️ Part IV – 8×8 Sequential Multiplier (Adder Chain)

### 🧠 Functional Overview
Implements an **8×8 multiplier** using a **chain of adders**.  
Each stage adds one shifted partial product sequentially, resulting in longer propagation delay.

### 🔩 Logical Explanation
- **Components Used:**
  - **AND Gates** for 64 partial products.
  - **Multiple 8-bit Adders** connected sequentially.
  - **Registers** for A, B, and product storage.
  - **Binary-to-BCD Converter** for displaying large numbers.
  - **7-Segment Display Decoders**.

- **Logic Flow:**
  1. Partial products are generated by ANDing bits of A and B.
  2. Each partial product is shifted based on its bit position.
  3. Adders sum these partial products one after another (forming a ripple chain).
  4. The result is stored in a 16-bit product register.
  5. The registered output is converted to decimal for display.

**Drawback:** Sequential addition introduces large propagation delay, making it slower.

### 🔧 Code Snippet
```verilog
multiplier_8x8 MT_8by8 (
    .i_A(8'd100),
    .i_B(SW[7:0]),
    .o_P(w_Product),
    .o_Overflow(LEDR[9])
);
```

📸 *Insert timing waveform or schematic:*  
`![Part IV – 8×8 Sequential Multiplier Logic](images/part4.png)`

---

## ⚙️ Part V – 4×4 Adder-Tree Multiplier (Parallel Design)

### 🧠 Functional Overview
This design replaces the long chain of adders with a **parallel adder tree**, allowing faster computation by performing multiple additions simultaneously.

### 🔩 Logical Explanation
- **Components Used:**
  - **AND Gates** to generate partial products.
  - **Adder Tree Structure** composed of multiple 8-bit adders operating in parallel.
  - **Registers** for input and output synchronization.
  - **Binary-to-BCD Converter** and **7-Segment Display** for output.

- **Logic Flow:**
  1. Each bit of B selects a row of ANDed partial products.
  2. The 4 rows of partial products are aligned (shifted according to bit index).
  3. **Stage 1:** Two adders sum partial products in pairs (`pp0 + pp1`, `pp2 + pp3`).
  4. **Stage 2:** One final adder sums the results from Stage 1.
  5. The output register captures the final product.
  6. The result is displayed as binary on LEDs and decimal on HEX.

**Advantage:** The tree structure shortens the critical path, significantly improving fmax and overall performance.

### 🔧 Code Snippet
```verilog
multiplier_4x4_addertree MT_4by4 (
    .i_A(w_Q_A),
    .i_B(w_Q_B),
    .o_P(w_Product),
    .o_Overflow(LEDR[9])
);
```

📸 *Insert block diagram or timing analysis:*  
`![Part V – Adder-Tree Multiplier Logic](images/part5.png)`

---

## 🧱 Submodule Explanations

| Module | Logic Components | Description |
|--------|------------------|--------------|
| **`reg_nbit.v`** | D flip-flops | Parameterized register for N-bit storage |
| **`debounce.v`** | Counter + Comparator | Filters out mechanical switch noise to generate clean clock pulses |
| **`bin8_to_bcd.v`, `bin16_to_bcd.v`** | Adders + Comparators | Converts binary number to decimal representation |
| **`seg7Decoder.v`** | Decoder Logic | Translates BCD digits into 7-segment display patterns |
| **`multiplier_4x4.v`** | AND + Adders | Generates partial products and sums them combinationally |
| **`multiplier_8x8.v`** | AND + Sequential Adders | Slower chain-based 8×8 multiplication |
| **`multiplier_4x4_addertree.v`** | AND + Parallel Adders | Fast adder-tree structure for parallel multiplication |

---

## 🧪 Testing Procedure

1. Compile and program the FPGA board.  
2. Reset using **SW9 = 1**, then set it back to 0.  
3. Choose inputs using switches (A and B).  
4. Press **KEY0** to apply a clock pulse.  
5. Observe binary output on **LEDR** and decimal result on **HEX displays**.  

---

## 📈 Timing Analysis

| Architecture | Method | Logic Depth | Expected Speed |
|---------------|---------|-------------|----------------|
| Part IV – Sequential | Ripple adder chain | Long | Slower |
| Part V – Adder-Tree | Parallel addition | Short | Faster |

📸 *Insert fmax comparison screenshot:*  
`![Timing Report – fmax Comparison](images/fmax.png)`

---

## ✅ Conclusion

- Demonstrated hierarchical digital design using Verilog HDL.  
- Implemented multiple arithmetic circuits with correct functional behavior.  
- Showed how logic architecture (sequential vs parallel) affects timing.  
- Verified operation on **DE10-Lite FPGA** using switches, LEDs, and 7-segment displays.  

---

## 🖼️ Image Summary

| Part | Description | Image |
|------|--------------|-------|
| I | 8-bit Accumulator (Adder) | ![Part I](images/part1.png) |
| II | 8-bit Adder/Subtractor | ![Part II](images/part2.png) |
| III | 4×4 Multiplier | ![Part III](images/part3.png) |
| IV | 8×8 Sequential Multiplier | ![Part IV](images/part4.png) |
| V | 4×4 Adder-Tree Multiplier | ![Part V](images/part5.png) |

---
