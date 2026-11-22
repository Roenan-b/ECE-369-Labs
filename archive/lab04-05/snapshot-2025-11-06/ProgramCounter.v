`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 1
// Module - pc_register.v
// Description - 32-Bit program counter (PC) register.
//
// INPUTS:-
// Address: 32-Bit address input port.
// Reset: 1-Bit input control signal.
// Clk: 1-Bit input clock signal.
//
// OUTPUTS:-
// PCResult: 32-Bit registered output port.
//
// FUNCTIONALITY:-
// Design a program counter register that holds the current address of the 
// instruction memory. This module should be updated at the positive edge of 
// the clock. The contents of a register default to unknown values or 'X' upon 
// instantiation in your module.  
// You need to enable global reset of your datapath to point 
// to the first instruction in your instruction memory (i.e., the first address 
// location, 0x00000000H).
////////////////////////////////////////////////////////////////////////////////

module ProgramCounter(Address, PCResult, Reset, Clk);

	input [31:0] Address;	    // 32-bit input carrying the "next PC" value (e.g., PC + 4)
	input Reset, Clk;		    // Reset = async control to clear PC to 0; Clk = clock signal
	//input [31:0] PCAddResult;	// Unused input (likely for PC + 4 in other designs)
	output reg [31:0] PCResult;	// 32-bit register output that stores the current PC value
	
 // Always block triggered on the rising edge of the clock
	always @ (posedge Clk or posedge Reset) begin
    if (Reset == 1) begin
       PCResult <= 0;           // If Reset is asserted, set PC to 0 (start of instruction memory)
    end
	 else 
		 PCResult <= Address;   // Otherwise, update PCResult with the incoming Address (next PC)
 end
endmodule
