`timescale 1ns / 1ps

module toplevel(
  input        Clk,
  input        Reset,
  output [31:0] instructionWrite,
  output [31:0] PC_out
);

  // ------------------------------------------------------------
  // IF stage (via IFU) + PC control at top (Option A)
  // ------------------------------------------------------------
  wire [31:0] IF_PC;              // current PC from IFU
  wire [31:0] IF_Instruction;     // fetched instruction from IMEM
  wire [31:0] PCPlus4;            // PC+4
  wire [31:0] PCNext;             // next PC selected at top

  // IFU (expects PCNext)
  InstructionFetchUnit IFU (
    .Instruction(IF_Instruction),
    .PCResult  (IF_PC),
    .PCNext    (PCNext),
    .Reset     (Reset),
    .Clk       (Clk)
  );

  // For waveform visibility
  assign PC_out = IF_PC;

  // Compute PC+4 at top so we can mux it vs branch target
  PCAdder pc_plus4(
    .in (IF_PC),
    .out(PCPlus4)
  );

  // ------------------------------------------------------------
  // IF/ID pipeline register
  // ------------------------------------------------------------
  wire [31:0] instructionReadOut;      // to Decode
  wire [31:0] PCAddResultOutofIFID;    // PC+4 latched to Decode

  RegisterIF_ID IF_ID_reg(
    .PCAddResultIn (PCPlus4),
    .InstructionIn (IF_Instruction),
    .PCAddResultOut(PCAddResultOutofIFID),
    .InstructionOut(instructionReadOut),
    .Clk           (Clk)
  );

  // ------------------------------------------------------------
  // Decode signals
  // ------------------------------------------------------------
  wire [5:0]  opCode  = instructionReadOut[31:26];
  wire [4:0]  rs      = instructionReadOut[25:21];
  wire [4:0]  rt      = instructionReadOut[20:16];
  wire [4:0]  rd      = instructionReadOut[15:11];
  wire [4:0]  shamt   = instructionReadOut[10:6];
  wire [5:0]  funct   = instructionReadOut[5:0];
  wire [15:0] imm16   = instructionReadOut[15:0];

  // Controller signals
  wire ALUSrcIn, RegDstIn, MemReadIn, MemWriteIn, MemtoRegIn, RegWriteIn;
  wire BranchIn, Jump;
  wire [5:0] OPCodeIn;

  // Sign extension
  wire [31:0] signResultIn;

  // RegisterFile connections
  wire [31:0] ReadData1In, ReadData2In;

  controller a2(
    .instruction(instructionReadOut),
    .Clk(Clk),
    .ALUSrc(ALUSrcIn),
    .RegDst(RegDstIn),
    .OPCode(OPCodeIn),
    .MemRead(MemReadIn),
    .MemWrite(MemWriteIn),
    .MemtoReg(MemtoRegIn),
    .RegWrite(RegWriteIn),
    .Branch(BranchIn),
    .Jump(Jump)
  );

  SignExtension a3(
    .in (imm16),
    .out(signResultIn)
  );

  // Writeback connections declared later
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

  // ------------------------------------------------------------
  // ID/EX pipeline register
  // ------------------------------------------------------------
  wire ALUSrcOutofIDEX, RegDstOutofIDEX, BranchOutofIDEX;
  wire MemWriteOutofIDEX, MemReadOutofIDEX, MemToRegOutofIDEX, RegWriteOutofIDEX;
  wire [3:0] ALUopOutofIDEX; // assuming your controller drives this via OPCode
  wire [31:0] ReadData1OutofIDEX, ReadData2OutofIDEX;
  wire [31:0] PCAddResultOutofIDEX, signResultOutofIDEX;
  wire [4:0]  RTRegdestOutofIDEX, RDRegdestOutofIDEX;

  RegisterID_EX a14(
    .Clk(Clk),
    // control in
    .ALUSrcIn(ALUSrcIn),
    .OPCodeIn(OPCodeIn),
    .RegDstIn(RegDstIn),
    .ALUSrcOut(ALUSrcOutofIDEX),
    .ALUopOut(ALUopOutofIDEX),
    .RegDstOut(RegDstOutofIDEX),

    .BranchIn(BranchIn), .MemWriteIn(MemWriteIn), .MemReadIn(MemReadIn),
    .BranchOut(BranchOutofIDEX), .MemWriteOut(MemWriteOutofIDEX), .MemReadOut(MemReadOutofIDEX),

    .MemToRegIn(MemtoRegIn), .RegWriteIn(RegWriteIn),
    .MemToRegOut(MemToRegOutofIDEX), .RegWriteOut(RegWriteOutofIDEX),

    // data in
    .ReadData1In(ReadData1In),
    .ReadData2In(ReadData2In),
    .PCAddResultIn(PCAddResultOutofIFID),
    .SignExtIn(signResultIn),
    .RTIn(rt), .RDIn(rd),

    // data out
    .ReadData1Out(ReadData1OutofIDEX),
    .ReadData2Out(ReadData2OutofIDEX),
    .PCAddResultOut(PCAddResultOutofIDEX),
    .SignExtOut(signResultOutofIDEX),
    .RTOut(RTRegdestOutofIDEX),
    .RDOut(RDRegdestOutofIDEX)
  );

  // ------------------------------------------------------------
  // Execute stage
  // ------------------------------------------------------------
  wire [31:0] BottomALUInput;
  wire [31:0] immSL2_out;
  wire [31:0] ALUResult;
  wire ZeroIn;

  // $rd vs $rt select for write register
  Mux32Bit2To1 mux_rd_rt(
    .out(WriteRegister),
    .in0({27'b0, RTRegdestOutofIDEX}), // NOTE: if your Mux32Bit2To1 expects 32-bit, widen
    .in1({27'b0, RDRegdestOutofIDEX}),
    .sel(RegDstOutofIDEX)
  );

  // Choose ALU B input: register vs sign-extended immediate
  Mux32Bit2To1 mux_alu_b(
    .out(BottomALUInput),
    .in0(ReadData2OutofIDEX),
    .in1(signResultOutofIDEX),
    .sel(ALUSrcOutofIDEX)
  );

  // Shift-left-2 immediate
  immSL2 a12(
    .in (signResultOutofIDEX),
    .out(immSL2_out)
  );

  // Branch target = PC+4 (ID/EX) + (imm << 2); you named this adder a8
  wire [31:0] BranchTargetIn_EX;
  Adder a8(
    .A(PCAddResultOutofIDEX),
    .B(immSL2_out),
    .Y(BranchTargetIn_EX)        // this is your "PCAddResultIn" previously
  );

  // ALU
  ALU32Bit a11(
    .ALUop(ALUopOutofIDEX),
    .A(ReadData1OutofIDEX),
    .B(BottomALUInput),
    .Result(ALUResult),
    .Zero(ZeroIn)
  );

  // ------------------------------------------------------------
  // EX/MEM pipeline register
  // ------------------------------------------------------------
  wire [31:0] PCAddResultOutofEXMEM;
  wire [31:0] ALUResultOutofEXMEM;
  wire [31:0] MuxIn, MuxOutofEXMEM;
  wire [31:0] ReadData2OutofEXMEM;
  wire ZeroOut;
  wire MemWriteOutofEXMEM, MemReadOutofEXMEM;
  wire BranchOutofEXMEM, MemtoRegOutofEXMEM, RegWriteOutofEXMEM;

  EX_MEM a15(
    // branch target in/out
    .PCAddResultIn (BranchTargetIn_EX),
    .PCAddResultOut(PCAddResultOutofEXMEM),

    // ALU result
    .ALUResultIn(ALUResult),
    .ALUResultOut(ALUResultOutofEXMEM),

    // (you previously latched a RegDst path into MuxOutofEXMEM)
    .MuxIn(RegDstOutofIDEX ? {27'b0, RDRegdestOutofIDEX} : {27'b0, RTRegdestOutofIDEX}),
    .MuxOut(MuxOutofEXMEM),

    // data to memory
    .ReadData2In(ReadData2OutofIDEX),
    .ReadData2Out(ReadData2OutofEXMEM),

    // Zero flag
    .ZeroIn(ZeroIn),
    .ZeroOut(ZeroOut),

    // control
    .MemWriteIn(MemWriteOutofIDEX), .MemWriteOut(MemWriteOutofEXMEM),
    .MemReadIn (MemReadOutofIDEX),  .MemReadOut (MemReadOutofEXMEM),
    .BranchIn  (BranchOutofIDEX),   .BranchOut  (BranchOutofEXMEM),
    .MemtoRegIn(MemToRegOutofIDEX), .MemtoRegOut(MemtoRegOutofEXMEM),
    .RegWriteIn(RegWriteOutofIDEX), .RegWriteOut(RegWriteOutofEXMEM),

    .Clk(Clk)
  );

  // ------------------------------------------------------------
  // Data Memory
  // ------------------------------------------------------------
  wire [31:0] ReadData;

  DataMemory a10(
    .Address(ALUResultOutofEXMEM),
    .WriteData(ReadData2OutofEXMEM),
    .Clk(Clk),
    .MemWrite(MemWriteOutofEXMEM),
    .MemRead(MemReadOutofEXMEM),
    .ReadData(ReadData)
  );

  // Branch decision
  wire PCSrc;
  and a18(PCSrc, BranchOutofEXMEM, ZeroOut);

  // ------------------------------------------------------------
  // MEM/WB pipeline register
  // ------------------------------------------------------------
  wire [31:0] ReadDataOutofMEMWB, ALUResultOutofMEMWB;
  wire MemtoRegOutofMEMWB, RegWriteOutofMEMWB;

  MEM_WB a16(
    .ReadDataIn(ReadData), .ReadDataOut(ReadDataOutofMEMWB),
    .ALUResultIn(ALUResultOutofEXMEM), .ALUResultOut(ALUResultOutofMEMWB),
    .MemtoRegIn(MemtoRegOutofEXMEM), .MemtoRegOut(MemtoRegOutofMEMWB),
    .RegWriteIn(RegWriteOutofEXMEM), .RegWriteOut(RegWriteOutofMEMWB),
    .Clk(Clk)
  );

  // Writeback data select
  Mux32Bit2To1 a17(
    .out(WriteData),
    .in0(ReadDataOutofMEMWB),
    .in1(ALUResultOutofMEMWB),
    .sel(MemtoRegOutofMEMWB)
  );

  // ------------------------------------------------------------
  // Next PC selection (Option A): PCNext = PC+4 vs BranchTarget
  // Branch target comes from EX/MEM (PCAddResultOutofEXMEM)
  // ------------------------------------------------------------
  Mux32Bit2To1 nextpc_mux(
    .out(PCNext),
    .in0(PCPlus4),
    .in1(PCAddResultOutofEXMEM),   // Branch target from EX/MEM
    .sel(PCSrc)
  );

  // Final requested external output (your original code)
  assign instructionWrite = WriteData;

endmodule

