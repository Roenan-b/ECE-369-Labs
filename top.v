`timescale 1ns / 1ps



module top (Clk, Reset, NumberA, NumberB);
input Clk;
input Reset; //BTNU is Reset
//output [0:0] LED; //LED[0] is done
output NumberA, NumberB, out7, en_out; //segment a, b, ... g
//output [7:0] AN; //enable each digit of the 8 digits
//write your code to connect the modules as shown in Figure 1 (page 3)
wire ClkOut;
wire Instruction, PCResult;
  
ClkDiv a1(Clk, 1'b0, ClkOut);
InstructionFetchUnit a2(Instruction, PCResult, Reset, Clk);
  Two4DigitDisplay a4(Clk, NumberA, NumberB, out7, en_out);


endmodule
