`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 
// 
// Team Members: Roenan Bingle, Evan Harris, Noah Monroe
// % Effort    :   33%         |     33%    |     33% 
//
// Module - SignExtension.v
// Description - Sign extension module.
////////////////////////////////////////////////////////////////////////////////
module SignExtension(in, out);

    /* A 16-Bit input word */
    input [15:0] in;
    
    /* A 32-Bit output word */
    output [31:0] out;
    
    /* Fill in the implementation here ... */

    assign out = {{16{in[15]}}, in};

endmodule


