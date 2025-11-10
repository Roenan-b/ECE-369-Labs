`timescale 1ns / 1ps


module MEM_WB(ReadDataIn, ReadDataOut, ALUResultIn, ALUResultOut, MemtoRegIn, MemtoRegOut, RegWriteIn, RegWriteOut, Clk, Reset, WriteRegOut, WriteRegIn,PCResultIn,
PCResultOut, BranchTakenIn, BranchTakenOut);
  input Clk;
  input Reset;
  input [31:0] ALUResultIn;
  input [31:0] ReadDataIn;
  input [31:0] PCResultIn;
  //Controller Signals Inputs
  input [1:0] MemtoRegIn;
  input RegWriteIn;
  input[4:0] WriteRegIn;
  input BranchTakenIn;

  output reg [31:0] ALUResultOut;
  output reg [31:0] ReadDataOut;
  output reg [31:0] PCResultOut;
  //Controller Signals Outputs
  output reg [1:0] MemtoRegOut;
  output reg RegWriteOut;
  output reg [4:0] WriteRegOut;
  output BranchTakenOut;
  
  reg BranchTaken_q;
  
  always @(posedge Clk) begin
    if(Reset) begin
        ALUResultOut <= 32'b0;
        ReadDataOut <= 32'b0;
        MemtoRegOut <= 2'b00;
        RegWriteOut <= 1'b0;
        BranchTaken_q <= 1'b0;
     end else begin
    ALUResultOut <= ALUResultIn;
    ReadDataOut <= ReadDataIn;
    MemtoRegOut <= MemtoRegIn;
    RegWriteOut <= RegWriteIn;
    WriteRegOut <= WriteRegIn;
    PCResultOut <= PCResultIn;
    BranchTaken_q <= BranchTakenIn;
  end
  end
  assign BranchTakenOut = BranchTaken_q;

endmodule
  
