`timescale 1ns / 1ps

module controller(   //FIX THIS!!

  input [31:0] instruction, //Problably 32 bits
  input Clk,


  output reg ALUSrc,
  output reg RegDst,
  output reg [5:0] OPCode,  //Needs to be ?? bits
  output reg MemRead,
  output reg MemWrite,
  output reg MemtoReg,
  output reg RegWrite,
  output reg Branch,
  output reg Jump

);
  
  wire [5:0] opcode = instruction[31:26];
    // wire [4:0] rs     = instruction[25:21];
  wire [4:0] rt     = instruction[20:16]; //NEEDED FOR BLTZ AND BGEZ
    // wire [4:0] rd     = instruction[15:11];
   wire [5:0] funct  = instruction[5:0];


  //NEED TO CHANGE TO BIT ENCODINGS
    localparam OP_RTYPE   = 1; // SPECIAL
    localparam OP_REGIMM  = 2; // BLTZ/BGEZ via rt field  CHANGE THIS
    localparam OP_J       = 3;
    localparam OP_JAL     = 4;
    localparam OP_BEQ     = 5;
    localparam OP_BNE     = 6;
    localparam OP_BLEZ    = 7;
    localparam OP_BGTZ    = 8;

    localparam OP_ADDI    = 9;
    localparam OP_SLTI    = 10;
    localparam OP_ANDI    = 11;
    localparam OP_ORI     = 12;
    localparam OP_XORI    = 13;

    localparam OP_LB      = 14;
    localparam OP_LH      = 15;
    localparam OP_LW      = 16;

    localparam OP_SB      = 17;
    localparam OP_SH      = 18;
    localparam OP_SW      = 19;

    // In the following, the RT is used as an extension of op-code and it etheir 1 or 0
    localparam RT_BLTZ    = 0;
    localparam RT_BGEZ    = 1;

    //Used if doing a JR
  localparam FUNCT_JR = 8; //CHANGE VAL MAYBE?
  
  always @* begin
        ALUSrc  = 0;
        RegDst  = 0;
        MemRead = 0;
        MemWrite = 0;
        OPCode  = opcode;
        MemtoReg = 0;
        RegWrite = 0;
        Branch = 0;
        Jump =0;
    
    case(OPCode) 
    OP_RTYPE: begin   //add, sub, mul, and, or, nor, xor, sll, srl, slt, jr
      if(funct == FUNCT_JR) begin
        Jump = 1;
      end else begin
    RegDst = 1;
    ALUSrc = 0;
    MemtoReg = 0;
    RegWrite = 1;
      end
    end

    OP_LB, OP_LH, OP_LW: begin
    // load rt with val of ??  Rt <- Memory
      RegDst = 0;
      ALUSrc = 1;
      MemtoReg = 1;
      MemRead = 1;
      RegWrite = 1;
    end
    OP_SB, OP_SH, OP_SW: begin
      // Memory[imm] <- Rt
    MemWrite = 1;
    ALUSrc = 1;
    end
    
    OP_ADDI, OP_SLTI, OP_ANDI, OP_ORI, OP_XORI: begin
   //   rt <- rd + imm
    ALUSrc = 1;
    RegWrite =1;
    RegDst = 0;
    MemtoReg =0;
    end

      
      OP_BEQ, OP_BNE: begin
  // PCIntruction = imm if rt = rd
    ALUSrc = 0;  //compare RS to RT
    Branch =1;  
    end
      
      
      OP_BLTZ, OP_BGEZ: begin
        if (rt==RT_BLTZ || rt== RT_BGEZ) begin
                ALUSrc   = 0;   // compare rs vs 0 (handled in ALU control)
                Branch   = 1;
        end
      end

      OP_BLEZ, OP_BGTZ: begin
        ALUSrc =0;
        Branch = 1;
      end
      
      OP_J: begin
      Jump = 1;
      end
      
      OP_JAL: begin
      Jump = 1;
      RegWrite = 1;  //Write $ra
      MemtoReg = 0;  //Write back needs to have PC+4 mux
      end
    
      default: ;

      endcase

  end
