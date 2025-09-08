`timescale 1ns / 1ps



module top (Clk, BTNU, LED, first, CB, CC, CD, CE, CF, CG, AN);
input Clk;
input BTNU; //BTNU is Reset
output [0:0] LED; //LED[0] is done
output CA, CB, CC, CD, CE, CF, CG; //segment a, b, ... g
output [7:0] AN; //enable each digit of the 8 digits
//write your code to connect the modules as shown in Figure 1 (page 3)
wire ClkOut;
  ClkDiv a1(Clk, 1'b0, ClkOut);
wire [7:0] R_Data, max;
wire [7:0] D;
Two4DigitDisplay a4(CLK100MHZ, D[6:0], CA,CB,CC,CD,CE,CF,CG,AN);


endmodule
