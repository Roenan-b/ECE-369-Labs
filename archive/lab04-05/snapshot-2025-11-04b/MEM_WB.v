`timescale 1ns / 1ps


module MEM_WB(ReadDataIn, ReadDataOut, ALUResultIn, ALUResultOut, MemtoRegIn, MemtoRegOut, RegWriteIn, RegWriteOut, Clk, Reset, WriteRegOut, WriteRegIn);
  input Clk;
  input Reset;
  input [31:0] ALUResultIn;
  input [31:0] ReadDataIn;

  //Controller Signals Inputs
  input MemtoRegIn;
  input RegWriteIn;
  input[4:0] WriteRegIn;

  output reg [31:0] ALUResultOut;
  output reg [31:0] ReadDataOut;

  //Controller Signals Outputs
  output reg MemtoRegOut;
  output reg RegWriteOut;
  output reg [4:0] WriteRegOut;
  
  always @(posedge Clk) begin
    if(Reset) begin
        ALUResultOut <= 32'b0;
        ReadDataOut <= 32'b0;
        MemtoRegOut <= 1'b0;
        RegWriteOut <= 1'b0;
     end else begin
    ALUResultOut <= ALUResultIn;
    ReadDataOut <= ReadDataIn;
    MemtoRegOut <= MemtoRegIn;
    RegWriteOut <= RegWriteIn;
    WriteRegOut <= WriteRegIn;
  end
  end

endmodule
  
