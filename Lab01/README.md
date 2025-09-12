# Scrolling "HELO" Verilog Code

## Module Declaration
```verilog
module main (
    input MAX10_CLK1_50,     // 50 MHz clock
    output reg [7:0] HEX5,
    output reg [7:0] HEX4,
    output reg [7:0] HEX3,
    output reg [7:0] HEX2,
    output reg [7:0] HEX1,
    output reg [7:0] HEX0
);
```
- The FPGA receives the **50 MHz oscillator** (`MAX10_CLK1_50`).
- It drives six seven-segment displays (`HEX5..HEX0`).
- Each HEX is **8 bits wide**: 7 for segments a–g, 1 for the decimal point.
- Displays are **active-low**: `0` lights a segment, `1` turns it off.

---

## Segment Patterns
```verilog
localparam BLANK = 8'b11111111;
localparam H     = 8'b10001001;
localparam E     = 8'b10000110;
localparam L     = 8'b11000111;
localparam O     = 8'b11000000;
```
- Predefined **active-low patterns** for `H`, `E`, `L`, `O`, and a blank space.

---

## Message Buffer
```verilog
parameter MSG_LEN = 10;
reg [7:0] message [0:MSG_LEN-1];
initial begin
    message[0] = H;
    message[1] = E;
    message[2] = L;
    message[3] = O;
    message[4] = BLANK;
    message[5] = BLANK;
    message[6] = BLANK;
    message[7] = BLANK;
    message[8] = BLANK;
    message[9] = BLANK;
end
```
- Array of **10 characters**: `"HELO    "`.
- Defines the text to scroll across the displays.

---

## Index Register
```verilog
integer index = 0;
```
- Tracks **which character** is currently at HEX0.
- Advances over time to slide the text left.

---

## Clock Divider
```verilog
reg [25:0] divcnt = 0;
reg tick = 0;
always @(posedge MAX10_CLK1_50) begin
    if (divcnt == 25_000_000) begin
        divcnt <= 0;
        tick   <= 1;
    end else begin
        divcnt <= divcnt + 1;
        tick   <= 0;
    end
end
```
- Divides the 50 MHz clock down to ~2 Hz.
- `tick` pulses high once every 0.5 seconds.

---

## Scroll Index Update
```verilog
always @(posedge MAX10_CLK1_50) begin
    if (tick) begin
        if (index == MSG_LEN-1)
            index <= 0;
        else
            index <= index + 1;
    end
end
```
- On each `tick`, `index` increments.
- When `index` reaches the end of the message, it wraps back to 0.

---

## Driving the HEX Displays
```verilog
always @(*) begin
    HEX5 = (index >= 5) ? message[index-5] : BLANK;
    HEX4 = (index >= 4) ? message[index-4] : BLANK;
    HEX3 = (index >= 3) ? message[index-3] : BLANK;
    HEX2 = (index >= 2) ? message[index-2] : BLANK;
    HEX1 = (index >= 1) ? message[index-1] : BLANK;
    HEX0 = message[index];
end
```
- Displays a **6-character window** from the message buffer.
- Example progression:
  - `index=0`: HEX0=`H`, rest blank.
  - `index=1`: HEX1=`H`, HEX0=`E`.
  - `index=2`: HEX2=`H`, HEX1=`E`, HEX0=`L`.
  - `index=3`: HEX3=`H`, HEX2=`E`, HEX1=`L`, HEX0=`O`.
  - Continues until the word scrolls off to HEX5.

---

## Summary
- **Clock divider** slows the 50 MHz clock to ~2 Hz.
- **Index counter** advances the scroll position.
- **Window logic** maps message characters onto HEX displays.
- Result: `"HELO"` scrolls from HEX0 towards HEX5, one step every half second.
