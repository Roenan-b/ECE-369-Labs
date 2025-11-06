`timescale 1ns / 1ps

module EX_MEM(AddResultIn, AddResultOut, ALUResultIn, ALUResultOut, MuxIn, MuxOut, ReadData2In, ReadData2Out, ZeroIn, ZeroOut,
              MemWriteIn, MemWriteOut, MemReadIn, MemReadOut, BranchIn, BranchOut, MemtoRegIn, MemtoRegOut, RegWriteIn, RegWriteOut, Clk, Reset, WriteRegOut, WriteRegIn,
PCAddResultIn,PCAddResultOut);

  input Clk;
  input Reset;
  input [31:0] AddResultIn;
  input [31:0] ALUResultIn;
  input [4:0] MuxIn;
  input [31:0] ReadData2In;
  input [31:0] PCAddResultIn;
  //Controller Signals Inputs
  input ZeroIn;
  input MemWriteIn;
  input MemReadIn;
  input BranchIn;
  input [1:0] MemtoRegIn;
  input RegWriteIn;
  input [4:0] WriteRegIn;
  

  output reg [31:0] AddResultOut;
  output reg [31:0] ALUResultOut;
  output reg [4:0] MuxOut;
  output reg [31:0] ReadData2Out;
  output reg [31:0] PCAddResultOut;
  //Controller Signals Outputs
  output reg ZeroOut;
  output reg MemWriteOut;
  output reg MemReadOut;
  output reg BranchOut;
  output reg [1:0] MemtoRegOut;
  output reg RegWriteOut;
  output reg [4:0] WriteRegOut;

  always @(posedge Clk) begin
    if(Reset) begin
    ZeroOut <= 1'b0;
    MemWriteOut <= 1'b0;
    MemReadOut <= 1'b0;
    BranchOut <= 1'b0;
    MemtoRegOut <= 2'b00;
    RegWriteOut <= 1'b0;
    end else begin
    
    AddResultOut <= AddResultIn;
    ALUResultOut <= ALUResultIn;
    MuxOut <= MuxIn;
    ReadData2Out <= ReadData2In;
    ZeroOut <= ZeroIn;
    MemWriteOut <= MemWriteIn;
    MemReadOut <= MemReadIn;
    BranchOut <= BranchIn;
    MemtoRegOut <= MemtoRegIn;
    RegWriteOut <= RegWriteIn;
    WriteRegOut <= WriteRegIn;
    PCAddResultOut <= PCAddResultIn;
  end
  end
endmodule
  
