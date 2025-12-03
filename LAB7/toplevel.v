
//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%

`timescale 1ns / 1ps

module toplevel(
  input         Clk,
  input         Reset,
  //output [31:0] instructionWrite,
  output [31:0] PC_out, 
  //output        WB_RegWrite,      // write-enable at WB
  //output [4:0]  WB_WriteReg,      // Register index being written
  output [31:0] WB_WriteData
  output [31:0] v0;
  output [31:0] v1;
  //output [6:0] out7,
  //output [7:0] en_out
);


//wire ClkOut;

//ClkDiv a20(Clk, Reset, ClkOut);   
//Two4DigitDisplay a19(Clk, PC_out, WB_WriteData, out7, en_out);
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
  wire        BranchIn, Jump, JumpReg, UseShamt;
  wire [5:0]  OPCodeIn;            // ALU control from controller
  wire [31:0] ReadData1In, ReadData2In;

  // Controller emits 2-bit WBSource (00 ALU, 01 Mem, 10 PC+4) and 2-bit RegDstSel.
  // We'll map them to your existing 1-bit MemtoReg and 1-bit RegDst path without renaming any original nets.
  wire [1:0]  WBSource_bus;
  wire [1:0]  RegDstSel_bus;
  wire [1:0] MemSize;       // 00=byte, 01=half, 10=word
  wire       MemUnsigned;   // loads: 1 = zero-extend, 0 = sign-extend

  //wire MemtoRegIn;   // 1 -> ALU, 0 -> MEM  (for your 2:1 WB mux)
  //assign MemtoRegIn = (WBSource_bus == 2'b00) ? 1'b1 :      // ALU
   //                   (WBSource_bus == 2'b01) ? 1'b0 :      // MEM
   //                   1'b1;                                  // PC+4 not supported in 2:1; choose ALU

  // Reduce 2-bit RegDstSel (00 rt, 01 rd, 10 $31) to your existing 1-bit RegDstIn (0 rt, 1 rd)
  // (JAL's $31 is not handled in this 2:1 path; fine for now)
  wire RegDst1bit = (RegDstSel_bus == 2'b01); // 0=rt, 1=rd
  wire ExtZero;
  

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
    .UseShamt(UseShamt),
    .JumpReg(JumpReg),
    .MemSize(MemSize),           
    .MemUnsigned(MemUnsigned),   
    .ExtZero(ExtZero) 
  );

  wire        ALUSrcIn2, RegDstSel_bus2, MemReadIn2, MemWriteIn2, RegWriteIn2, MemSize2, MemUnsigned2;
  wire        BranchIn2, Jump2, JumpReg2, UseShamt2, OPCodeIn2, WBSource_bus2, ExtZero2;

  
  ControllerMux c3(
    .sel(),
    .inALUSRC(ALUSrcIn),
    .inRegDstSel(RegDstSel_bus),
    .inALUControl(OPCodeIn),
    .inMemRead(MemReadIn),
    .inWBSource(WBSource_bus),
    .inRegWrite(RegWriteIn),
    .inBranch(BranchIn),
    .inJump(Jump),
    .inJumpReg(JumpReg),
    .inExtZero(ExtZero),
    .inUseShamt(UserShamt),
    .inMemSize(MemSize),
    .inMemUnisgned(MemUnsigned),

    .outALUSrc(ALUSrcIn2)
    .outRegDstSel(RegDstSel_bus2),
    .outALUControl(OPCodeIn2),
    .outMemRead(MemReadIn2),
    .outMemWrite(MemWriteIn2),
    .outWBSource(WBSource_bus2),
    .outRegWrite(RegWriteIn2),
    .outBranch(BranchIn2),
    .outJump(Jump2),
    .outJumpReg(JumpReg2),
    .outExtZero(ExtZero2),
    .outUseShamt(UseShamt2),
    .outMemSize(MemSize2),
    .outMemUnsigned(MemUnsigned2)
  ).
  
  wire [31:0] signExtImm, zeroExtImm, immFinal;
  SignExtension a3(.in(imm16), .out(signExtImm));
  assign zeroExtImm = {16'b0, imm16};
  assign immFinal = ExtZero2 ? zeroExtImm : signExtImm;

  // Writeback wires (defined later)
  wire [31:0] WriteData;
  wire [4:0]  WriteRegister;

  wire [31:0] v0;
  wire [31:0] v1;
  RegisterFile a5(
    .ReadRegister1(rs),
    .ReadRegister2(rt),
    .WriteRegister(WriteReg_MEMWB),       // will be the MEM/WB version (see below)
    .WriteData(WriteData),
    .RegWrite(RegWriteOutofMEMWB),
    .Clk(Clk),
    .ReadData1(ReadData1In),
    .ReadData2(ReadData2In),
    .Readv0(v0),
    .Readv1(v1)
  );

  wire EqualSignal;
  EqualGate a20(
    .inputA(ReadData1In),
    .inputB(ReadData2In),
    .outSignal(EqualSignal)
  );

  // =========================
  // ID/EX pipeline register
  // =========================
  wire        ALUSrcOutofIDEX, RegDstOutofIDEX, BranchOutofIDEX;
  wire        MemWriteOutofIDEX, MemReadOutofIDEX;
  wire        MemToRegOutofIDEX;
  wire        RegWriteOutofIDEX;
  wire [5:0]  ALUopOutofIDEX;                 // *** was [3:0], must be [5:0]
  wire        UseShamtOutofIDEX;
  wire [31:0] ReadData1OutofIDEX, ReadData2OutofIDEX;
  wire [31:0] PCAddResultOutofIDEX, signResultOutofIDEX;
  wire [4:0]  RTRegdestOutofIDEX, RDRegdestOutofIDEX;
  wire [4:0] shamtOutofIDEX;
  wire [1:0] WBSourceOutofIDEX;
  wire [1:0] WBSourceOutofEXMEM;
  wire [1:0] WBSourceOutofMEMWB;
  wire [1:0] MemSizeOutofIDEX;
  wire       MemUnsignedOutofIDEX;
  wire [1:0] MemSizeOutofEXMEM;
  wire       MemUnsignedOutofEXMEM;
  wire [1:0] RegDstSelOutofIDEX;
  wire [4:0] RSOutofIDEX;


  RegisterID_EX a14(
    .Clk(Clk),
    .Reset(Reset),
    // control in/out
    .ALUSrcIn    (ALUSrcIn2),
    .ALUopIn     (OPCodeIn2),        // 6-bit path
    .RegDstIn    (RegDst1bit),      // mapped from 2-bit RegDstSel_bus
    .ALUSrcOut   (ALUSrcOutofIDEX),
    .ALUopOut    (ALUopOutofIDEX),  // 6-bit
    .RegDstOut   (RegDstOutofIDEX),
    .BranchIn    (BranchIn2),
    .MemWriteIn  (MemWriteIn2),
    .MemReadIn   (MemReadIn2),
    .BranchOut   (BranchOutofIDEX),
    .MemWriteOut (MemWriteOutofIDEX),
    .MemReadOut  (MemReadOutofIDEX),
    .MemtoRegIn  (WBSource_bus2),
    .RegWriteIn  (RegWriteIn2),
    .MemtoRegOut (WBSourceOutofIDEX),
    .RegWriteOut (RegWriteOutofIDEX),
    // data in/out
    .ReadData1In (ReadData1In),
    .ReadData2In (ReadData2In),
    .PCAddResultIn(PCAddResultOutofIFID),
    .signResultIn(immFinal),
    .RTRegdestIn (rt),
    .RDRegdestIn (rd),
    .ReadData1Out(ReadData1OutofIDEX),
    .ReadData2Out(ReadData2OutofIDEX),
    .PCAddResultOut(PCAddResultOutofIDEX),
    .signResultOut(signResultOutofIDEX),
    .RTRegdestOut(RTRegdestOutofIDEX),
    .RDRegdestOut(RDRegdestOutofIDEX),
    .UseShamtIn(UseShamt2),
    .UseShamtOut(UseShamtOutofIDEX),
    .shamtIn(shamt),
    .shamtOut(shamtOutofIDEX),
    .RegDstSelIn (RegDstSel_bus2),         // from controller (ID)
    .RegDstSelOut(RegDstSelOutofIDEX),
    .MemSizeIn     (MemSize2),
    .MemUnsignedIn (MemUnsigned2),
    .MemSizeOut    (MemSizeOutofIDEX),
    .MemUnsignedOut(MemUnsignedOutofIDEX),
    .rs_in(rs), 
    .rs_out(RSOutofIDEX)
  );

  // =========================
  // Execute
  // =========================
  wire [31:0] BottomALUInput;
  wire [31:0] immSL2_out;
  wire [31:0] ALUResult;
  wire        ZeroIn;

  // 5-bit write-register selection in EX (rt vs rd), then PIPELINE it
 /*mux3x1_RegDst mux_reg_dst (
    .out(WriteReg_EX),
    .inA(RTRegdestOutofIDEX),
    .inB(RDRegdestOutofIDEX),
    .sel(RegDstOutofIDEX)
);*/
// Compute exactly which register to write in EX
reg [4:0] WriteReg_EX;
always @* begin
  case (RegDstSelOutofIDEX)           // 00: rt, 01: rd, 10: $31
    2'b00: WriteReg_EX = RTRegdestOutofIDEX;   // I-type (addi, lw, etc.)
    2'b01: WriteReg_EX = RDRegdestOutofIDEX;   // R-type (sub, sll, etc.)
    2'b10: WriteReg_EX = 5'd31;                // jal writes $ra = 31
    default: WriteReg_EX = RTRegdestOutofIDEX;
  endcase
end

  // B-input mux to ALU: sel=1 -> immediate (signResultOutofIDEX), sel=0 -> ReadData2
  
  //Fowarding Muxes
  Mux32Bit2To1 c1(mux2Out,WriteData,ReadData2OutofIDEX,fowardB); //bottom one
  Mux32Bit2To1 c2(mux1Out,WriteData,ReadData1OutofIDEX,fowardA); //top one
  
  Mux32Bit2To1 mux_alu_b(
    .out (BottomALUInput),
    .inA (mux2Out),  //was ReadData2OutofIDEX changed to mux1Out for fowarding
    .inB (signResultOutofIDEX),
    .sel (ALUSrcOutofIDEX)
  );

  //////////////////////////////////////////////////////////////
  //
  wire [31:0] ALU_A_input;
  assign ALU_A_input = UseShamtOutofIDEX ? {27'b0, shamtOutofIDEX} : mux1Out;
  //check THIS!!!!

  ////////////////////////////////////////////////////////////////////////////
  
  //shift left 2 unit (changed this for lab 6)
  immSL2 a12(.in(immFinal), .out(immSL2_out));

  // Branch target = PC+4 (ID/EX) + (imm << 2)
  wire [31:0] BranchTargetIn_EX;
  Adder a8(.PCAddResult(PCAddResultOutofIFID), .immSL2(immSL2_out), .InstructionSig(BranchTargetIn_EX));   // changed PCAddResultOutofIDEX to PCAddResultOutofIFID

  ALU32Bit a11(
    .ALUControl(ALUopOutofIDEX),     // 6-bit path intact
    .A(ALU_A_input),
    .B(BottomALUInput),
    .ALUResult(ALUResult),
    .Zero(ZeroIn)
  );
  
  // EX: detect compare-style ops from ALU control
wire is_cmp_EX = (ALUopOutofIDEX == 6'd10) || // CMPEQ
                 (ALUopOutofIDEX == 6'd11) || // CMPNE
                 (ALUopOutofIDEX == 6'd12) || // CMPGT0
                 (ALUopOutofIDEX == 6'd13) || // CMPGE0
                 (ALUopOutofIDEX == 6'd14) || // CMPLT0
                 (ALUopOutofIDEX == 6'd15);   // CMPLE0

// EX: branch condition (1 = take)
wire BranchCond_EX = is_cmp_EX ? ALUResult[0] : ZeroIn;

  FowardingUnit b5(
    .id_ex_rs(RSOutofIDEX),
    .id_ex_rt(RTRegdestOutofIDEX) //correct
    .ex_mem_reg_write(RegWriteOutofEXMEM), //correct
    .ex_mem_rd(WriteReg_EXMEM), //correct
    .mem_wb_reg_write(RegWriteOutofMEMWB), //correct
    .mem_wb_rd(WriteReg_MEMWB),  //correct
    .foward_a(fowardA),
    .foward_b(fowardB)
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
  wire        BranchOutofEXMEM, RegWriteOutofEXMEM;
  wire        MemtoRegOutofEXMEM;
 

  // *** Add a proper 5-bit write-reg pipe through EX/MEM
  wire [4:0] WriteReg_EXMEM;
  wire [31:0] PCResultOutofEXMEM = PCAddResultOutofEXMEM;
  wire [31:0] BranchTargetOutofEXMEM;

  EX_MEM a15(
    // branch target
    .AddResultIn (BranchTargetIn_EX),
    .AddResultOut(BranchTargetOutofEXMEM),

    .ALUResultIn(ALUResult), .ALUResultOut(ALUResultOutofEXMEM),

    // keep original MuxIn/MuxOut wiring as-is (name preserved), but use a new 5-bit pipe for WriteReg
    .MuxIn(RegDstOutofIDEX ? {27'b0, RDRegdestOutofIDEX} : {27'b0, RTRegdestOutofIDEX}),
    .MuxOut(MuxOutofEXMEM),

    .ReadData2In(mux2Out), .ReadData2Out(ReadData2OutofEXMEM),

    .ZeroIn(ZeroIn), .ZeroOut(ZeroOut),

    .MemWriteIn(MemWriteOutofIDEX), .MemWriteOut(MemWriteOutofEXMEM),
    .MemReadIn (MemReadOutofIDEX),  .MemReadOut (MemReadOutofEXMEM),
    .BranchIn  (BranchOutofIDEX),   .BranchOut  (BranchOutofEXMEM),
    .MemtoRegIn(WBSourceOutofIDEX), .MemtoRegOut(WBSourceOutofEXMEM),
    .RegWriteIn(RegWriteOutofIDEX), .RegWriteOut(RegWriteOutofEXMEM),
    .PCAddResultIn(PCAddResultOutofIDEX), .PCAddResultOut(PCAddResultOutofEXMEM),

    .Clk(Clk),
    .Reset(Reset),

    // *** New 5-bit register index pipe (add these two ports in EX_MEM module)
    .WriteRegIn (WriteReg_EX),
    .WriteRegOut(WriteReg_EXMEM),
    
    .MemSizeIn     (MemSizeOutofIDEX),
    .MemUnsignedIn (MemUnsignedOutofIDEX),
    .MemSizeOut    (MemSizeOutofEXMEM),
    .MemUnsignedOut(MemUnsignedOutofEXMEM),
    .BranchCondIn (BranchCond_EX),
    .BranchCondOut(BranchCondOutofEXMEM)

  );


  // =========================
  // Data Memory
  // =========================
  wire [31:0] ReadData;
  wire MemWrite_safe = MemWriteOutofEXMEM & ~PCSrc;

  DataMemory a10(
    .Address  (ALUResultOutofEXMEM),
    .WriteData(ReadData2OutofEXMEM),
    .Clk(Clk),
    .MemWrite (MemWrite_safe),
    .MemRead  (MemReadOutofEXMEM),
    .MemSize  (MemSizeOutofEXMEM),
    .MemUnsigned(MemUnsignedOutofEXMEM),
    .ReadData (ReadData)
  );

// ---------------------------
// Branch decision logic (MEM stage)
// ---------------------------
// (BranchCondOutofEXMEM comes from EX_MEM.v via BranchCond_q)

wire PCSrc = BranchOutofEXMEM && BranchCondOutofEXMEM;

// Select PC target or PC+4 based on branch decision MUX FOR PC+4 VS JUMP TARGET
  
  wire [31:0] PCBranchOrSeq = PCSrc ? BranchTargetIn_EX : IF_PCPlus4;  // IN LAB 6: changed BranchTargetOutofEXMEM  to  BranchTargetIn_EX



  // =========================
  // MEM/WB
  // =========================
  wire [31:0] ReadDataOutofMEMWB, ALUResultOutofMEMWB;

  // *** Add a 5-bit write-reg pipe through MEM/WB as well
  wire [4:0] WriteReg_MEMWB;
  
  wire MemtoRegOutofMEMWB;
  wire RegWriteOutofMEMWB;
  wire [31:0] PCResultOutofMEMWB;

  MEM_WB a16(
    .ReadDataIn (ReadData),              .ReadDataOut (ReadDataOutofMEMWB),
    .ALUResultIn(ALUResultOutofEXMEM),   .ALUResultOut(ALUResultOutofMEMWB),
    .MemtoRegIn (WBSourceOutofEXMEM),    .MemtoRegOut (WBSourceOutofMEMWB),
    .RegWriteIn (RegWriteOutofEXMEM & ~PCSrc),    .RegWriteOut (RegWriteOutofMEMWB),
    .PCResultIn(PCResultOutofEXMEM), .PCResultOut(PCResultOutofMEMWB),
    .Clk(Clk),
    .Reset(Reset),

    // *** New 5-bit write-reg pipe (add these two ports in MEM_WB module)a
    .WriteRegIn (WriteReg_EXMEM),
    .WriteRegOut(WriteReg_MEMWB),
    
    .BranchTakenIn (PCSrc),
    .BranchTakenOut(BranchTakenOutofMEMWB)
  );



mux3x1 wb_mux3(
  .out(WriteData),
  .inA(ALUResultOutofMEMWB),  // 00: ALU
  .inB(ReadDataOutofMEMWB),   // 01: MEM
  .inC(PCResultOutofMEMWB),   // 10: PC+4
  .sel(WBSourceOutofMEMWB)    // 2-bit, pipelined
);



  // *** Use the WB-stage register index to write the file (timing-correct)
  wire [4:0] WriteRegister_wb_sel = WriteReg_MEMWB;
  assign WriteRegister = WriteRegister_wb_sel;

// =========================
// Next PC selection (Branch / Jump / JR / Seq)
// =========================

wire [31:0] JumpTarget;
assign JumpTarget = {PCAddResultOutofIFID[31:28], instructionReadOut[25:0], 2'b00};



// Final PC priority: JR > J > Branch > Sequential
  assign PCNext = JumpReg2 ? ReadData1In : (Jump2 ? JumpTarget : PCBranchOrSeq);

  

  // Final external outputs (as in your original)
  wire do_wb = RegWriteOutofMEMWB && ~MemWriteOutofEXMEM && ~PCSrc;
  
  //assign instructionWrite = IF_Instruction;   // show current fetched instruction
  //assign WB_RegWrite      = RegWriteOutofMEMWB;
  //assign WB_WriteReg  = WriteRegister_wb_sel;
  //assign WB_WriteData = BranchTakenOutofMEMWB ? 32'd0 : WriteData;
  assign WB_WriteData = do_wb ? WriteData : 32'd0;
  //assign WB_WriteReg  = do_wb ? WriteRegister_wb_sel : 5'd0;
  //assign WB_RegWrite  = RegWriteOutofMEMWB; // keep real control for the RF


  assign v0Out = v0;
  assign v1Out = v1;

endmodule
