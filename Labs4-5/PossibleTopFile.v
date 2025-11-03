`timescale 1ns / 1ps

module toplevel(instructionRead,Clk,instructionWrite);
  input [31:0] instructionRead;
  input Clk;
  output [31:0] instructionWrite;
  
  wire [5:0]  opCode;
wire [4:0]  rs;
wire [4:0]  rt;
wire [4:0]  rd;
wire [4:0]  shamt;
wire [5:0]  funct;
wire [15:0] imm;

// Between stages
wire [31:0] instruction;              // output of InstructionMemory
wire [31:0] instructionReadOut;       // output of IF/ID
wire [31:0] Instruction;              // from InstructionMemory (alias)
wire [31:0] PCAddResult;              // from PCAdder
wire [31:0] PCAddResultOutofIFID;     // output of IF/ID

// Controller signals
wire ALUSrcIn, RegDstIn, MemReadIn, MemWriteIn, MemtoRegIn, RegWriteIn;
wire BranchIn, Jump;
wire [3:0] OPCodeIn;

// Sign extension
wire [31:0] signResultIn;

// RegisterFile connections
wire [31:0] ReadData1In, ReadData2In;

// ID/EX register outputs
wire ALUSrcOutofIDEX, RegDstOutofIDEX, BranchOutofIDEX, MemWriteOutofIDEX, MemReadOutofIDEX;
wire MemToRegOutofIDEX, RegWriteOutofIDEX;
wire [3:0] ALUopOutofIDEX;
wire [31:0] ReadData1OutofIDEX, ReadData2OutofIDEX, PCAddResultOutofIDEX, signResultOutofIDEX;
wire [4:0] RTRegdestOutofIDEX, RDRegdestOutofIDEX;

// Execute stage
wire [31:0] BottomALUInput;
wire [31:0] immSL2;
wire [31:0] ALUResult;
wire ZeroIn;

// EX/MEM register outputs
wire [31:0] PCAddResultOutofEXMEM;
wire [31:0] ALUResultOutofEXMEM;
wire [31:0] MuxIn, MuxOutofEXMEM;
wire [31:0] ReadData2OutofIDED, ReadData2OutofEXMEM;
wire ZeroOut;
wire MemWriteOutofEXMEM, MemReadOutofEXMEM, BranchOutofEXMEM, MemtoRegOutofEXMEM, RegWriteOutofEXMEM;

// Data Memory
wire [31:0] ReadData;

// MEM/WB register outputs
wire [31:0] ReadDataOutofMEMWB, ALUResultOutofMEMWB;
wire MemtoRegOutofMEMWB, RegWriteOutofMEMWB;

// Writeback
wire [31:0] WriteData;
wire [4:0] WriteRegister;

// PC / branch MUX
wire [31:0] out, inA, inB;
wire sel;
wire PCSrc;

  assign opCode = instructionReadOut [31:26];
    assign   rs = instructionReadOut [25:21];
  assign   rt = instructionReadOut [20:16];
      assign rd = instructionReadOut [15:11];
  assign shamt = instructionReadOut [10:6]; 
  assign funct = instructionReadOut [5:0];
  
  //For I-type instructions
// assign imm = instructionRead [15:0];
  
  assign imm = instructionRead [15:0];
    
  Mux32Bit2To1 a19(NextPC, PCAddResult, MuxOutofEXMEM, PCSrc); //Mux to select between PC+4 and Branch
  
  InstructionMemory a1(instructionRead, Instruction);  //NEED TO FIX THIS MODULES INTERNALS
  
  PCAdder a4(instructionRead, PCAddResult); //Takes instruction number and adds 4

  //FIRST STAGE REGISTER Fetch->Decode
  RegisterIF_ID a13(PCAddResult,instruction,PCAddResultOutofIFID,instructionReadOut,Clk);

    //All "in"-suffix ports feed into ID/EX register
  controller a2(instructionReadOut, Clk, ALUSrcIn, RegDstIn, OPCodeIn, MemReadIn, MemWriteIn, MemtoRegIn, RegWriteIn, BranchIn,Jump); //Check but should be good

  SignExtension a3(imm, signResultIn); //signResultIn goes to ID/EX reg

  RegisterFile a5(rs, rt, WriteRegister, WriteData, RegWrite, Clk, ReadData1In, ReadData2In); //Should be good
  

  
  //SECOND STAGE REGISTER Decode->Execute
RegisterID_EX a14(Clk,ALUSrcIn,ALUopIn,RegDstIn,ALUSrcOutofIDEX,ALUopOutofIDEX,RegDstOutofIDEX,BranchIn,MemWriteIn,MemReadIn,
                     BranchOutofIDEX,MemWriteOutofIDEX,MemReadOutofIDEX,MemToRegIn,RegWriteIn,MemToRegOutofIDEX,RegWriteOutofIDEX,
                     ReadData1In,ReadData2In,PCAddResultOutofIFID,signResultIn,rt,rd,
                     ReadData1OutofIDEX,ReadData2OutofIDEX,PCAddResultOutofIDEX,signResultOutofIDEX,RTRegdestOutofIDEX,
                     RDRegdestOutofIDEX);

  Mux32Bit2To1 a6(WriteRegister, RTRegdestOutofIDEX, RDRegdestOutofIDEX, RegDstOutofIDEX);  //$rd vs imm mux, uses regDst as signal

  Mux32Bit2To1 a7(BottomALUInput, ReadData2OutofIDEX, signResultOutofIDEX, ALUSrcOutofIDEX);  //Sign extend imm vs $rt (Read data 2), uses ALUSrc as signal, outputs the B input to ALU
  
  Adder a8(PCAddResultOutofIDEX, immSL2, PCAddResultIn); //Adds PC instruction+4 (Output of PCADDER) and Imm*4 (Shift left 2 module) together, sending to PC mu
  //PCAddResultIn goes into register 

  
  immSL2 a12(signResultOutofIDEX,immSL2); //Multiplies in by 4
  
  ALU32Bit a11(ALUopOutofIDEX, ReadData1OutofIDEX, BottomALUInput, ALUResult, ZeroIn);
  
  //THIRD STAGE REGISTER Execute->Memory
  EX_MEM a15(PCAddResultIn, PCAddResultOutofEXMEM,ALUResult , ALUResultOutofEXMEM, MuxIn, MuxOutofEXMEM, ReadData2OutofIDED, ReadData2OutofEXMEM, ZeroIn, ZeroOut,MemWriteOutofIDEX, MemWriteOutofEXMEM, MemReadOutofIDEX, MemReadOutofEXMEM, BranchOutofIDEX, BranchOutofEXMEM, MemtoRegIn, MemtoRegOutofEXMEM, RegWriteIn, RegWriteOutofEXMEM, Clk);

   DataMemory a10(ALUResultOutofEXMEM, ReadData2OutofEXMEM, Clk, MemWriteOutofEXMEM, MemReadOutofIDEX, ReadData); //Should be good
  
  AND a18(BranchOutofEXMEM, ZeroOut, PCSrc);
  
  //FOURTH STAGE REGISTER Memory->Write Back
  MEM_WB a16(ReadData, ReadDataOutofMEMWB, ALUResultOutofEXMEM, ALUResultOutofMEMWB, MemtoRegOutofEXMEM, MemtoRegOutofMEMWB, RegWriteOutofEXMEM, RegWriteOutofMEMWB, Clk);
  
   Mux32Bit2To1 a17(WriteData, ReadDataOutofMEMWB, ALUResultOutofEXMEM, MemtoRegOutofMEMWB); //Takes ReadData vs ALUresult, controlled by MemtoReg

  Mux32Bit2To1 a9(InstructionWrite, PCAddResult, PCAddResultOutofEXMEM, PCSrc); //Chooses between PCaddResult and instructionSig (Output of Adder)

  assign instructionWrite = WriteData;
  
  
 

  
  
endmodule
