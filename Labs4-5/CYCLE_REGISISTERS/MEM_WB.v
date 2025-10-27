`timescale 1ns / 1ps


module MEM_WB(ReadDataIn, ReadDataOut, ALUResultIn, ALUResultOut, MemtoRegIn, MemtoRegOut, RegWriteIn, RegWriteOut, Clk);
  input Clk;
  input [31:0] ALUResultIn;
  input [31:0] ReadDataIn;

  //Controller Signals Inputs
  input MemtoRegIn;
  input RegWriteIn;

  output reg [31:0] ALUResultOut;
  output reg [31:0] ReadDataOut;

  //Controller Signals Outputs
  output reg MemtoRegOut;
  output reg RegWriteOut;
  
  always @(posedge Clk) begin
    ALUResultOut <= ALUResultIn;
    ReadDataOut <= ReadDataIn;
    MemtoRegOut <= MemtoRegIn;
    RegWriteOut <= RegWriteIn;
  end

endmodule
  
