`timescale 1ns / 1ps   // Simulation time unit = 1 ns, time precision = 1 ps



module top (Clk, Reset, out7, en_out);
input Clk;                    // System clock input (board clock)
input Reset;                  // Active-high reset (BTNU per your note)
//output [0:0] LED;           // Unused: could be used as a "done" indicator
output [6:0]out7;            // Seven-seg segment lines: {a,b,c,d,e,f,g}
output [7:0]en_out;          // Seven-seg digit enables for 8 digits (active-low on many boards)
//output [7:0] AN;            // Unused: alternative naming for digit enables
//write your code to connect the modules as shown in Figure 1 (page 3)

wire ClkOut;                  // Divided/derived clock for synchronous subsystems
wire [31:0]Instruction;       // 32-bit instruction fetched from instruction memory (IFU output)
wire[31:0]PCResult;           // 32-bit Program Counter value (IFU output)
wire [15:0]NumberA;           // Lower 16 bits of Instruction to display on one 4-digit pair
wire [15:0]NumberB;           // Lower 16 bits of PCResult to display on the other 4-digit pair
  
// Clock divider: takes board Clk and an (unused) reset input '1'b0', produces slower ClkOut for the IFU/display
ClkDiv a1(Clk, 1'b0, ClkOut);

// Instruction Fetch Unit: on Reset and rising edges of ClkOut, updates PCResult and fetches Instruction
InstructionFetchUnit a2(Instruction, PCResult, Reset, ClkOut);

// Break out the low halves for display (hex nibbles -> seven-seg handled downstream)
assign NumberA = Instruction[15:0];  // Show low 16 bits of the current instruction
assign NumberB = PCResult[15:0];     // Show low 16 bits of the current PC

// Dual 4-digit seven-seg driver: time-multiplexed output of NumberA and NumberB onto out7/en_out
Two4DigitDisplay a4(Clk, NumberA, NumberB, out7, en_out);

endmodule
