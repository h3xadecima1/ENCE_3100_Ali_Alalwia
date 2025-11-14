#!/usr/bin/env python3
"""
generate_microcode_full_nmos_v2.py
Generates 768×40-bit microcode ROM image for a microcoded NMOS 6502
(fetch/decode/execute pipeline) including illegal opcode placeholders.
Each opcode gets three micro-steps: FETCH, EXECUTE, WRITEBACK.
"""

# 40-bit control word bitfields (must match microcode_rom.v mapping)
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
        if isinstance(b, tuple):  # alu_op, set to ADD (0001)
            val |= (1 << b[1])
        else:
            val |= (1 << b)
    return val

def word(*names):
    """Format a 40-bit control word as 10 hex digits."""
    return f"{bits(*names):010X}"

def build_microsteps():
    table = []

    for opcode in range(256):
        # 1️⃣ FETCH: every instruction fetches and increments PC
        fetch = word("mem_read","inc_PC")

        # 2️⃣ EXECUTE: opcode-specific behavior
        if opcode == 0xA9:          # LDA #imm
            execu = word("mem_read","load_A","inc_PC","set_NZVC")
        elif opcode == 0xA2:        # LDX #imm
            execu = word("mem_read","load_X","inc_PC","set_NZVC")
        elif opcode == 0xA0:        # LDY #imm
            execu = word("mem_read","load_Y","inc_PC","set_NZVC")
        elif opcode == 0x8D:        # STA abs
            execu = word("mem_write")
        elif opcode == 0xE8:        # INX
            execu = word("alu_op","load_X","set_NZVC")
        elif opcode == 0xCA:        # DEX
            execu = word("alu_op","load_X","set_NZVC")
        elif opcode == 0x69:        # ADC #imm
            execu = word("alu_op","load_A","inc_PC","set_NZVC")
        elif opcode == 0x4C:        # JMP abs
            execu = word("load_PC")
        elif opcode == 0x00:        # BRK
            execu = word("set_B","dec_SP","mem_write")
        elif opcode == 0x20:        # JSR abs
            execu = word("dec_SP","mem_write","load_PC")
        elif opcode == 0x60:        # RTS
            execu = word("inc_SP","mem_read","load_PC")
        elif opcode == 0xEA:        # NOP
            execu = word()
        else:
            # illegal or not implemented
            execu = word("set_B")

        # 3️⃣ WRITEBACK: update flags, clear intermediates
        writeb = word("set_NZVC")

        table.extend([fetch, execu, writeb])
    return table

def main():
    lines = build_microsteps()
    with open("microcode_full_nmos.hex", "w") as f:
        for i, line in enumerate(lines):
            f.write(f"{line}  // step {i:03d} opcode ${i//3:02X}\n")
    print(f"✅ Generated microcode_full_nmos.hex with {len(lines)} entries (3×256).")

if __name__ == "__main__":
    main()
