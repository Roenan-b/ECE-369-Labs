# ECE 369A: Pipelined MIPS Processor in Verilog

A five-stage pipelined processor for a MIPS32 instruction subset, written in Verilog and brought up on a Xilinx FPGA through a sequence of labs. The final design includes hazard detection, data forwarding, byte/halfword memory access, and enough of the ISA to run a motion-estimation kernel (VBSME) written in MIPS assembly.

Coursework for ECE 369A Computer Organization, University of Arizona, Fall 2025.

## Contents

- [Repository layout](#repository-layout)
- [Processor architecture](#processor-architecture)
- [Supported instructions](#supported-instructions)
- [Labs](#labs)
- [Getting started](#getting-started)
- [FPGA build with Vivado](#fpga-build-with-vivado)
- [Known issues](#known-issues)
- [Authors](#authors)

## Repository layout

```
.
├── labs/                                   Final sources for each lab
│   ├── lab01-instruction-fetch/
│   ├── lab03-vbsme-and-datapath/
│   ├── lab04-pipelined-datapath/
│   ├── lab05-fpga-pipelined-processor/
│   ├── lab06-hazard-detection-forwarding/
│   └── lab07-vbsme-on-pipeline/
├── archive/                                Earlier drafts and snapshots, kept for history
├── docs/course-materials/                  Course handouts and slides
├── tools/mipshelper/                       Course-provided MIPS assembler (MipsHelper)
├── scripts/                                Simulation helpers used by the Makefile
└── Makefile                                Icarus Verilog build and simulation targets
```

Each lab directory uses the same structure; a lab only contains the folders it needs.

| Folder         | Contents                                                     |
| -------------- | ------------------------------------------------------------ |
| `rtl/`         | Synthesizable Verilog. File names match the module they define. |
| `tb/`          | Testbenches (`*_tb.v`)                                       |
| `mem/`         | Memory images loaded with `$readmemh`                        |
| `constraints/` | Vivado `.xdc` pin and clock constraints                      |
| `asm/`         | MIPS assembly sources                                        |
| `docs/`        | Lab notes and design sketches                                |
| `scripts/`     | Lab-specific utilities                                       |

## Processor architecture

The Lab 6 and Lab 7 designs (`labs/lab06-hazard-detection-forwarding`, `labs/lab07-vbsme-on-pipeline`) implement a classic five-stage pipeline. The core module is `toplevel`; `top` wraps it for the FPGA board.

```
        IF              ID                EX                MEM              WB
  +-----------+   +-------------+   +--------------+   +------------+   +----------+
  | PC        |   | controller  |   | ALU32Bit     |   | DataMemory |   | mux3x1   |
  | PCAdder   |-->| RegisterFile|-->| Forwarding   |-->| byte/half/ |-->| ALU/Mem/ |
  | Instr.Mem |   | SignExtend  |   | muxes        |   | word       |   | PC+4     |
  +-----------+   +-------------+   +--------------+   +------------+   +----------+
         IF_ID            ID_EX              EX_MEM             MEM_WB
```

| Stage | Main modules | Notes |
| ----- | ------------ | ----- |
| IF  | `ProgramCounter`, `PCAdder`, `InstructionMemory` (in `InstructionFetchUnit`) | 1024-word instruction memory loaded from `instruction_memory.mem`. PC write can be held by the hazard unit. |
| ID  | `controller`, `RegisterFile`, `SignExtension` | 32 x 32-bit register file. Jump (`j`, `jal`) and `jr` targets are selected in ID. |
| EX  | `ALU32Bit`, `ForwardingUnit`, `Adder`, `immSL2` | Operand forwarding from EX/MEM and MEM/WB. Branch target and branch condition are computed here. |
| MEM | `DataMemory` | 1024-word data memory with byte, halfword, and word access and signed/unsigned loads. |
| WB  | `mux3x1` | Selects ALU result, load data, or PC+4 (for `jal`). |

Pipeline registers: `IF_ID.v`, `ID_EX.v`, `EX_MEM.v`, `MEM_WB.v`.

### Hazard handling

- **Forwarding** (`ForwardingUnit.v`): when an instruction in EX reads a register written by the instruction in MEM or WB, the ALU operand is taken from the EX/MEM or MEM/WB stage. EX/MEM has priority, and register `$zero` is never forwarded.
- **Load-use stall** (`HazardDetection.v`): when a load in EX writes a register that the instruction in ID reads, the PC and IF/ID register are held for one cycle and a bubble is inserted by zeroing the ID/EX control signals.
- **Control hazards**: branch decisions are registered into EX/MEM and the PC is redirected from there; a taken branch flushes IF/ID and ID/EX. Jumps and `jr` redirect the PC from ID and flush IF/ID.
- **Register file bypass** (Lab 6 and Lab 7): a read of the register being written in the same cycle returns the new value.

## Supported instructions

Decoded by `controller.v` in Lab 6 and Lab 7:

| Class | Instructions |
| ----- | ------------ |
| Arithmetic | `add`, `addi`, `sub`, `mul` |
| Logical | `and`, `andi`, `or`, `ori`, `xor`, `xori`, `nor` |
| Shift | `sll`, `srl` |
| Compare | `slt`, `slti` |
| Memory | `lw`, `sw`, `lh`, `sh`, `lb`, `sb` |
| Branch | `beq`, `bne`, `bgez`, `bgtz`, `blez`, `bltz` |
| Jump | `j`, `jal`, `jr` |

## Labs

| Lab | Directory | Summary |
| --- | --------- | ------- |
| 1 | [`lab01-instruction-fetch`](labs/lab01-instruction-fetch) | Program counter, PC adder, instruction memory, and instruction fetch unit, with a seven-segment board wrapper. |
| 2 | (none) | No Lab 2 files were committed to this repository. |
| 3 | [`lab03-vbsme-and-datapath`](labs/lab03-vbsme-and-datapath) | VBSME motion-estimation kernel in MIPS assembly, plus datapath components (ALU, register file, data memory, sign extension, 2:1 mux) with testbenches. |
| 4 | [`lab04-pipelined-datapath`](labs/lab04-pipelined-datapath) | First integrated five-stage pipelined datapath, simulation only. |
| 5 | [`lab05-fpga-pipelined-processor`](labs/lab05-fpga-pipelined-processor) | Lab 4 datapath on the FPGA with a clock divider and two 4-digit seven-segment displays. |
| 6 | [`lab06-hazard-detection-forwarding`](labs/lab06-hazard-detection-forwarding) | Hazard detection unit, forwarding unit, and pipeline flushing. |
| 7 | [`lab07-vbsme-on-pipeline`](labs/lab07-vbsme-on-pipeline) | Runs the VBSME kernel on the Lab 6 processor and exposes `$v0`/`$v1` (result row and column). Built as an overlay on Lab 6. |

### VBSME

VBSME (variable block size motion estimation) slides a window (4x4 up to 16x16 pixels) over a frame (16 to 64 pixels per side) and returns, in `$v0` (row) and `$v1` (column), the position whose sum of absolute differences (SAD) against the window is smallest. The assembly sources include the course test cases with their expected results.

## Getting started

### Prerequisites

- [Icarus Verilog](https://steveicarus.github.io/iverilog/) (tested with 12.0), for command-line simulation
- GNU Make
- Xilinx Vivado, for synthesis and programming the board
- Java runtime, only if you use the MipsHelper assembler in `tools/mipshelper`

### Simulate

```sh
make check              # elaborate every processor core and unit testbench
make sim LAB=lab04      # run a lab's toplevel_tb (copies mem/*.mem into the run directory)
make unit LAB=lab03     # run a lab's unit testbenches
make board LAB=lab05    # elaborate the FPGA wrapper (module top)
make clean
```

Simulation output goes to `build/<lab>/`. The memory modules load their images with relative paths (`$readmemh("instruction_memory.mem", ...)`), so `make sim` runs from that directory after copying the lab's `mem/` files into it. Some testbenches were written for interactive Vivado sessions and never call `$finish`; `make` bounds those runs with `SIM_TIME_NS` (default 50000):

```sh
make sim LAB=lab04 SIM_TIME_NS=200000
```

Several modules print a trace with `$display` (instruction fetch, loads, stores, decode), so expect verbose output.

## FPGA build with Vivado

1. Create an RTL project and add every file in the lab's `rtl/` directory (for Lab 7, add the Lab 6 `rtl/` files first, then the Lab 7 files, replacing the Lab 6 copies with the same name).
2. Add the lab's `mem/*.mem` files as design sources so `$readmemh` can find them during simulation and synthesis.
3. Add `constraints/Two4DigitDisplay.xdc` and set `top` as the top module.
4. Run synthesis and implementation, generate the bitstream, and program the board.

The constraint file defines a 100 MHz clock on pin E3, a reset input, and eight multiplexed seven-segment digits; these pin assignments are consistent with the Digilent Nexys A7 board. `ClkDiv` slows the processor clock so execution is visible on the display.

## Known issues

These come from the source as committed and are documented here rather than changed:

- **Lab 1**: `top.v` instantiates `Two4DigitDisplay`, which is not in the Lab 1 directory (it first appears in Lab 5). The lab also has no `instruction_memory.mem`.
- **Lab 5**: `toplevel_tb.v` connects ports (`instructionWrite`, `WB_RegWrite`, `WB_WriteReg`) that the Lab 5 `toplevel` no longer has, so `make sim LAB=lab05` does not elaborate. The core itself elaborates.
- **Lab 6**: `toplevel_tb.v` was later updated for Lab 7 and connects `Readv0`/`Readv1`, which the Lab 6 `toplevel` does not have. The core elaborates.
- **Lab 7**: `toplevel_tb.v` connects `Readv0`/`Readv1` while `toplevel` names those ports `v0Out`/`v1Out`, and `top.v` has syntax errors in its port list. The core elaborates. The Lab 7 data image holds 3,109 words, more than the 1,024-word `DataMemory` in Lab 6; the enlarged memory module used for Lab 7 is not in the repository.

## Authors

Team project by:

- **Roenan Bingle** ([@Roenan-b](https://github.com/Roenan-b))
- **Evan Harris** ([@eharris2](https://github.com/eharris2))
- **Noah Monroe** ([@nmonroe04](https://github.com/nmonroe04))

Course materials in `docs/course-materials/` and the MipsHelper tool in `tools/mipshelper/` were provided by the course and remain the property of their authors.
