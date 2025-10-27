`timescale 1ns / 1ps

module EX_MEM(AddResultIn, AddResultOut, ALUResultIn, ALUResultOut, MuxIn, MuxOut, ReadData2In, ReadData2Out, ZeroIn, ZeroOut,
              MemWriteIn, MemWriteOut, MemReadIn, MemReadOut, BranchIn, BranchOut, MemtoRegIn, MemtoRegOut, RegWriteIn, RegWriteOut, Clk);

  input Clk;
  input [31:0] AddResultIn;
  input [31:0] ALUResultIn;
  input [4:0] MuxIn;
  input [31:0] ReadData2In;
  input ZeroIn;
  input MemWriteIn;
  input MemReadIn;
  input BranchIn;
  input MemtoRegIn;
  input RegWriteIn;

  output reg [31:0] AddResultOut;
  output reg [31:0] ALUResultOut;
  output reg [4:0] MuxOut;
  output reg [31:0] ReadData2Out;
  output reg ZeroOut;
  output reg MemWriteOut;
  output reg MemReadOut;
  output reg BranchOut;
  output reg MemtoRegOut;
  output reg RegWriteOut;

  always @(posedge Clk) begin
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
  end
endmodule
  
