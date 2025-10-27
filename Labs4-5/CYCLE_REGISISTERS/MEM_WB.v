`timescale 1ns / 1ps


module MEM_WB(ReadDataIn, ReadDataOut, ALUResultIn, ALUResultOut, MemtoRegIn, MemtoRegOut, PCSrcIn, PCSrcOut, Clk);
  input Clk;
  input [31:0] ALUResultIn;
  input [31:0] ReadDataIn;
  input MemtoRegIn;
  input PCSrcIn;
  
  always @(posedge Clk) begin
    ALUResultOut <= ALUResultIn;
    ReadDataOut <= ReadDataIn;
    MemtoRegOut <= MemtoRegIn;
    PCSrcOut <= PCSrcIn;
  end

endmodule
  
