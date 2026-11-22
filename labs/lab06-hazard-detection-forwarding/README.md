# Lab 6: Hazard Detection and Forwarding

Adds pipeline hazard handling to the processor:

- `ForwardingUnit.v` forwards ALU operands from EX/MEM and MEM/WB.
- `HazardDetection.v` stalls one cycle on a load-use dependency and flushes on taken branches and jumps.
- `RegisterFile.v` returns the value being written when a register is read and written in the same cycle.

`controller.v` decodes the full instruction set listed in the root README, including byte/halfword memory access, `mul`, and `jal`/`jr`.

| Path | Description |
| ---- | ----------- |
| `rtl/toplevel.v` | Processor core |
| `rtl/top.v` | Board top module |
| `constraints/Two4DigitDisplay.xdc` | Board constraints |
| `mem/` | Program and data images |
| `tb/toplevel_tb.v` | Core testbench (see known issue below) |

```sh
make check
make board LAB=lab06
```

Known issue: `tb/toplevel_tb.v` was later edited for Lab 7 and connects `Readv0`/`Readv1`, which this `toplevel` does not have, so `make sim LAB=lab06` fails to elaborate.

Lab 7 reuses this directory's RTL; see `../lab07-vbsme-on-pipeline`.
