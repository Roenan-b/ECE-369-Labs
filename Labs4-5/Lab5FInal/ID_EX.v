`timescale 1ns / 1ps


//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%

module RegisterID_EX(Clk,Reset, ALUSrcIn,ALUopIn,RegDstIn,ALUSrcOut,ALUopOut,RegDstOut,BranchIn,MemWriteIn,MemReadIn,
                     BranchOut,MemWriteOut,MemReadOut,MemtoRegIn,RegWriteIn,MemtoRegOut,RegWriteOut,
                     ReadData1In,ReadData2In,PCAddResultIn,signResultIn,RTRegdestIn,RDRegdestIn,
                     ReadData1Out,ReadData2Out,PCAddResultOut,signResultOut,RTRegdestOut,
                     RDRegdestOut, UseShamtOut,UseShamtIn, shamtIn, shamtOut, RegDstSelIn,RegDstSelOut, MemSizeIn, MemUnsignedIn, MemSizeOut, MemUnsignedOut);

input Clk;
input Reset;
//EX Variables
input ALUSrcIn;
input [5:0] ALUopIn;
input [1:0] RegDstIn;
input UseShamtIn;
input[4:0] shamtIn;
input[1:0] MemSizeIn;
input MemUnsignedIn;
  
output reg ALUSrcOut;
output reg [5:0]ALUopOut;
output reg[1:0] RegDstOut;
output reg UseShamtOut;
output reg[4:0] shamtOut;

//MEM VARIABLES
input BranchIn;
input MemWriteIn;
input MemReadIn;

output reg BranchOut;
output reg MemWriteOut;
output reg MemReadOut;

//WRITEBACK VARAIABLE
  input [1:0] MemtoRegIn;
  input RegWriteIn;
  output reg [1:0] MemtoRegOut;
  output reg RegWriteOut;
  
//DataVariables for EX Stage
  input [31:0] ReadData1In;
  input [31:0] ReadData2In;
  
  input [31:0] PCAddResultIn;
  input [31:0] signResultIn; //SIGN EXTEND OUTPUT

  input [4:0] RTRegdestIn;
  input [4:0] RDRegdestIn;
  

  output reg [31:0] ReadData1Out;
  output reg [31:0] ReadData2Out;
  
  output reg [31:0] PCAddResultOut;
  output reg [31:0] signResultOut;  

  output reg [4:0] RTRegdestOut;
  output reg [4:0] RDRegdestOut;
  
  output reg [1:0] MemSizeOut;
  output reg       MemUnsignedOut;
  

    input      [1:0] RegDstSelIn;
    output reg [1:0] RegDstSelOut;


  //Register Logic
  always @(posedge Clk) begin
    if (Reset) begin
    ALUSrcOut <= 1'b0;
    ALUopOut <= 6'b000000;
    RegDstOut <= 2'b00;
    BranchOut <= 1'b0;
    MemWriteOut <= 1'b0;
    MemReadOut <= 1'b0;
    MemtoRegOut <= 2'b00;
    RegWriteOut <= 1'b0;
    UseShamtOut <= 1'b0;
    shamtOut    <= 5'b00000;
    RegDstSelOut <= 2'b00;
    MemSizeOut <= 2'b10;
    MemUnsignedOut <= 1'b0;
  end else begin
  
    //EX
    ALUSrcOut <= ALUSrcIn;
    ALUopOut <= ALUopIn;
    RegDstOut <= RegDstIn;
    UseShamtOut <= UseShamtIn;
    shamtOut <= shamtIn;
    //Mem
    BranchOut <= BranchIn;
    MemWriteOut <= MemWriteIn;
    MemReadOut <= MemReadIn;
    //WB
    MemtoRegOut <= MemtoRegIn;
    RegWriteOut <= RegWriteIn;
    //VARS 
    ReadData1Out <= ReadData1In;
    ReadData2Out <= ReadData2In;
  
    PCAddResultOut <= PCAddResultIn;
    signResultOut <= signResultIn;  

    RTRegdestOut <= RTRegdestIn;
    RDRegdestOut <= RDRegdestIn;
    
    RegDstSelOut <= RegDstSelIn;
    
    MemSizeOut <= MemSizeIn;
    MemUnsignedOut <= MemUnsignedIn;
    
    $display("[%0t] IDEX : MemSizeOut=%b UnsOut=%b",
         $time, MemSizeOut, MemUnsignedOut);


    end
  end
       endmodule
                     
