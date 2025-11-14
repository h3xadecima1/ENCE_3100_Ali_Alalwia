#!/usr/bin/env python3
"""
generate_microcode_full_nmos.py
Creates a 256×40-bit microcode table (microcode_full_nmos.hex)
for a microcoded 6502 core.  Each opcode gets a placeholder
control word that you can refine later.
"""

OPCODES = {
    0x00: "BRK", 0x01: "ORA (Indirect,X)", 0x05: "ORA zp", 0x06: "ASL zp",
    0x08: "PHP", 0x09: "ORA #imm", 0x0A: "ASL A", 0x0D: "ORA abs",
    0x0E: "ASL abs", 0x10: "BPL", 0x18: "CLC", 0x20: "JSR",
    0x24: "BIT zp", 0x25: "AND zp", 0x29: "AND #imm", 0x2A: "ROL A",
    0x2D: "AND abs", 0x30: "BMI", 0x38: "SEC", 0x4C: "JMP abs",
    0x60: "RTS", 0x69: "ADC #imm", 0x6C: "JMP (abs)", 0x78: "SEI",
    0x84: "STY zp", 0x85: "STA zp", 0x86: "STX zp",
    0x8A: "TXA", 0x8D: "STA abs", 0x98: "TYA", 0x9A: "TXS",
    0xA0: "LDY #imm", 0xA2: "LDX #imm", 0xA9: "LDA #imm",
    0xAD: "LDA abs", 0xAE: "LDX abs", 0xB0: "BCS", 0xC9: "CMP #imm",
    0xCA: "DEX", 0xD0: "BNE", 0xE8: "INX", 0xEA: "NOP",
}

# 40-bit control-word bit positions (see your microcode_rom spec)
BIT = {
    "alu_op":   (39,36),
    "load_A":   35, "load_X": 34, "load_Y": 33, "load_P": 32,
    "load_SP":  31, "load_PC":30, "inc_PC":29, "dec_SP":28, "inc_SP":27,
    "mem_read": 26, "mem_write":25,
    "set_NZVC":24, "set_D":23, "clr_D":22, "set_I":21, "clr_I":20,
    "set_B":19, "clr_B":18,
}

def bits(*names):
    """Return integer with listed control bits set."""
    val = 0
    for n in names:
        b = BIT[n]
        if isinstance(b, tuple):
            # e.g. alu_op (we set lowest bit)
            val |= (1 << b[1])
        else:
            val |= (1 << b)
    return val

def main():
    lines = []
    for opcode in range(256):
        if opcode in OPCODES:
            mnem = OPCODES[opcode]
            # --- Rough default behavior templates ---
            if mnem.startswith("LDA") or mnem.startswith("LDX") or mnem.startswith("LDY"):
                ctrl = bits("mem_read","load_A","inc_PC","set_NZVC")
            elif mnem.startswith("STA") or mnem.startswith("STX") or mnem.startswith("STY"):
                ctrl = bits("mem_write","set_NZVC")
            elif mnem.startswith("ADC") or mnem.startswith("SBC"):
                ctrl = bits("alu_op","load_A","set_NZVC","inc_PC")
            elif mnem in ("DEX","DEY"):
                ctrl = bits("alu_op","load_X","set_NZVC")
            elif mnem == "INX":
                ctrl = bits("alu_op","load_X","set_NZVC")
            elif mnem == "JMP abs" or mnem == "JMP (abs)":
                ctrl = bits("load_PC")
            elif mnem == "JSR":
                ctrl = bits("dec_SP","mem_write","load_PC")
            elif mnem == "RTS":
                ctrl = bits("inc_SP","mem_read","load_PC")
            elif mnem.startswith("B") and len(mnem) == 3:  # Branches
                ctrl = bits("inc_PC")
            elif mnem == "BRK":
                ctrl = bits("set_B")
            elif mnem == "NOP":
                ctrl = 0
            else:
                ctrl = 0
        else:
            # Illegal opcode placeholder
            ctrl = bits("set_B")  # mark as illegal
            mnem = "ILLEGAL"

        line = f"{ctrl:010X}  // ${opcode:02X} {mnem}"
        lines.append(line)

    with open("microcode_full_nmos.hex", "w") as f:
        f.write("\n".join(lines))
    print("✅ Wrote microcode_full_nmos.hex with 256 entries.")

if __name__ == "__main__":
    main()
