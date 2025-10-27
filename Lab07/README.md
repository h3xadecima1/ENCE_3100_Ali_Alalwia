# UART Word Detection & Display System on DE10-Lite  
**Comprehensive Lab Report — Verilog-2001 Implementation**  
**Author:** Ali G  
**Board:** Intel DE10-Lite (MAX10 FPGA)  
**Clock Frequency:** 50 MHz  
**Objective:** Detect the word **“hello”** sent via UART and blink the word **“HELLO”** on the HEX displays for 3 seconds.  

<img src="img/Lab07.gif" alt="Lab07_animation" width="500"/>
---

## 🧠 1. Abstract
This project implements a **UART-based word detection system** on the Intel DE10-Lite FPGA board. The FPGA receives ASCII characters through UART communication at 115200 baud. When the word `"hello"` is received, the system activates a **Finite State Machine (FSM)** that displays `"HELLO"` on the board’s 7-segment HEX displays (`HEX4` to `HEX0`), blinking for 3 seconds.  

This design demonstrates digital communication, finite state machines, and timed display control using Verilog HDL.

---

## 🧩 2. System Overview
The system integrates three major subsystems:

1. **UART Communication Core** (Receiver + Transmitter)
2. **Finite State Machine Word Detector**
3. **Display Control Logic (HEX + LED Visualization)**

These blocks interact as follows:

```
+--------------------------------------------------------------+
|                          DE10-Lite                           |
|                                                              |
|  +-------------------+       +----------------------------+  |
|  |  UART Receiver    |-----> |                            |  |
|  | (async_receiver)  |       |   FSM_Word_Detecter        |  |
|  +-------------------+       |  Detects "hello" & drives  |  |
|          |                   |  HEX displays (blinking)   |  |
|          v                   +-------------^--------------+  |
|  +-------------------+                     |                 |
|  |  UART Transmitter |<--------------------+                 |
|  +-------------------+                                       |
|          |                                                   |
|          +--> LEDR[7:0] shows ASCII value                    |
+--------------------------------------------------------------+
```

---

## ⚙️ 3. UART Communication Theory

**UART (Universal Asynchronous Receiver/Transmitter)** converts parallel data into serial and vice versa without requiring a clock signal between devices.

**Transmission Format (8N1):**
```
Idle (1) | Start (0) | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Stop (1)
```
- 1 start bit (low)
- 8 data bits (LSB first)
- 1 stop bit (high)
- No parity bit
- Baud rate: **115200 baud**

**Why 115200 baud?** It’s a standard rate easily divisible from 50 MHz (system clock). The provided `async_receiver` and `async_transmitter` modules handle all sampling and timing internally.

---

## 🔧 4. Top Module — `main.v`

This file integrates UART RX/TX modules, the FSM, and board I/O.

### 📜 Full Code
```verilog
`default_nettype none

module main(
    input        MAX10_CLK1_50,
    input  [9:0] SW,
    output [9:0] LEDR,
    inout  [35:0] GPIO,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6
);
    wire w_clk = MAX10_CLK1_50;

    // UART receiver signals
    wire RxD_data_ready;
    wire [7:0] RxD_data;
    reg  [7:0] GPout;

    // UART Receiver (115200 baud)
    async_receiver RX (
        .clk(w_clk),
        .RxD(GPIO[35]),
        .RxD_data_ready(RxD_data_ready),
        .RxD_data(RxD_data)
    );

    // UART Transmitter (echo back)
    async_transmitter TX (
        .clk(w_clk),
        .TxD(GPIO[33]),
        .TxD_start(RxD_data_ready),
        .TxD_data(RxD_data)
    );

    // Store received byte
    always @(posedge w_clk) begin
        if (RxD_data_ready)
            GPout <= RxD_data;
    end

    // Display received byte on LEDs
    assign LEDR[7:0] = GPout;

    // FSM word detector for "hello"
    FSM_Word_Detecter word_detector (
        .clk(w_clk),
        .reset(SW[9]),
        .RXD_data(GPout),
        .data_ready(RxD_data_ready),
        .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4)
    );

    // Blank unused HEX displays
    assign HEX5 = 7'b1111111;
    assign HEX6 = 7'b1111111;

endmodule

`default_nettype wire
```

---

### 🧠 Explanation (Line by Line)

#### 1️⃣ Module Declaration
```verilog
module main(
    input MAX10_CLK1_50,
    input [9:0] SW,
    output [9:0] LEDR,
    inout [35:0] GPIO,
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6
);
```
- Declares the top-level FPGA I/O interface.
- `MAX10_CLK1_50`: 50 MHz onboard oscillator.
- `SW[9:0]`: 10 slide switches; only SW[9] used as reset.
- `LEDR[9:0]`: 10 on-board red LEDs.
- `GPIO[35:0]`: general-purpose I/O header, here used for UART.
- `HEX0–HEX6`: seven 7-segment display buses (active-low).

#### 2️⃣ Clock Signal Alias
```verilog
wire w_clk = MAX10_CLK1_50;
```
- Creates a simpler internal name for readability.

#### 3️⃣ UART Receiver
```verilog
wire RxD_data_ready;
wire [7:0] RxD_data;
async_receiver RX (...);
```
- `RxD_data_ready` pulses **for one clock cycle** each time a byte is fully received.
- `RxD_data` contains the received 8-bit ASCII code.
- Input `GPIO[35]` is the RX line (connect to USB-UART TX).

#### 4️⃣ UART Transmitter
```verilog
async_transmitter TX (...);
```
- Echoes data back to the terminal.
- Starts a transmission whenever `RxD_data_ready` is asserted.

#### 5️⃣ Data Storage
```verilog
always @(posedge w_clk)
    if (RxD_data_ready)
        GPout <= RxD_data;
```
- Stores the most recent character for both LED and FSM use.

#### 6️⃣ LED Display
```verilog
assign LEDR[7:0] = GPout;
```
- Displays the binary representation of the received ASCII character.

#### 7️⃣ FSM Integration
```verilog
FSM_Word_Detecter word_detector (...);
```
- Processes incoming characters to detect `"hello"`.
- Drives HEX displays.

#### 8️⃣ HEX Display Blanking
```verilog
assign HEX5 = 7'b1111111;
assign HEX6 = 7'b1111111;
```
- Turns off unused HEX displays (active-low).

---

## ⚙️ 5. FSM — `FSM_Word_Detecter.v`

The FSM verifies sequential characters “h”, “e”, “l”, “l”, “o”.  
If detected, it triggers a 3-second display sequence with blinking “HELLO”.

### 📜 Full Code
```verilog
`default_nettype none
module FSM_Word_Detecter(
    input clk,
    input reset,
    input [7:0] RXD_data,
    input data_ready,
    output reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4
);
    localparam [2:0]
        S_IDLE = 3'd0, S_H = 3'd1, S_HE = 3'd2,
        S_HEL = 3'd3, S_HELL = 3'd4, S_DONE = 3'd5, S_SHOW = 3'd6;

    localparam integer CNT_3S = 150_000_000;
    localparam integer CNT_BLINK = 25_000_000;

    reg [2:0] state, next_state;
    reg [27:0] counter;
    reg blink_state;
    wire done_3s = (counter >= CNT_3S);

    always @(posedge clk or posedge reset)
        if (reset) state <= S_IDLE;
        else state <= next_state;

    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:  if (data_ready && RXD_data=="h") next_state=S_H;
            S_H:     if (data_ready && RXD_data=="e") next_state=S_HE;
                      else if (data_ready) next_state=S_IDLE;
            S_HE:    if (data_ready && RXD_data=="l") next_state=S_HEL;
                      else if (data_ready) next_state=S_IDLE;
            S_HEL:   if (data_ready && RXD_data=="l") next_state=S_HELL;
                      else if (data_ready) next_state=S_IDLE;
            S_HELL:  if (data_ready && RXD_data=="o") next_state=S_DONE;
                      else if (data_ready) next_state=S_IDLE;
            S_DONE:  next_state = S_SHOW;
            S_SHOW:  if (done_3s) next_state = S_IDLE;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0; blink_state <= 1'b1;
        end else if (state==S_SHOW) begin
            counter <= counter + 1;
            if (counter % CNT_BLINK == 0)
                blink_state <= ~blink_state;
        end else begin
            counter <= 0; blink_state <= 1'b1;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) {HEX0,HEX1,HEX2,HEX3,HEX4} <= {5{7'b1111111}};
        else case(state)
            S_SHOW,S_DONE:
                if (blink_state) begin
                    HEX4<=seg_H(1'b0); HEX3<=seg_E(1'b0);
                    HEX2<=seg_L(1'b0); HEX1<=seg_L(1'b0);
                    HEX0<=seg_O(1'b0);
                end else {HEX0,HEX1,HEX2,HEX3,HEX4}<={5{7'b1111111}};
            default: {HEX0,HEX1,HEX2,HEX3,HEX4}<={5{7'b1111111}};
        endcase
    end

    function [6:0] seg_H; input d; begin seg_H=7'b0001001; end endfunction
    function [6:0] seg_E; input d; begin seg_E=7'b0000110; end endfunction
    function [6:0] seg_L; input d; begin seg_L=7'b1000111; end endfunction
    function [6:0] seg_O; input d; begin seg_O=7'b1000000; end endfunction
endmodule
`default_nettype wire
```

---

### Detailed Explanation

#### FSM State Encoding
Each character is matched sequentially:
| State | Expected Input | Description |
|--------|----------------|--------------|
| `S_IDLE` | `'h'` | Waiting for start of sequence |
| `S_H` | `'e'` | 'h' found, expecting 'e' |
| `S_HE` | `'l'` | 'he' found |
| `S_HEL` | `'l'` | 'hel' found |
| `S_HELL` | `'o'` | 'hell' found |
| `S_DONE` | – | Word detected |
| `S_SHOW` | – | Display & blink "HELLO" |

#### Timer & Blink Logic
- Counter increments while in `S_SHOW`.
- `CNT_BLINK` toggles the display every 0.5s.
- `CNT_3S` defines the total blink duration.

#### Display Logic
Each HEX digit uses a function to encode letters (active-low):
| Letter | Pattern | Description |
|---------|----------|-------------|
| **H** | `0001001` | Vertical bars + crossbar |
| **E** | `0000110` | Classic "E" pattern |
| **L** | `1000111` | Left vertical + bottom bar |
| **O** | `1000000` | Full circle |

---

## 🕒 6. FSM Block Diagram
```
Reset
 ↓
+-------+  'h'  +-----+  'e'  +-----+  'l'  +------+  'l'  +------+  'o'   +------+ 
| IDLE  |-----> |  H  |-----> | HE  |-----> | HEL  |-----> | HELL |----->  | HELLO |
+-------+       +-----+       +-----+       +------+       +------+        +------+
                                                                                |
                                                                                v
                                                                             +------+
                                                                             |DONE  |
                                                                             +------+
                                                                                 |
                                                                                 v
                                                                             +------+
                                                                             |SHOW  |
                                                                             +------+
                                                                |
                                                                          after 3 s ↩
```

---

## 🧪 7. Testing & Verification

| Test | Input | Expected Output | Observed |
|------|--------|----------------|-----------|
| Type “hello” | UART @115200 baud | HELLO blinks 3s | ✅ |
| Any other string | – | No display | ✅ |
| Reset (SW[9]) | – | Clears HEX | ✅ |

---

## 🚀 8. Future Improvements
- Case-insensitive detection (`HELLO` or `hello`).  
- Support multiple words (“world”, “test”).  
- Adjustable blink time via switches.  
- Add scrolling display on HEXs.  

---

## 🧾 9. Conclusion
This project integrates digital communication, sequential logic, and display control into one cohesive Verilog design. The UART interface enables real-time serial input, while the FSM demonstrates finite state transitions with conditional timing and output control. The blinking “HELLO” display validates synchronized timing and multi-module integration on the DE10-Lite FPGA.

**Skills Demonstrated:**
- UART serial communication design  
- FSM-based control logic  
- Timer/counter implementation  
- 7-segment encoding and multiplexing  
- Modular Verilog design integration  

---