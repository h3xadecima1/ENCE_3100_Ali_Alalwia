#!/usr/bin/env python3
"""
generate_microcode_full_nmos_v3.py
Generates 768×40-bit microcode image for an NMOS 6502 with
stack + interrupt micro-ops.  (3 microsteps/opcode × 256 opcodes)
"""

BIT = {
    "alu_op":   (39,36),
    "load_A":   35, "load_X": 34, "load_Y": 33, "load_P": 32,
    "load_SP":  31, "load_PC":30, "inc_PC":29, "dec_SP":28, "inc_SP":27,
    "mem_read": 26, "mem_write":25,
    "set_NZVC":24, "set_D":23, "clr_D":22, "set_I":21, "clr_I":20,
    "set_B":19, "clr_B":18,
}

def bits(*names):
    val = 0
    for n in names:
        b = BIT[n]
        if isinstance(b, tuple):  # alu_op
            val |= (1 << b[1])
        else:
            val |= (1 << b)
    return val

def word(*names): return f"{bits(*names):010X}"

def micro_for_opcode(op):
    """Return (fetch, execute, writeback) 40-bit words."""
    f = word("mem_read","inc_PC")  # universal FETCH
    # EXEC + WRITEBACK vary
    if op == 0xA9:   e, w = word("mem_read","load_A","inc_PC","set_NZVC"), word("set_NZVC")      # LDA #imm
    elif op == 0x85: e, w = word("mem_write"), word()                                             # STA zp
    elif op == 0x20: e, w = word("dec_SP","mem_write","load_PC"), word("set_I")                   # JSR
    elif op == 0x60: e, w = word("inc_SP","mem_read","load_PC"), word("clr_B")                    # RTS
    elif op == 0x48: e, w = word("dec_SP","mem_write"), word("set_B")                             # PHA
    elif op == 0x68: e, w = word("inc_SP","mem_read","load_A","set_NZVC"), word()                 # PLA
    elif op == 0x08: e, w = word("dec_SP","mem_write","set_B"), word()                            # PHP
    elif op == 0x28: e, w = word("inc_SP","mem_read","load_P"), word()                            # PLP
    elif op == 0x00: e, w = word("set_B","dec_SP","mem_write","set_I","load_PC"), word("set_I")   # BRK
    elif op == 0x40: e, w = word("inc_SP","mem_read","load_P","inc_SP"), word("mem_read","load_PC") # RTI
    elif op == 0xEA: e, w = word(), word()                                                        # NOP
    else:           e, w = word("set_B","inc_PC"), word()                                         # ILLEGAL / default
    return f, e, w

def build():
    rom = []
    for op in range(256):
        rom.extend(micro_for_opcode(op))
    return rom

def main():
    lines = build()
    with open("microcode_full_nmos.hex","w") as f:
        for i,l in enumerate(lines):
            f.write(f"{l}  // step {i:03d} opcode ${i//3:02X}\n")
    print(f"✅ Wrote microcode_full_nmos.hex ({len(lines)} entries = 3×256).")

if __name__ == "__main__":
    main()
