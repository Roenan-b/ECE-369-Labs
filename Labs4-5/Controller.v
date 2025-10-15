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
  
 // wire [5:0] opcode = instruction[31:26];
    // wire [4:0] rs     = instruction[25:21];
    // wire [4:0] rt     = instruction[20:16];
    // wire [4:0] rd     = instruction[15:11];
    // wire [5:0] funct  = instruction[5:0];
    localparam OP_RTYPE = 6'b000000;
    localparam OP_LW    = 6'b100011; // 35
    localparam OP_SW    = 6'b101011; // 43
    localparam OP_BEQ   = 6'b000100; // 4
    localparam OP_ADDI  = 6'b001000; // 8
    localparam OP_ORI   = 6'b001101; // 13

  
  always @* begin
        ALUSrc  = 0;
        RegDst  = 0;
        MemRead = 0;
        MemWrite = 0;
        OPCode  =  instruction[31:26];
        MemtoReg = 0;
        RegWrite = 0;
        Branch = 1;
    case(OPCode) 
    OP_RTYPE: begin

    end

    OP_LW: begin
    // load rt with val of ??  Rt <- Memory
      RegDst = 0;
      ALUSrc = 1;
      MemtoReg = 0;
      MemRead = 1;
      RegWrite =1;
    end
    OP_SW: begin
      // Memory[imm] <- Rt
    MemWrite = 1;
    ALUSrc = 1;
    
    OP_ADDI: begin
   //   rt <- rd + imm
    ALUSrc = 1;
    RegWrite =1;
  
    end
    OP_BEQ: begin
  // PCIntruction = imm if rt = rd
    ALUSrc = 1;
    Branch =1;

    end
    end
      

      endcase

  end
