`timescale 1ns / 1ps

module toplevel(instructionRead,CLk,instructionWrite);
  input [31:0] instructionRead;
  input Clk;
  output [31:0] instructionWrite;


  assign opCode = instructionRead [31:26]
    assign   rs = instructionRead [25:21]
    assign   rt = instructionRead [20:16]
      assign rd = instructionRead [15:11];
  assign shamt = instructionRead [10:6]; 
  assign funct = instructionRead [5:0];

  
  assign imm = instructionRead [15:0];

  InstructionMemory a1(instructionRead, Instruction);  //NEED TO FIX THIS MODULES INTERNALS
  
  PCAdder a4(instructionRead, PCAddResult); //Takes instruction number and adds 4

  
  controller a2(instructionRead, Clk, ALUSrc, RegDst, OPCode, MemRead, MemWrite, MemtoReg, RegWrite, Branch,Jump); //Check but should be good

  SignExtension a3(imm, signResult);

  RegisterFile a5(rs, rt, WriteRegister, WriteData, RegWrite, Clk, ReadData1, ReadData2); //Should be good

  Mux32Bit2To1 a6(WriteRegister, rt, rd, RegDst);  //$rd vs imm mux, uses regDst as signal

  Mux32Bit2To1 a7(B, ReadData2, signResult, ALUSrc);  //Sign extend imm vs $rt (Read data 2), uses ALUSrc as signal, outputs the B input to ALU
  
  Adder a8(PCAddResult, immSL2, instructionSig); //Adds PC instruction+4 (Output of PCADDER) and Imm*4 (Shift left 2 module) together, sending to PC mux

  Mux32Bit2To1 a9(out, inA, inB, sel) //Chooses between PCaddResult and instructionSig (Output of Adder)

  DataMemory a10(ALUResult, ReadData2, Clk, MemWrite, MemRead, ReadData); //Should be good

  Mux32Bit2To1 a7(WriteData, ReadData, ALUResult, MemtoReg); //Takes ReadData vs ALUresult, controlled by MemtoReg

  ALU32Bit a11(ALUControl, ReadData1, B, ALUResult, Zero);
  
  immSL2 a12(signResult,immSL2); //Multiplies in by 4
  
end module
