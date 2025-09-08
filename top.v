`timescale 1ns / 1ps



module top (Clk, Reset, NumberA, NumberB);
input Clk;
input Reset; //BTNU is Reset
//output [0:0] LED; //LED[0] is done
output NumberA, NumberB; //segment a, b, ... g
//output [7:0] AN; //enable each digit of the 8 digits
//write your code to connect the modules as shown in Figure 1 (page 3)
wire ClkOut;
  ClkDiv a1(Clk, 1'b0, ClkOut);
  InstructionFetchUnit a2(
  Two4DigitDisplay a4(Clk, CA,CB,CC,CD,CE,CF,CG,AN);


endmodule
