`timescale 1ns / 1ps


module RegisterID_EX(ALUSrcIn,ALUopIn,RegDstIn,ALUSrcOut,ALUopOut,RegDstOut,BranchIn,MemWriteIn,MemReadIn,
                     BranchOut,MemWriteOut,MemReadOut,MemToRegIn,RegWriteIn,MemToRegOut,RegWriteOut,
                     ReadData1In,ReadData2In,PCAddResultIn,signResultIn,RTRegdestIn,RDRegdestIn,
                     ReadData1Out,ReadData2Out,PCAddResultOut,signResultOut,RTRegdestOut,
                     RDRegdestOut);

input Clk;
//EX Variables
input ALUSrcIn;
input [5:0] ALUopIn;
input RegDstIn;
  
output reg ALUSrcOut;
output reg [5:0]ALUopOut;
output reg RegDstOut;

//MEM VARIABLES
input BranchIn;
input MemWriteIn;
input MemReadIn;

output reg BranchOut;
output reg MemWriteOut;
output reg MemReadOut;

//WRITEBACK VARAIABLE
  input MemToRegIn;
  input RegWriteIn;
  output reg MemToRegOut;
  output reg RegWriteOut;
  
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
    //EX
    ALUSrcOut <= ALUSrcIn;
    ALUopOut <= ALUopIn;
    RegDstOut <= RegDstIn;
    //Mem
    BranchOut <= BranchIn;
    MemWriteOut <= MemWriteIn;
    MemReadOut <= MemReadOut;
    //WB
    MemToRegOut <= MemToRegIn;
    RegWriteOut <= RegWriteIn;
    //VARS 
    ReadData1Out <= ReadData1In;
    ReadData2Out <= ReadData2In;
  
    PCAddResultOut <= PCAddResultIn;
    signResultOut <= signResultIn;  

    RTRegdestOut <= RTRegdestIn;
    RDRegdestOut <= RDRegdestIn;

    
  end
       endmodule
                     
