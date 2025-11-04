`timescale 1ns / 1ps

module toplevel(
  input        Clk,
  input        Reset,
  output [31:0] instructionWrite,
  output [31:0] PC_out, 
  output WB_RegWrite, //write-enable at WB
  output [4:0] WB_WriteReg,  //Register index being written
  output [31:0] WB_WriteData
);

  // =========================
  // IF stage via IFU (Option A)
  // =========================
  wire [31:0] IF_PC;                 // current PC
  wire [31:0] IF_Instruction;        // fetched instruction
  wire [31:0] IF_PCPlus4;            // PC+4 from IFU
  wire [31:0] PCNext;                // chosen at top

  InstructionFetchUnit IFU (
    .Instruction(IF_Instruction),
    .PCResult  (IF_PC),
    .PCPlus4   (IF_PCPlus4),
    .PCNext    (PCNext),
    .Reset     (Reset),
    .Clk       (Clk)
  );

  assign PC_out = IF_PC;

  // =========================
  // IF/ID pipeline register
  // =========================
  wire [31:0] instructionReadOut;    // instruction to Decode
  wire [31:0] PCAddResultOutofIFID;  // PC+4 to Decode

  RegisterIF_ID IF_ID_reg(
    .PCAddResult (IF_PCPlus4),
    .instructionReadIn (IF_Instruction),
    .PCAddResultOut(PCAddResultOutofIFID),
    .instructionReadOut(instructionReadOut),
    .Clk(Clk),
    .Reset(Reset)
  );

  // =========================
  // Decode
  // =========================
  wire [5:0]  opCode  = instructionReadOut[31:26];
  wire [4:0]  rs      = instructionReadOut[25:21];
  wire [4:0]  rt      = instructionReadOut[20:16];
  wire [4:0]  rd      = instructionReadOut[15:11];
  wire [15:0] imm16   = instructionReadOut[15:0];

  wire ALUSrcIn, RegDstIn, MemReadIn, MemWriteIn, MemtoRegIn, RegWriteIn;
  wire BranchIn, Jump;
  wire [5:0] OPCodeIn;
  wire [31:0] signResultIn;
  wire [31:0] ReadData1In, ReadData2In;

  controller a2(
    .instruction(instructionReadOut),
    .Clk(Clk),
    .ALUSrc(ALUSrcIn),
    .RegDstSel(RegDstIn),
    .ALUControl(OPCodeIn),
    .MemRead(MemReadIn),
    .MemWrite(MemWriteIn),
    .WBSource(MemtoRegIn),
    .RegWrite(RegWriteIn),
    .Branch(BranchIn),
    .Jump(Jump)
  );

  SignExtension a3(.in(imm16), .out(signResultIn));

  // Writeback wires (defined later)
  wire [31:0] WriteData;
  wire [4:0]  WriteRegister;

  RegisterFile a5(
    .ReadRegister1(rs),
    .ReadRegister2(rt),
    .WriteRegister(WriteRegister),
    .WriteData(WriteData),
    .RegWrite(RegWriteOutofMEMWB),
    .Clk(Clk),
    .ReadData1(ReadData1In),
    .ReadData2(ReadData2In)
  );

  // =========================
  // ID/EX pipeline register
  // =========================
  wire ALUSrcOutofIDEX, RegDstOutofIDEX, BranchOutofIDEX;
  wire MemWriteOutofIDEX, MemReadOutofIDEX, MemToRegOutofIDEX, RegWriteOutofIDEX;
  wire [5:0] ALUopOutofIDEX;
  wire [31:0] ReadData1OutofIDEX, ReadData2OutofIDEX;
  wire [31:0] PCAddResultOutofIDEX, signResultOutofIDEX;
  wire [4:0]  RTRegdestOutofIDEX, RDRegdestOutofIDEX;

  RegisterID_EX a14(
    .Clk(Clk),
    .Reset(Reset),
    // control in/out
    .ALUSrcIn(ALUSrcIn), .ALUopIn(OPCodeIn), .RegDstIn(RegDstIn),
    .ALUSrcOut(ALUSrcOutofIDEX), .ALUopOut(ALUopOutofIDEX), .RegDstOut(RegDstOutofIDEX),
    .BranchIn(BranchIn), .MemWriteIn(MemWriteIn), .MemReadIn(MemReadIn),
    .BranchOut(BranchOutofIDEX), .MemWriteOut(MemWriteOutofIDEX), .MemReadOut(MemReadOutofIDEX),
    .MemToRegIn(MemtoRegIn), .RegWriteIn(RegWriteIn),
    .MemToRegOut(MemToRegOutofIDEX), .RegWriteOut(RegWriteOutofIDEX),
    // data in/out
    .ReadData1In(ReadData1In), .ReadData2In(ReadData2In),
    .PCAddResultIn(PCAddResultOutofIFID),
    .signResultIn(signResultIn),
    .RTRegdestIn(rt), .RDRegdestIn(rd),
    .ReadData1Out(ReadData1OutofIDEX), .ReadData2Out(ReadData2OutofIDEX),
    .PCAddResultOut(PCAddResultOutofIDEX),
    .signResultOut(signResultOutofIDEX),
    .RTRegdestOut(RTRegdestOutofIDEX), .RDRegdestOut(RDRegdestOutofIDEX)
  );

  // =========================
  // Execute
  // =========================
  wire [31:0] BottomALUInput;
  wire [31:0] immSL2_out;
  wire [31:0] ALUResult;
  wire ZeroIn;

  // Write-register select - use your 5-bit param mux if you have it
  // MuxN2To1 #(5) mux_wr_idx(WriteRegister, RTRegdestOutofIDEX, RDRegdestOutofIDEX, RegDstOutofIDEX);
  // If only 32-bit mux exists, widen:
  Mux32Bit2To1 mux_wr_idx32(
    .out(WriteRegister),
    .inA({27'b0, RTRegdestOutofIDEX}),
    .inB({27'b0, RDRegdestOutofIDEX}),
    .sel(RegDstOutofIDEX)
  );

  Mux32Bit2To1 mux_alu_b(
    .out(BottomALUInput),
    .inA(ReadData2OutofIDEX),
    .inB(signResultOutofIDEX),
    .sel(ALUSrcOutofIDEX)
  );

  immSL2 a12(.in(signResultOutofIDEX), .out(immSL2_out));

  // Branch target = PC+4 (ID/EX) + (imm << 2)
  wire [31:0] BranchTargetIn_EX;
  Adder a8(.PCAddResult(PCAddResultOutofIDEX), .immSL2(immSL2_out), .InstructionSig(BranchTargetIn_EX));

  ALU32Bit a11(
    .ALUControl(ALUopOutofIDEX),
    .A(ReadData1OutofIDEX),
    .B(BottomALUInput),
    .ALUResult(ALUResult),
    .Zero(ZeroIn)
  );

  // =========================
  // EX/MEM
  // =========================
  wire [31:0] PCAddResultOutofEXMEM;
  wire [31:0] ALUResultOutofEXMEM;
  wire [31:0] ReadData2OutofEXMEM;
  wire [31:0] MuxOutofEXMEM;
  wire ZeroOut;
  wire MemWriteOutofEXMEM, MemReadOutofEXMEM;
  wire BranchOutofEXMEM, MemtoRegOutofEXMEM, RegWriteOutofEXMEM;

  EX_MEM a15(
    // branch target
    .AddResultIn (BranchTargetIn_EX),
    .AddResultOut(PCAddResultOutofEXMEM),

    .ALUResultIn(ALUResult), .ALUResultOut(ALUResultOutofEXMEM),

    // the 5-bit reg idx latched via your path; keep your original if different
    .MuxIn(RegDstOutofIDEX ? {27'b0, RDRegdestOutofIDEX} : {27'b0, RTRegdestOutofIDEX}),
    .MuxOut(MuxOutofEXMEM),

    .ReadData2In(ReadData2OutofIDEX), .ReadData2Out(ReadData2OutofEXMEM),

    .ZeroIn(ZeroIn), .ZeroOut(ZeroOut),

    .MemWriteIn(MemWriteOutofIDEX), .MemWriteOut(MemWriteOutofEXMEM),
    .MemReadIn (MemReadOutofIDEX),  .MemReadOut (MemReadOutofEXMEM),
    .BranchIn  (BranchOutofIDEX),   .BranchOut  (BranchOutofEXMEM),
    .MemtoRegIn(MemToRegOutofIDEX), .MemtoRegOut(MemtoRegOutofEXMEM),
    .RegWriteIn(RegWriteOutofIDEX), .RegWriteOut(RegWriteOutofEXMEM),

    .Clk(Clk),
    .Reset(Reset)
  );

  // =========================
  // Data Memory
  // =========================
  wire [31:0] ReadData;

  DataMemory a10(
    .Address  (ALUResultOutofEXMEM),
    .WriteData(ReadData2OutofEXMEM),
    .Clk(Clk),
    .MemWrite (MemWriteOutofEXMEM),
    .MemRead  (MemReadOutofEXMEM),
    .ReadData (ReadData)
  );

  // Branch decision (EX/MEM stage)
  wire PCSrc;
  and a18(PCSrc, BranchOutofEXMEM, ZeroOut);

  // =========================
  // MEM/WB
  // =========================
  wire [31:0] ReadDataOutofMEMWB, ALUResultOutofMEMWB;
  wire MemtoRegOutofMEMWB, RegWriteOutofMEMWB;

  MEM_WB a16(
    .ReadDataIn(ReadData), .ReadDataOut(ReadDataOutofMEMWB),
    .ALUResultIn(ALUResultOutofEXMEM), .ALUResultOut(ALUResultOutofMEMWB),
    .MemtoRegIn(MemtoRegOutofEXMEM), .MemtoRegOut(MemtoRegOutofMEMWB),
    .RegWriteIn(RegWriteOutofEXMEM), .RegWriteOut(RegWriteOutofMEMWB),
    .Clk(Clk),
    .Reset(Reset)
  );

  // Writeback
  Mux32Bit2To1 a17(
    .out(WriteData),
    .inA(ReadDataOutofMEMWB),
    .inB(ALUResultOutofMEMWB),
    .sel(MemtoRegOutofMEMWB)
  );

  // =========================
  // Next PC selection (Option A)
  // =========================
  // Branch target from EX/MEM; select vs PC+4 from IFU
  Mux32Bit2To1 nextpc_mux(
    .out(PCNext),
    .inA(IF_PCPlus4),            // sequential
    .inB(PCAddResultOutofEXMEM), // branch target
    .sel(PCSrc)
  );

  // Final external output (as in your original)
  assign instructionWrite = IF_Instruction;
  assign WB_RegWrite = RegWriteOutofMEMWB;
  assign WB_WriteReg = WriteRegister;
  assign WB_WriteData = WriteData;

endmodule
