
//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
 
`timescale 1ns / 1ps
module toplevel(
  input Clk,
  input Reset,
  //output [31:0] instructionWrite,
  output [31:0] PC_out,
  //output WB_RegWrite,
  //output [4:0] WB_WriteReg,
  output [31:0] WB_WriteData
  //output [6:0] out7,
  //output [7:0] en_out
);
  // =========================
  // IF stage via IFU
  // =========================
  wire [31:0] IF_PC; // current PC
  wire [31:0] IF_Instruction; // fetched instruction
  wire [31:0] IF_PCPlus4; // PC+4 from IFU
  wire [31:0] PCNext; // chosen at top
  // Hazard unit will drive PCWrite
  wire PCWrite;
  InstructionFetchUnit IFU (
    .Instruction(IF_Instruction),
    .PCResult (IF_PC),
    .PCPlus4 (IF_PCPlus4),
    .PCNext (PCNext),
    .Reset (Reset),
    .Clk (Clk),
    .PCWrite (PCWrite)
  );
  assign PC_out = IF_PC;
  // =========================
  // IF/ID pipeline register
  // =========================
  wire [31:0] instructionReadOut; // instruction to Decode
  wire [31:0] PCAddResultOutofIFID; // PC+4 to Decode
  // From HazardDetection
  wire IF_ID_Write;
  wire IF_Flush;
  wire ID_Flush;
  wire ControlMuxSel;
  RegisterIF_ID IF_ID_reg(
    .PCAddResult (IF_PCPlus4),
    .instructionReadIn (IF_Instruction),
    .PCAddResultOut (PCAddResultOutofIFID),
    .instructionReadOut(instructionReadOut),
    .Clk (Clk),
    .Reset (Reset),
    .WriteEnable (IF_ID_Write),
    .Flush (IF_Flush)
  );
  // =========================
  // Decode
  // =========================
  wire [5:0] opCode = instructionReadOut[31:26];
  wire [4:0] rs = instructionReadOut[25:21];
  wire [4:0] rt = instructionReadOut[20:16];
  wire [4:0] rd = instructionReadOut[15:11];
  wire [4:0] shamt = instructionReadOut[10:6];
  wire [15:0] imm16 = instructionReadOut[15:0];
  wire ALUSrcIn, RegDstIn, MemReadIn, MemWriteIn, RegWriteIn;
  wire BranchIn, Jump, JumpReg, UseShamt;
  wire [5:0] OPCodeIn; // ALU control from controller
  wire [31:0] ReadData1In, ReadData2In;
  // Controller emits 2-bit WBSource (00 ALU, 01 Mem, 10 PC+4) and 2-bit RegDstSel.
  wire [1:0] WBSource_bus;
  wire [1:0] RegDstSel_bus;
  wire [1:0] MemSize; // 00=byte, 01=half, 10=word
  wire MemUnsigned; // loads: 1 = zero-extend, 0 = sign-extend
  wire ExtZero;
  // Reduce 2-bit RegDstSel (00 rt, 01 rd, 10 $31) to 1-bit RegDst (rt vs rd)
  wire RegDst1bit = (RegDstSel_bus == 2'b01); // 0=rt, 1=rd
  controller a2(
    .instruction(instructionReadOut),
    .Clk(Clk),
    .ALUSrc(ALUSrcIn),
    .RegDstSel(RegDstSel_bus),
    .ALUControl(OPCodeIn),
    .MemRead(MemReadIn),
    .MemWrite(MemWriteIn),
    .WBSource(WBSource_bus),
    .RegWrite(RegWriteIn),
    .Branch(BranchIn),
    .Jump(Jump),
    .UseShamt(UseShamt),
    .JumpReg(JumpReg),
    .MemSize(MemSize),
    .MemUnsigned(MemUnsigned),
    .ExtZero(ExtZero)
  );
 
  wire [31:0] signExtImm, zeroExtImm, immFinal;
  SignExtension a3(.in(imm16), .out(signExtImm));
  assign zeroExtImm = {16'b0, imm16};
  assign immFinal = ExtZero ? zeroExtImm : signExtImm;
  // Writeback wires (defined later)
  wire [31:0] WriteData;
  wire [4:0] WriteRegister;
  RegisterFile a5(
    .ReadRegister1(rs),
    .ReadRegister2(rt),
    .WriteRegister(WriteReg_MEMWB),
    .WriteData(WriteData),
    .RegWrite(RegWriteOutofMEMWB),
    .Clk(Clk),
    .ReadData1(ReadData1In),
    .ReadData2(ReadData2In)
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
  wire ALUSrcOutofIDEX, RegDstOutofIDEX, BranchOutofIDEX;
  wire MemWriteOutofIDEX, MemReadOutofIDEX;
  wire MemToRegOutofIDEX;
  wire RegWriteOutofIDEX;
  wire [5:0] ALUopOutofIDEX;
  wire UseShamtOutofIDEX;
  wire [31:0] ReadData1OutofIDEX, ReadData2OutofIDEX;
  wire [31:0] PCAddResultOutofIDEX, signResultOutofIDEX;
  wire [4:0] RTRegdestOutofIDEX, RDRegdestOutofIDEX;
  wire [4:0] shamtOutofIDEX;
  wire [1:0] WBSourceOutofIDEX;
  wire [1:0] WBSourceOutofEXMEM;
  wire [1:0] WBSourceOutofMEMWB;
  wire [1:0] MemSizeOutofIDEX;
  wire MemUnsignedOutofIDEX;
  wire [1:0] MemSizeOutofEXMEM;
  wire MemUnsignedOutofEXMEM;
  wire [1:0] RegDstSelOutofIDEX;
  // NEW: source register numbers for forwarding/hazards
  wire [4:0] RsOutofIDEX;
  wire [4:0] RtOutofIDEX;
  // ---- Control bubble mux into ID/EX (for HazardDetection) ----
  wire ALUSrc_IDEX_in = ControlMuxSel ? ALUSrcIn : 1'b0;
  wire Branch_IDEX_in = ControlMuxSel ? BranchIn : 1'b0;
  wire MemWrite_IDEX_in = ControlMuxSel ? MemWriteIn : 1'b0;
  wire MemRead_IDEX_in = ControlMuxSel ? MemReadIn : 1'b0;
  wire RegWrite_IDEX_in = ControlMuxSel ? RegWriteIn : 1'b0;
  wire [1:0] WBSource_IDEX_in = ControlMuxSel ? WBSource_bus : 2'b00;
  wire RegDst1bit_IDEX_in = ControlMuxSel ? RegDst1bit : 1'b0;
  wire UseShamt_IDEX_in = ControlMuxSel ? UseShamt : 1'b0;
  wire [1:0] RegDstSel_IDEX_in = ControlMuxSel ? RegDstSel_bus : 2'b00; // <<< NEW
 
  RegisterID_EX a14(
    .Clk(Clk),
    .Reset(Reset),
    .Flush(ID_Flush), // flush on taken branch/jump
    // control in/out
    .ALUSrcIn (ALUSrc_IDEX_in),
    .ALUopIn (OPCodeIn),
    .RegDstIn (RegDst1bit_IDEX_in),
    .ALUSrcOut (ALUSrcOutofIDEX),
    .ALUopOut (ALUopOutofIDEX),
    .RegDstOut (RegDstOutofIDEX),
    .BranchIn (Branch_IDEX_in),
    .MemWriteIn (MemWrite_IDEX_in),
    .MemReadIn (MemRead_IDEX_in),
    .BranchOut (BranchOutofIDEX),
    .MemWriteOut (MemWriteOutofIDEX),
    .MemReadOut (MemReadOutofIDEX),
    .MemtoRegIn (WBSource_IDEX_in),
    .RegWriteIn (RegWrite_IDEX_in),
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
    .UseShamtIn (UseShamt_IDEX_in),
    .UseShamtOut(UseShamtOutofIDEX),
    .shamtIn (shamt),
    .shamtOut (shamtOutofIDEX),
    //.RegDstSelIn (RegDstSel_bus),
    //.RegDstSelOut(RegDstSelOutofIDEX),
    .RegDstSelIn (RegDstSel_IDEX_in),
    .RegDstSelOut(RegDstSelOutofIDEX),
    .MemSizeIn (MemSize),
    .MemUnsignedIn (MemUnsigned),
    .MemSizeOut (MemSizeOutofIDEX),
    .MemUnsignedOut(MemUnsignedOutofIDEX),
    .RsIn(rs),
    .RtIn(rt),
    .RsOut(RsOutofIDEX),
    .RtOut(RtOutofIDEX)
  );
  // =========================
  // Execute
  // =========================
  wire [31:0] BottomALUInput;
  wire [31:0] immSL2_out;
  wire [31:0] ALUResult;
  wire ZeroIn;
  // Forwarding select signals
  wire [1:0] forward_a;
  wire [1:0] forward_b;
  // Forwarded ALU operands
  wire [31:0] ForwardAData;
  wire [31:0] ForwardBData;
  // 5-bit write-register selection in EX (rt vs rd) then pipelined
  reg [4:0] WriteReg_EX;
  always @* begin
    case (RegDstSelOutofIDEX) // 00: rt, 01: rd, 10: $31
      2'b00: WriteReg_EX = RTRegdestOutofIDEX; // I-type
      2'b01: WriteReg_EX = RDRegdestOutofIDEX; // R-type
      2'b10: WriteReg_EX = 5'd31; // jal
      default: WriteReg_EX = RTRegdestOutofIDEX;
    endcase
  end
  // Forwarding logic for ALU A/B inputs
  assign ForwardAData = (forward_a == 2'b10) ? ALUResultOutofEXMEM :
                        (forward_a == 2'b01) ? WriteData :
                                              ReadData1OutofIDEX;
  assign ForwardBData = (forward_b == 2'b10) ? ALUResultOutofEXMEM :
                        (forward_b == 2'b01) ? WriteData :
                                              ReadData2OutofIDEX;
  // B-input mux to ALU: sel=1 -> immediate, sel=0 -> forwarded RT
  Mux32Bit2To1 mux_alu_b(
  .out (BottomALUInput),
  .inA (ForwardBData), // register path
  .inB (signResultOutofIDEX), // immediate
  .sel (ALUSrcOutofIDEX) // 0 = reg, 1 = imm
);
  wire [31:0] ALU_A_input;
  assign ALU_A_input = UseShamtOutofIDEX ? {27'b0, shamtOutofIDEX}
                                         : ForwardAData;
  // shift left 2 unit (changed this for lab 6)
  immSL2 a12(.in(signResultOutofIDEX), .out(immSL2_out));
  // Branch target = PC+4 (ID/EX) + (imm << 2)
  wire [31:0] BranchTargetIn_EX;
  Adder a8(
    .PCAddResult (PCAddResultOutofIDEX),
    .immSL2 (immSL2_out),
    .InstructionSig(BranchTargetIn_EX)
  );
  ALU32Bit a11(
    .ALUControl(ALUopOutofIDEX),
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
                   (ALUopOutofIDEX == 6'd15); // CMPLE0
  // EX: branch condition (1 = take)
  wire BranchCond_EX = is_cmp_EX ? ALUResult[0] : ZeroIn;
  // =========================
  // EX/MEM
  // =========================
  wire [31:0] PCAddResultOutofEXMEM;
  wire [31:0] ALUResultOutofEXMEM;
  wire [31:0] ReadData2OutofEXMEM;
  wire [31:0] MuxOutofEXMEM;
  wire ZeroOut;
  wire MemWriteOutofEXMEM, MemReadOutofEXMEM;
  wire BranchOutofEXMEM, RegWriteOutofEXMEM;
  wire MemtoRegOutofEXMEM;
  wire BranchCondOutofEXMEM;
  // 5-bit write reg through EX/MEM
  wire [4:0] WriteReg_EXMEM;
  wire [31:0] PCResultOutofEXMEM = PCAddResultOutofEXMEM;
  wire [31:0] BranchTargetOutofEXMEM;
  EX_MEM a15(
    .AddResultIn (BranchTargetIn_EX),
    .AddResultOut(BranchTargetOutofEXMEM),
    .ALUResultIn (ALUResult),
    .ALUResultOut(ALUResultOutofEXMEM),
    .MuxIn (RegDstOutofIDEX ? {27'b0, RDRegdestOutofIDEX}
                            : {27'b0, RTRegdestOutofIDEX}),
    .MuxOut(MuxOutofEXMEM),
    .ReadData2In (ForwardBData),
    .ReadData2Out(ReadData2OutofEXMEM),
    .ZeroIn(ZeroIn),
    .ZeroOut(ZeroOut),
    .MemWriteIn(MemWriteOutofIDEX),
    .MemWriteOut(MemWriteOutofEXMEM),
    .MemReadIn (MemReadOutofIDEX),
    .MemReadOut(MemReadOutofEXMEM),
    .BranchIn (BranchOutofIDEX),
    .BranchOut (BranchOutofEXMEM),
    .MemtoRegIn (WBSourceOutofIDEX),
    .MemtoRegOut(WBSourceOutofEXMEM),
    .RegWriteIn (RegWriteOutofIDEX),
    .RegWriteOut(RegWriteOutofEXMEM),
    .PCAddResultIn (PCAddResultOutofIDEX),
    .PCAddResultOut(PCAddResultOutofEXMEM),
    .Clk (Clk),
    .Reset (Reset),
    .WriteRegIn (WriteReg_EX),
    .WriteRegOut(WriteReg_EXMEM),
   
    .MemSizeIn (MemSizeOutofIDEX),
    .MemUnsignedIn (MemUnsignedOutofIDEX),
    .MemSizeOut (MemSizeOutofEXMEM),
    .MemUnsignedOut(MemUnsignedOutofEXMEM),
    .BranchCondIn (BranchCond_EX),
    .BranchCondOut(BranchCondOutofEXMEM)
  );
  // =========================
  // Data Memory
  // =========================
  wire [31:0] ReadData;
  // Branch decision (MEM stage)
  wire PCSrc;
  assign PCSrc = BranchOutofEXMEM && BranchCondOutofEXMEM;

  wire BranchTakenOutofMEMWB;
 wire MemWrite_safe = MemWriteOutofEXMEM & ~PCSrc & ~BranchTakenOutofMEMWB;

  DataMemory a10(
    .Address (ALUResultOutofEXMEM),
    .WriteData (ReadData2OutofEXMEM),
    .Clk (Clk),
    .MemWrite (MemWrite_safe),
    .MemRead (MemReadOutofEXMEM),
    .MemSize (MemSizeOutofEXMEM),
    .MemUnsigned(MemUnsignedOutofEXMEM),
    .ReadData (ReadData)
  );
  // Select PC target or PC+4 based on branch decision
  wire [31:0] PCBranchOrSeq = PCSrc ? BranchTargetOutofEXMEM : IF_PCPlus4;
  // =========================
  // MEM/WB
  // =========================
  wire [31:0] ReadDataOutofMEMWB, ALUResultOutofMEMWB;
  // 5-bit write-reg pipe through MEM/WB
  wire [4:0] WriteReg_MEMWB;
 
  wire MemtoRegOutofMEMWB;
  wire RegWriteOutofMEMWB;
  wire [31:0] PCResultOutofMEMWB;
  MEM_WB a16(
    .ReadDataIn (ReadData),
    .ReadDataOut(ReadDataOutofMEMWB),
    .ALUResultIn(ALUResultOutofEXMEM),
    .ALUResultOut(ALUResultOutofMEMWB),
    .MemtoRegIn (WBSourceOutofEXMEM),
    .MemtoRegOut(WBSourceOutofMEMWB),
    .RegWriteIn (RegWriteOutofEXMEM & ~BranchTakenOutofMEMWB),
    .RegWriteOut(RegWriteOutofMEMWB),
    .PCResultIn (PCResultOutofEXMEM),
    .PCResultOut(PCResultOutofMEMWB),
    .Clk (Clk),
    .Reset (Reset),
    .WriteRegIn (WriteReg_EXMEM),
    .WriteRegOut(WriteReg_MEMWB),
   
    .BranchTakenIn (PCSrc),
    .BranchTakenOut(BranchTakenOutofMEMWB)
  );
  // =========================
  // Writeback mux
  // =========================
  mux3x1 wb_mux3(
    .out(WriteData),
    .inA(ALUResultOutofMEMWB),
    .inB(ReadDataOutofMEMWB),
    .inC(PCResultOutofMEMWB),
    .sel(WBSourceOutofMEMWB)
  );
  wire [4:0] WriteRegister_wb_sel = WriteReg_MEMWB;
  assign WriteRegister = WriteRegister_wb_sel;
  // =========================
  // Next PC selection (Branch / Jump / JR / Seq)
  // =========================
  wire [31:0] JumpTarget;
  assign JumpTarget = {PCAddResultOutofIFID[31:28], instructionReadOut[25:0], 2'b00};
  // Final PC priority: JR > J > Branch > Sequential
  assign PCNext = JumpReg ? ReadData1In
                          : (Jump ? JumpTarget : PCBranchOrSeq);
  // =========================
  // Forwarding Unit
  // =========================
  ForwardingUnit fwd_unit (
    .id_ex_rs (RsOutofIDEX),
    .id_ex_rt (RtOutofIDEX),
    .ex_mem_reg_write (RegWriteOutofEXMEM),
    .ex_mem_rd (WriteReg_EXMEM),
    .mem_wb_reg_write (RegWriteOutofMEMWB),
    .mem_wb_rd (WriteReg_MEMWB),
    .forward_a (forward_a),
    .forward_b (forward_b)
  );
  // =========================
  // Hazard Detection Unit
  // =========================
  HazardDetection hazard_unit (
    .id_ex_MemRead (MemReadOutofIDEX),
    .id_ex_Rt (RTRegdestOutofIDEX),
    .if_id_Rs (rs),
    .if_id_Rt (rt),
    .ex_mem_RegWrite (RegWriteOutofEXMEM),
    .ex_mem_Rd (WriteReg_EXMEM),
    .mem_wb_RegWrite (RegWriteOutofMEMWB),
    .mem_wb_Rd (WriteReg_MEMWB),
    .id_isBranch (BranchIn),
    .id_isJR (JumpReg),
    .ex_branchTaken (PCSrc), // branch resolves in MEM in this design
    .id_isJump (Jump),
    .PCWrite (PCWrite),
    .IF_ID_Write (IF_ID_Write),
    .ControlMuxSel (ControlMuxSel),
    .IF_Flush (IF_Flush),
    .ID_Flush (ID_Flush)
  );
  // Final external WB output
  assign WB_WriteData = RegWriteOutofMEMWB ? WriteData : 32'd0;
endmodule