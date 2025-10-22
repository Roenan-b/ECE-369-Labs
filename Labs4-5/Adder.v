module Adder(PCAddResult, immSL2, InstructionSig);

    input [31:0] immSL2;         
    input [31:0] PCAddResult;
    output reg [31:0] InstructionSig;

    // Always block triggers whenever PCResult changes
  always @ (*) begin
        InstructionSig <= PCAddResult + innSL2; // Increment the PC by 4 (word-aligned instruction step)
    end
  
endmodule
