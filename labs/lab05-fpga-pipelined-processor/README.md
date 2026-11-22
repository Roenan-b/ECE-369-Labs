# Lab 5: Pipelined Processor on the FPGA

The Lab 4 pipeline, with most modules revised, plus the board wrapper. `top.v` divides the 100 MHz board clock with `ClkDiv`, runs the core, and shows the low 16 bits of the PC and of the write-back data on two 4-digit seven-segment displays (`Two4DigitDisplay`, `SevenSegment`).

| Path | Description |
| ---- | ----------- |
| `rtl/top.v` | Board top module |
| `rtl/toplevel.v` | Processor core |
| `constraints/Two4DigitDisplay.xdc` | Clock, reset, and seven-segment pin constraints |
| `mem/` | Program and data images |
| `tb/toplevel_tb.v` | Core testbench (see known issue below) |

```sh
make check              # core elaborates
make board LAB=lab05    # board wrapper elaborates
```

Known issue: `tb/toplevel_tb.v` connects `instructionWrite`, `WB_RegWrite`, and `WB_WriteReg`, which this version of `toplevel` does not have, so `make sim LAB=lab05` fails to elaborate.
