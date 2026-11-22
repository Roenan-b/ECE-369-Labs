# Lab 4: Pipelined Datapath

First integration of the datapath components into a five-stage pipeline (IF, ID, EX, MEM, WB) with pipeline registers `IF_ID`, `ID_EX`, `EX_MEM`, and `MEM_WB`. This lab has no hazard detection or forwarding; those arrive in Lab 6. Simulation only.

| Path | Description |
| ---- | ----------- |
| `rtl/toplevel.v` | Processor core |
| `rtl/controller.v` | Main decoder and ALU control |
| `rtl/` (others) | Fetch unit, register file, ALU, data memory, pipeline registers, muxes |
| `mem/instruction_memory.mem` | Test program (hex) |
| `mem/data_memory.mem` | Initial data memory contents |
| `tb/toplevel_tb.v` | Clock/reset testbench; observe the write-back trace |

```sh
make sim LAB=lab04
```

The testbench has no `$finish`; the run is bounded by `SIM_TIME_NS`.
