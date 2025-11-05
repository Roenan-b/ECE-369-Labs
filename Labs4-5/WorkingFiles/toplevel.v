`timescale 1ns / 1ps

module toplevel(
  input         Clk,
  input         Reset,
  output [31:0] instructionWrite,
  output [31:0] PC_out, 
  output        WB_RegWrite,      // write-enable at WB
  output [4:0]  WB_WriteReg,      // Register index being written
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
    .PCAddResult       (IF_PCPlus4),
    .instructionReadIn (IF_Instruction),
    .PCAddResultOut    (PCAddResultOutofIFID),
    .instructionReadOut(instructionReadOut),
    .Clk               (Clk),
    .Reset             (Reset)
  );

  // =========================
  // Decode
  // =========================
  wire [5:0]  opCode  = instructionReadOut[31:26];
  wire [4:0]  rs      = instructionReadOut[25:21];
  wire [4:0]  rt      = instructionReadOut[20:16];
  wire [4:0]  rd      = instructionReadOut[15:11];
  wire [4:0] shamt    = instructionReadOut[10:6];
  wire [15:0] imm16   = instructionReadOut[15:0];

  wire        ALUSrcIn, RegDstIn, MemReadIn, MemWriteIn, RegWriteIn;
  wire        BranchIn, Jump, UseShamt;
  wire [5:0]  OPCodeIn;            // ALU control from controller
  wire [31:0] signResultIn;
  wire [31:0] ReadData1In, ReadData2In;

  // Controller emits 2-bit WBSource (00 ALU, 01 Mem, 10 PC+4) and 2-bit RegDstSel.
  // We'll map them to your existing 1-bit MemtoReg and 1-bit RegDst path without renaming any original nets.
  wire [1:0]  WBSource_bus;
  wire [1:0]  RegDstSel_bus;

  wire MemtoRegIn;   // 1 -> ALU, 0 -> MEM  (for your 2:1 WB mux)
  assign MemtoRegIn = (WBSource_bus == 2'b00) ? 1'b1 :      // ALU
                      (WBSource_bus == 2'b01) ? 1'b0 :      // MEM
                      1'b1;                                  // PC+4 not supported in 2:1; choose ALU

  // Reduce 2-bit RegDstSel (00 rt, 01 rd, 10 $31) to your existing 1-bit RegDstIn (0 rt, 1 rd)
  // (JAL's $31 is not handled in this 2:1 path; fine for now)
  wire RegDst1bit = (RegDstSel_bus == 2'b01); // 0=rt, 1=rd

  controller a2(
    .instruction(instructionReadOut),
    .Clk(Clk),
    .ALUSrc(ALUSrcIn),
    .RegDstSel(RegDstSel_bus),     // keep controller's name
    .ALUControl(OPCodeIn),
    .MemRead(MemReadIn),
    .MemWrite(MemWriteIn),
    .WBSource(WBSource_bus),       // 2-bit bus
    .RegWrite(RegWriteIn),
    .Branch(BranchIn),
    .Jump(Jump),
    .UseShamt(UseShamt)
    // (JumpReg/UseShamt/ExtZero omitted here if unused in this top)
  );

  SignExtension a3(.in(imm16), .out(signResultIn));

  // Writeback wires (defined later)
  wire [31:0] WriteData;
  wire [4:0]  WriteRegister;

  RegisterFile a5(
    .ReadRegister1(rs),
    .ReadRegister2(rt),
    .WriteRegister(WriteReg_MEMWB),       // will be the MEM/WB version (see below)
    .WriteData(WriteData),
    .RegWrite(RegWriteOutofMEMWB),
    .Clk(Clk),
    .ReadData1(ReadData1In),
    .ReadData2(ReadData2In)
  );

  // =========================
  // ID/EX pipeline register
  // =========================
  wire        ALUSrcOutofIDEX, RegDstOutofIDEX, BranchOutofIDEX;
  wire        MemWriteOutofIDEX, MemReadOutofIDEX, MemToRegOutofIDEX, RegWriteOutofIDEX;
  wire [5:0]  ALUopOutofIDEX;                 // *** was [3:0], must be [5:0]
  wire        UseShamtOutofIDEX;
  wire [31:0] ReadData1OutofIDEX, ReadData2OutofIDEX;
  wire [31:0] PCAddResultOutofIDEX, signResultOutofIDEX;
  wire [4:0]  RTRegdestOutofIDEX, RDRegdestOutofIDEX;

  RegisterID_EX a14(
    .Clk(Clk),
    .Reset(Reset),
    // control in/out
    .ALUSrcIn    (ALUSrcIn),
    .ALUopIn     (OPCodeIn),        // 6-bit path
    .RegDstIn    (RegDst1bit),      // mapped from 2-bit RegDstSel_bus
    .ALUSrcOut   (ALUSrcOutofIDEX),
    .ALUopOut    (ALUopOutofIDEX),  // 6-bit
    .RegDstOut   (RegDstOutofIDEX),
    .BranchIn    (BranchIn),
    .MemWriteIn  (MemWriteIn),
    .MemReadIn   (MemReadIn),
    .BranchOut   (BranchOutofIDEX),
    .MemWriteOut (MemWriteOutofIDEX),
    .MemReadOut  (MemReadOutofIDEX),
    .MemtoRegIn  (MemtoRegIn),
    .RegWriteIn  (RegWriteIn),
    .MemtoRegOut (MemToRegOutofIDEX),
    .RegWriteOut (RegWriteOutofIDEX),
    // data in/out
    .ReadData1In (ReadData1In),
    .ReadData2In (ReadData2In),
    .PCAddResultIn(PCAddResultOutofIFID),
    .signResultIn(signResultIn),
    .RTRegdestIn (rt),
    .RDRegdestIn (rd),
    .ReadData1Out(ReadData1OutofIDEX),
    .ReadData2Out(ReadData2OutofIDEX),
    .PCAddResultOut(PCAddResultOutofIDEX),
    .signResultOut(signResultOutofIDEX),
    .RTRegdestOut(RTRegdestOutofIDEX),
    .RDRegdestOut(RDRegdestOutofIDEX),
    .UseShamtIn(UseShamt),
    .UseShamtOut(UseShamt)
  );

  // =========================
  // Execute
  // =========================
  wire [31:0] BottomALUInput;
  wire [31:0] immSL2_out;
  wire [31:0] ALUResult;
  wire        ZeroIn;

  // 5-bit write-register selection in EX (rt vs rd), then PIPELINE it
  wire [4:0] WriteReg_EX = RegDstOutofIDEX ? RDRegdestOutofIDEX : RTRegdestOutofIDEX;

  // B-input mux to ALU: sel=1 -> immediate (signResultOutofIDEX), sel=0 -> ReadData2
  Mux32Bit2To1 mux_alu_b(
    .out (BottomALUInput),
    .inA (ReadData2OutofIDEX),
    .inB (signResultOutofIDEX),
    .sel (ALUSrcOutofIDEX)
  );

  wire [31:0] ALU_A_input;
  assign ALU_A_input = UseShamtOutofIDEX ? {27'b0, shamt} : ReadData1OutofIDEX;
  immSL2 a12(.in(signResultOutofIDEX), .out(immSL2_out));

  // Branch target = PC+4 (ID/EX) + (imm << 2)
  wire [31:0] BranchTargetIn_EX;
  Adder a8(.PCAddResult(PCAddResultOutofIDEX), .immSL2(immSL2_out), .InstructionSig(BranchTargetIn_EX));

  ALU32Bit a11(
    .ALUControl(ALUopOutofIDEX),     // 6-bit path intact
    .A(ALU_A_input),
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
  wire [31:0] MuxOutofEXMEM;           // kept for compatibility (unused for WriteReg now)
  wire        ZeroOut;
  wire        MemWriteOutofEXMEM, MemReadOutofEXMEM;
  wire        BranchOutofEXMEM, MemtoRegOutofEXMEM, RegWriteOutofEXMEM;

  // *** Add a proper 5-bit write-reg pipe through EX/MEM
  wire [4:0] WriteReg_EXMEM;

  EX_MEM a15(
    // branch target
    .AddResultIn (BranchTargetIn_EX),
    .AddResultOut(PCAddResultOutofEXMEM),

    .ALUResultIn(ALUResult), .ALUResultOut(ALUResultOutofEXMEM),

    // keep original MuxIn/MuxOut wiring as-is (name preserved), but use a new 5-bit pipe for WriteReg
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
    .Reset(Reset),

    // *** New 5-bit register index pipe (add these two ports in EX_MEM module)
    .WriteRegIn (WriteReg_EX),
    .WriteRegOut(WriteReg_EXMEM)
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

  // *** Add a 5-bit write-reg pipe through MEM/WB as well
  wire [4:0] WriteReg_MEMWB;
  
  wire MemtoRegOutofMEMWB;
  wire RegWriteOutofMEMWB;

  MEM_WB a16(
    .ReadDataIn (ReadData),              .ReadDataOut (ReadDataOutofMEMWB),
    .ALUResultIn(ALUResultOutofEXMEM),   .ALUResultOut(ALUResultOutofMEMWB),
    .MemtoRegIn (MemtoRegOutofEXMEM),    .MemtoRegOut (MemtoRegOutofMEMWB),
    .RegWriteIn (RegWriteOutofEXMEM),    .RegWriteOut (RegWriteOutofMEMWB),
    .Clk(Clk),
    .Reset(Reset),

    // *** New 5-bit write-reg pipe (add these two ports in MEM_WB module)
    .WriteRegIn (WriteReg_EXMEM),
    .WriteRegOut(WriteReg_MEMWB)
  );

  // Writeback (2:1 mux; sel=1 -> ALU, sel=0 -> MEM)
  Mux32Bit2To1 a17(
    .out(WriteData),
    .inA(ReadDataOutofMEMWB),
    .inB(ALUResultOutofMEMWB),
    .sel(MemtoRegOutofMEMWB)
  );

  // *** Use the WB-stage register index to write the file (timing-correct)
  wire [4:0] WriteRegister_wb_sel = WriteReg_MEMWB;
  assign WriteRegister = WriteRegister_wb_sel;

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
  

  // Final external outputs (as in your original)
  assign instructionWrite = IF_Instruction;   // show current fetched instruction
  assign WB_RegWrite      = RegWriteOutofMEMWB;
  assign WB_WriteReg      = WriteRegister_wb_sel;
  assign WB_WriteData     = WriteData;
    
  // Add this debug code to your toplevel
always @(posedge Clk) begin
    // Capture specific instructions in ID stage
    if (instructionReadOut == 32'h012B6022) begin // SUB $t4, $t1, $t3
        $display("=== SUB DETECTED in ID ===");
        $display("ID: rs=$t1(%0d) rt=$t3(%0d) rd=$t4(%0d)", 
                 instructionReadOut[25:21], instructionReadOut[20:16], instructionReadOut[15:11]);
        $display("ID: ALUControl=%0d ALUSrc=%b UseShamt=%b", 
                 OPCodeIn, ALUSrcIn, UseShamt);
    end
    if (instructionReadOut == 32'h000B60C0) begin // SLL $t4, $t3, 3  
        $display("=== SLL DETECTED in ID ===");
        $display("ID: rt=$t3(%0d) rd=$t4(%0d) shamt=3", 
                 instructionReadOut[20:16], instructionReadOut[15:11]);
        $display("ID: ALUControl=%0d ALUSrc=%b UseShamt=%b", 
                 OPCodeIn, ALUSrcIn, UseShamt);
    end
    if (instructionReadOut == 32'h000C6882) begin // SRL $t5, $t4, 2
        $display("=== SRL DETECTED in ID ===");
        $display("ID: rt=$t4(%0d) rd=$t5(%0d) shamt=2", 
                 instructionReadOut[20:16], instructionReadOut[15:11]);
        $display("ID: ALUControl=%0d ALUSrc=%b UseShamt=%b", 
                 OPCodeIn, ALUSrcIn, UseShamt);
    end
    
    // Debug EX stage for these ALU operations
    if (ALUopOutofIDEX == 5 || ALUopOutofIDEX == 8 || ALUopOutofIDEX == 9) begin
        $display("EX: ALUop=%0d A=%h B=%h Result=%h", 
                 ALUopOutofIDEX, ALU_A_input, BottomALUInput, ALUResult);
        $display("EX: UseShamt=%b ReadData1=%h ReadData2=%h", 
                 UseShamtOutofIDEX, ReadData1OutofIDEX, ReadData2OutofIDEX);
    end
end
endmodule
