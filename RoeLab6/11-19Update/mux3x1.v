`timescale 1ns / 1ps
 


//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
module mux3x1(
  output reg [31:0] out,
  input  [31:0] inA,   // 00: ALU
  input  [31:0] inB,   // 01: MEM
  input  [31:0] inC,   // 10: PC+4
  input  [1:0]  sel
);
  always @(*) begin
    case (sel)
      2'b00: out = inA;
      2'b01: out = inB;
      2'b10: out = inC;
      default: out = inA; // safe default
    endcase
  end
endmodule
