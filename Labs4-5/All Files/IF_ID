`timescale 1ns / 1ps



module RegisterIF_ID(PCAddResult,instructionReadIn,PCAddResultOut,instructionReadOut,Clk, Reset);
input Clk;
input Reset;
input [31:0]  PCAddResult;
  input [31:0] instructionReadIn;
  output reg [31:0]instructionReadOut;
  output reg [31:0] PCAddResultOut;

    always @(posedge Clk) begin
      if(Reset) begin
        instructionReadOut <= 32'b0;
        PCAddResultOut <= 32'b0;
      end else begin
    
  instructionReadOut <= instructionReadIn;
  PCAddResultOut <= PCAddResult;
    end
    end


    endmodule
      
