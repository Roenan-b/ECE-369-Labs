`timescale 1ns / 1ps


module EqualGate (inputA, inputB, outSignal);
  
  input [31:0] inputA;
  input [31:0] inputB;
  output reg outSignal;



  always @(*)  begin
  if (inputA == inputB) outSignal <= 1;
  else outsignal <=0;

  end
endmodule
