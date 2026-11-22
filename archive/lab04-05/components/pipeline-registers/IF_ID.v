`timescale 1ns / 1ps



module RegisterIF_ID(PCAddResult,instructionReadIn,PCAddResultOut,instructionReadOut,Clk);
input Clk;
input [31:0]  PCAddResult;
  input [31:0] instructionReadIn;
  output [31:0]instructionReadOut;
  output [31:0] PCAddResultOut;

    always @(posedge Clk) begin
    
  instructionReadOut <= instructionReadIn;
  PCAddResultOut <= PCAddResult;
    end


    endmodule
      
