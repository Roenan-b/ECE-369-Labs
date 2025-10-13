`timescale 1ns / 1ps

module controller(instruction, Clk, ALUSrc,RegDst,OPCode,MemRead,MemWrite);

  input [31:0] instruction; //Problably 32 bits
  input Clk;


  output reg ALUSrc;
  output reg RegDst;
  output reg [5:0] OPCode;  //Needs to be ?? bits
  output reg MemRead;
  output reg MemWrite;
  
 // wire [5:0] opcode = instruction[31:26];
    // wire [4:0] rs     = instruction[25:21];
    // wire [4:0] rt     = instruction[20:16];
    // wire [4:0] rd     = instruction[15:11];
    // wire [5:0] funct  = instruction[5:0];

  always @* begin
        ALUSrc    = 0;
        RegDst    = 0;
        MemRead   = 0;
        MemWrite  = 0;
        OPCode    =  instruction[31:26];
   

      endcase

  end
