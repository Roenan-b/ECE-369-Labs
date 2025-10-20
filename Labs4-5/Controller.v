`timescale 1ns / 1ps

module controller(instruction, Clk, ALUSrc,RegDst,OPCode,MemRead,MemWrite);   //FIX THIS!!

  input [31:0] instruction; //Problably 32 bits
  input Clk;


  output reg ALUSrc;
  output reg RegDst;
  output reg [5:0] OPCode;  //Needs to be ?? bits
  output reg MemRead;
  output reg MemWrite;
  output reg MemtoReg;
  output reg RegWrite;
  output reg Branch;
  output reg Jump;
  
 // wire [5:0] opcode = instruction[31:26];
    // wire [4:0] rs     = instruction[25:21];
    // wire [4:0] rt     = instruction[20:16];
    // wire [4:0] rd     = instruction[15:11];
    // wire [5:0] funct  = instruction[5:0];
    localparam OP_RTYPE   = ; // SPECIAL
    localparam OP_REGIMM  = ; // BLTZ/BGEZ via rt field  CHANGE THIS
    localparam OP_J       = ;
    localparam OP_JAL     = ;
    localparam OP_BEQ     = ;
    localparam OP_BNE     = ;
    localparam OP_BLEZ    = ;
    localparam OP_BGTZ    = ;

    localparam OP_ADDI    = ;
    localparam OP_SLTI    = ;
    localparam OP_ANDI    = ;
    localparam OP_ORI     = ;
    localparam OP_XORI    = ;

    localparam OP_LB      = ;
    localparam OP_LH      = ;
    localparam OP_LW      = ;

    localparam OP_SB      = ;
    localparam OP_SH      = ;
    localparam OP_SW      = ;
  
  always @* begin
        ALUSrc  = 0;
        RegDst  = 0;
        MemRead = 0;
        MemWrite = 0;
        OPCode  =  instruction[31:26];
        MemtoReg = 0;
        RegWrite = 0;
        Branch = 0;
    
    case(OPCode) 
    OP_RTYPE: begin   //add, sub, mul, and, or, nor, xor, sll, srl, slt, jr
    RegDst <= 1;
    ALUSrc <= 0;
    MemtoReg <= 0
    RegWrite <= 1;
    end

    OP_LB, OP_LH, OP_LW: begin
    // load rt with val of ??  Rt <- Memory
      RegDst <= 0;
      ALUSrc <= 1;
      MemtoReg <= 0;
      MemRead <= 1;
      RegWrite <= 1;
    end
    OP_SB, OP_SH, OP_SW: begin
      // Memory[imm] <- Rt
    MemWrite <= 1;
    ALUSrc <= 1;
    
    OP_ADDI, OP_SLTI, OP_ANDI, OP_ORI, OP_XORI: begin
   //   rt <- rd + imm
    ALUSrc <= 1;
    RegWrite <=1;
  
    end
      OP_BEQ, OP_BNE: begin
  // PCIntruction = imm if rt = rd
    ALUSrc <= 0;  //compare RS to RT
    Branch <=1;

    end
      OP_BLEZ, OP_BGTZ: begin
                ALUSrc   = 1'b0;   // compare rs vs 0 (handled in ALU control)
                Branch   = 1'b1;
            end
      OP_J: begin
      Jump <= 1;
      end
      OP_JAL: begin
      Jump <= 1;
      RegWrite <= 1;
      MemtoReg <= 0;  //Write back needs to have PC+4 mux
        

      end
    
      

      endcase

  end
