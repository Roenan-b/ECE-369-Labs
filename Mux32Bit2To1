`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module Mux32Bit2To1(out, inA, inB, sel);

    output reg [31:0] out;
    
    input [31:0] inA;
    input [31:0] inB;
    input sel;

    always @(*) begin
        case (sel)
            1'b0: out = inA;   // if sel = 0, choose inA
            1'b1: out = inB;   // if sel = 1, choose inB
            default: out = 32'hXXXXXXXX; // safety fallback
        endcase
    end

endmodule
