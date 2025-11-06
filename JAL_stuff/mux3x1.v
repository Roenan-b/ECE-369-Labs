// ECE369 - Computer Architecture
// 
// Team Members: Roenan Bingle, Evan Harris, Noah Monroe
// % Effort    :   33%         |     33%    |     33% 
//
// Module - Mux32Bit2To1.v
// Description - Performs signal multiplexing between 2 32-Bit words.
////////////////////////////////////////////////////////////////////////////////

module mux3x1(out, inA, inB,inC, sel);

    output reg [31:0] out;
    
    input [31:0] inA;
    input [31:0] inB;
    input [31:0] inC;
    input [1:0] sel;

    /* Fill in the implementation here ... */ 
    
    always @(*)
    begin
    if (sel == 1)
	out <= inB;
    else if (sel == 0)
	out <= inA;
    else if (sel ==2) out <=inC;
else 
    out <=inA;
    end

endmodule
