`timescale 1ns / 1ps

//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 1
// Module - pc_register.v
// Description - 32-Bit program counter (PC) register with write enable.
//
// INPUTS:-
// Address: 32-Bit address input port.
// Reset: 1-Bit input control signal.
// Clk: 1-Bit input clock signal.
// PCWrite: 1-Bit input control signal to allow stalling the PC.
//
// OUTPUTS:-
// PCResult: 32-Bit registered output port.
////////////////////////////////////////////////////////////////////////////////

module ProgramCounter(
    input  [31:0] Address,     // next PC
    input         Reset,       // global reset
    input         Clk,         // clock
    input         PCWrite,     // NEW: gate PC updates (from HazardDetection)
    output reg [31:0] PCResult // current PC
);

    // Update PC on rising edge
    always @ (posedge Clk) begin
        if (Reset) begin
            // On reset, point to first instruction
            PCResult <= 32'b0;
        end
        else if (PCWrite) begin
            // Normal update when not stalled
            PCResult <= Address;
        end
        else begin
            // Stall: hold current PC
            PCResult <= PCResult;
        end
    end

endmodule
