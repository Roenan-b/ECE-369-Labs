# Lab 3: VBSME in MIPS Assembly and Datapath Components

Two parts: the VBSME motion-estimation kernel written in MIPS assembly, and the datapath building blocks later reused by the pipelined processor.

| Path | Description |
| ---- | ----------- |
| `asm/vbsme.s` | VBSME kernel and course test cases (expected row/column results are in the comments) |
| `docs/vbsme_algorithm_sketch.c` | C-style pseudocode used to plan the search order; not compilable |
| `rtl/ALU32Bit.v` | 32-bit ALU: arithmetic, logic, shifts, comparisons, pass-through, zero flag |
| `rtl/RegisterFile.v` | 32 x 32-bit register file, two read ports and one write port |
| `rtl/DataMemory.v` | 32-bit data memory with word access |
| `rtl/SignExtension.v` | 16-to-32-bit sign extension |
| `rtl/Mux32Bit2To1.v` | 32-bit 2:1 multiplexer |
| `tb/*_tb.v` | One testbench per component |

```sh
make unit LAB=lab03
```

`ALU32Bit_tb` is self-checking and reports pass/fail per operation. The other testbenches are stimulus-only.

`tools/mipshelper` (MipsHelper369) assembles MIPS source into instruction and data memory contents for the Verilog memories.
