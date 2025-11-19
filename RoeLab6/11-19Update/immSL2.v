`timescale 1ns / 1ps

 

//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
module immSL2(in, out);

  input [31:0] in;
  output reg [31:0] out;

  always @(*) begin
    out <= in << 2;
  end
endmodule
