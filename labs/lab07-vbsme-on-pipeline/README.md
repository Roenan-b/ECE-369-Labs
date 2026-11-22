# Lab 7: VBSME on the Pipelined Processor

Runs the VBSME kernel on the Lab 6 processor. The core exposes `$v0` and `$v1` (the result row and column) as `v0Out`/`v1Out` so the board can display the answer.

## Overlay on Lab 6

`rtl/` holds only the files that differ from Lab 6. The full design is every file in `../lab06-hazard-detection-forwarding/rtl/` with these replacements:

| File | Change from Lab 6 |
| ---- | ----------------- |
| `rtl/toplevel.v` | Adds `v0Out`/`v1Out` ports and the `id_usesRt` hazard input |
| `rtl/RegisterFile.v` | Adds `Readv0`/`Readv1` outputs for registers `$2` and `$3` |
| `rtl/HazardDetection.v` | Load-use check only compares `rt` when the instruction in ID reads it |
| `rtl/top.v` | Board wrapper that displays `$v0` and `$v1` |
| `rtl/ClkDiv.v` | Board clock divider |

The Makefile assembles this source list automatically.

## Program

| Path | Description |
| ---- | ----------- |
| `asm/vbsme.s` | VBSME kernel with the full set of course test cases |
| `asm/vbsme_tests.s` | Test-case variant of the kernel |
| `asm/vbsme_nops.s` | Kernel with explicit `nop` instructions inserted |
| `mem/instruction_memory.mem` | Final program image (hex, one word per line) |
| `mem/data_memory.mem` | Final data image (frames, windows, and sizes) |
| `scripts/memory_init_to_hex.regex.txt` | Find/replace pattern that turns `memory[i] = 32'hX;` lines into plain hex |

## Build

```sh
make check   # the lab07 core elaborates with the Lab 6 modules
```

Known issues:

- `tb/toplevel_tb.v` connects `Readv0`/`Readv1`, but `toplevel` names the ports `v0Out`/`v1Out`, so `make sim LAB=lab07` fails to elaborate.
- `rtl/top.v` has syntax errors in the `toplevel` instance port list, so `make board LAB=lab07` fails.
- `mem/data_memory.mem` holds 3,109 words, but the Lab 6 `DataMemory` has 1,024. The enlarged data memory used for this lab was not committed.
