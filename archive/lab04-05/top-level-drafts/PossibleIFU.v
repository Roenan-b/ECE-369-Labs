`timescale 1ns / 1ps
module InstructionFetchUnit(
  output [31:0] Instruction,   // fetched instruction
  output [31:0] PCResult,      // current PC
  output [31:0] PCPlus4,       // convenient PC+4 for IF/ID
  input  [31:0] PCNext,        // <— next PC chosen at top (branch/jump/seq)
  input         Reset,
  input         Clk
);
  // PC register loads PCNext each cycle
  ProgramCounter pc_reg(
    .NextPC(PCNext),
    .PC(PCResult),
    .Reset(Reset),
    .Clk(Clk)
  );

  // PC + 4 for sequential path
  PCAdder pc_adder(
    .in(PCResult),
    .out(PCPlus4)
  );

  // Instruction memory addressed by current PC
  InstructionMemory imem(
    .addr(PCResult),
    .dout(Instruction)
  );
endmodule
