# Scrolling Display with Switch-Controlled

## 📌 Overview
This project is written in **Verilog HDL** for the **Terasic DE10-Lite (Intel MAX10 FPGA)**.  
It demonstrates how to display a scrolling message across the six 7-segment displays (HEX5..HEX0) while using the onboard switches (SW[9:0]) to both control behavior and directly drive the LEDs (LEDR[9:0]).

---

## 📌 Features
- **Scrolling text**:
  - Displays the message `"HELO"` on the 7-segment HEX displays.
  - The message scrolls smoothly across HEX0 → HEX5.
- **Switch controls**:
  - `SW[0]` → Direction control
    - `0` = Scroll left
    - `1` = Scroll right
  - `SW[1]` → Pause control
    - `0` = Running
    - `1` = Paused
  - `SW[2]` → Message selection
    - `0` = Scroll `"HELO"`
    - `1` = Scroll `"HELLO WORLD"`
  - `SW[3]..SW[9]` → Reserved (no effect on scrolling, but still mapped to LEDs).
- **LED control**:
  - Each LED (`LEDR[n]`) directly mirrors its switch (`SW[n]`).
  - Example: Turn on `SW[5]` → LEDR[5] lights up.

---

## 📌 Hardware Setup
- **Board**: Terasic DE10-Lite
- **FPGA**: Intel MAX10
- **Inputs**:
  - 50 MHz clock (`MAX10_CLK1_50`)
  - Switches `SW[9:0]`
- **Outputs**:
  - LEDs `LEDR[9:0]`
  - Seven-segment displays `HEX0..HEX5`

---

## 📌 Code Structure
1. **Segment Patterns**  
   Defines active-low patterns for letters (`H`, `E`, `L`, `O`, `W`, `R`, `D`) and blank.

2. **Message Buffers**  
   Two preloaded arrays store `"HELO    "` and `"HELLO WORLD      "`.

3. **Clock Divider**  
   Divides the 50 MHz input clock down to ~2 Hz.  
   - One scroll update happens every 0.5 seconds.

4. **Scroll Index Logic**  
   - Advances the index through the message buffer.  
   - Wraps back to the start after the last character.  
   - Controlled by `SW[0]` (direction) and `SW[1]` (pause).

5. **LED Control**  
   ```verilog
   assign LEDR = SW;
   ```
   Ensures that LEDs directly follow the switches.

6. **Display Driver**  
   Maps a 6-character window of the message buffer onto HEX5..HEX0, creating the scrolling effect.

---

## 📌 Example Behavior
1. At startup:
   - HEX0 = `H`, other displays blank.
2. After 0.5s:
   - HEX1 = `H`, HEX0 = `E`.
3. After another tick:
   - HEX2 = `H`, HEX1 = `E`, HEX0 = `L`.
4. Continues until `"HELO"` has fully scrolled across the HEX displays.
5. Then the word disappears and repeats.

---

## 📌 Customization
- To change the default scroll message, edit the `message[]` array.
- To change scroll speed, adjust the divider in:
  ```verilog
  if (divcnt == 25_000_000)
  ```
  - Larger value = slower scroll.
  - Smaller value = faster scroll.

---

## 📌 File List
- `main.v` → Verilog source code
- `README.md` → Documentation (this file)

---

## 📌 Author
Created for the DE10-Lite board as an educational FPGA project to demonstrate **scrolling text, switch-based control, and LED mapping**.
