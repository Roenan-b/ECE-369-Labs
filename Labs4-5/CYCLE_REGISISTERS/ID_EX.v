`timescale 1ns / 1ps


module RegisterID_EX( ALUSrc, RegDst, OPCode, MemRead, MemWrite, 
MemtoReg, RegWrite, Branch,Jump,Clk); 


//EX Variables
input ALUSrcIn;
  input [5:0] ALUopIn;
input RegDstIn;
output reg ALUSrcOut;
  output reg [5:0]ALUopOut;
output reg RegDstOut;

//MEM VARIABLES
input

output reg BranchOut;
output MemWriteOut;
output MemReadOut;

//WRITEBACK VARAIABLE
  input MemToRegIn;
  input RegWriteOut;
  output reg MemToRegOut;
  output reg RegWrite;
  
//DataVariables for EX Stage
  input [4:0] ReadData1In;
  input [4:0] ReadData2In;
  
  input [31:0] PCAddResultIn;
  input [31:0] signResultIn; //SIGN EXTEND OUTPUT

  input [4:0] RTRegdestIn;
  input [4:0] RDRegdestIn;
  

  output reg [4:0] ReadData1Out;
  output reg [4:0] ReadData2Out;
  
  output reg [31:0] PCAddResultOut;
  output reg [31:0] signResultOut;  

  output reg [4:0] RTRegdestOut;
  output reg [4:0] RDRegdestOut;

  //Register Logic
  always @(posedge Clk) begin



    
  end
       endmodule
                     
