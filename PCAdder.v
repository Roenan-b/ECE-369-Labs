`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory  
// Module - PCAdder.v
// Description - 32-Bit program counter (PC) adder.
// 
// INPUTS:-
// PCResult: 32-Bit input port.
// 
// OUTPUTS:-
// PCAddResult: 32-Bit output port.
//
// FUNCTIONALITY:-
// Design an incrementor (or a hard-wired ADD ALU whose first input is from the 
// PC, and whose second input is a hard-wired 4) that computes the current 
// PC + 4. The result should always be an increment of the signal 'PCResult' by 
// 4 (i.e., PCAddResult = PCResult + 4).
////////////////////////////////////////////////////////////////////////////////

module ProgramCounter(Address, PCResult, Reset, Clk);

	input [31:0] Address;	    // 32-bit input carrying the "next PC" value (e.g., PC + 4)
	input Reset, Clk;		    // Reset = async control to clear PC to 0; Clk = clock signal
	//input [31:0] PCAddResult;	// Unused input (likely for PC + 4 in other designs)
	output reg [31:0] PCResult;	// 32-bit register output that stores the current PC value
	
 // Always block triggered on the rising edge of the clock
 always @ (posedge Clk) begin
    if (Reset == 1) begin
       PCResult <= 0;           // If Reset is asserted, set PC to 0 (start of instruction memory)
    end
	 else 
		 PCResult <= Address;   // Otherwise, update PCResult with the incoming Address (next PC)
 end
endmodule
