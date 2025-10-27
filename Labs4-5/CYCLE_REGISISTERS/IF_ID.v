`timescale 1ns / 1ps



module RegisterIF_ID(PCinstructionPlus4,instructionReadIn,instructionReadOut,Clk);
input Clk;
input [31:0]  PCinstructionPlus4;
  input [31:0] instructionReadIn;
  output [31:0]instructionReadOut;

    always @(posedge Clk) begin
    
  instructionReadOut = instructionReadIn;
    end


    endmodule
      
