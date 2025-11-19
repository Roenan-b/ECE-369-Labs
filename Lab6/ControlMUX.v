`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Team Members: Roenan Bingle, Evan Harris, Noah Monroe
// % Effort    :   33%         |     33%    |     33% 
//
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module ControllerMux(

   // output reg [31:0] out;
  input sel,
  input inALUSrc,
  input [1:0] inRegDstSel,
  input [5:0] inALUControl,
  input inMemRead,
  input inMemWrite,
  input [1:0] inWBSource,
  input inRegWrite,
  input inBranch,
  input inJump,
  input inJumpReg,
  input inExtZero,
  input inUseShamt,
  input [1:0] inMemSize,
  input inMemUnsigned;,

  output reg outALUSRC,
  output reg [1:0] outRegDstSel,
  output reg [5:0] outALUControl,
  output reg outMemRead,
  output reg outMemWrite,
  output reg [1:0] outWBSource,
  output reg outRegWrite,
  output reg        outBranch,
  output reg        outJump,
  output reg        outJumpReg,     // jr
  output reg        outExtZero,     // immed: 1=zero-extend; 0=sign-extend
  output reg        outUseShamt,     // shifts: A=shamt
  output reg [1:0] outMemSize,
  output reg outMemUnsigned
  );
  
    /* Fill in the implementation here ... */ 
    
    always @(*)
    begin
       if (sel == 1) begin

 outALUSRC <=inALUSRC;
 outRegDstSel <=inRegDstSel;
 outALUControl <=inALUControl;
 outMemRead <=inMemRead;
 outMemWrite <=inMemWrite;
 outWBSource <=inWBSource;
 outRegWrite <=inRegWrite;
 outBranch<=inBranch;
 outJump<=inJump;
 outJumpReg <=inJumpReg;
 outExtZero <=inExtZero;
 outUseShamt<=inUseShamt;
 outMemSize<=inMemSize;
 outMemUnsigned<=inMemUnsigned;


       end
    else begin
 outALUSRC <=0;
 outRegDstSel <=0;
 outALUControl <=0;
 outMemRead <=0;
 outMemWrite <=0;
 outWBSource <=0;
 outRegWrite <=0;
 outBranch<=0;
 outJump<=0;
 outJumpReg <=0;
 outExtZero <=0;
 outUseShamt<=0;
 outMemSize<=0;
 outMemUnisgned<=0;
    end
    end

endmodule

endmodule
