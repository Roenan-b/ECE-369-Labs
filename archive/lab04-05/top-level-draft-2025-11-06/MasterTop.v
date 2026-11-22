`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
/* Fall 2025
# Team Members:  Nick Roman, Mason Njos, Ernesto Martinez  
# % Effort    :  33.3%, 33.3%, 33.3%
*/
//////////////////////////////////////////////////////////////////////////////////


module MasterTop( Clk, Reset, out7, en_out

    );
    
    input Clk, Reset;
    output [6:0] out7;
    output [7:0] en_out;
    
    wire ClkOut;
    
    wire [31:0] pc;
    wire [31:0] regWriteData;
    
    ClkDiv u0(.Clk(Clk), .Rst(Reset), .ClkOut(ClkOut));
    
    Top_Level u1(.Clk(ClkOut), .Reset(Reset), .pc(pc), .regWriteData(regWriteData));
    
    Two4DigitDisplay u2(.Clk(Clk), .NumberA(regWriteData), .NumberB(pc), .out7(out7), .en_out(en_out));
    
endmodule
