# Lab 1: Instruction Fetch Unit

Instruction fetch path for the processor: a program counter, a PC+4 adder, and a word-addressed instruction memory, combined in `InstructionFetchUnit`. `top.v` drives the board's seven-segment display from a divided clock.

| Path | Description |
| ---- | ----------- |
| `rtl/ProgramCounter.v` | 32-bit program counter register with reset |
| `rtl/PCAdder.v` | PC + 4 |
| `rtl/InstructionMemory.v` | Instruction ROM loaded with `$readmemh("instruction_memory.mem")` |
| `rtl/InstructionFetchUnit.v` | Fetch unit combining the three modules above |
| `rtl/ClkDiv.v` | Clock divider for visible stepping on the board |
| `rtl/top.v` | Board wrapper (needs `Two4DigitDisplay`, which is in Lab 5) |
| `tb/*_tb.v` | Testbenches for the program counter, PC adder, and instruction memory |

```sh
make unit LAB=lab01
```

The testbenches are stimulus-only (no self-checking) and are meant for waveform inspection. No `instruction_memory.mem` was committed for this lab.
