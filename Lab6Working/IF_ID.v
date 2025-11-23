`timescale 1ns / 1ps
 
//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%

module RegisterIF_ID(
    input             Clk,
    input             Reset,
    input             WriteEnable,        // from HazardDetection: IF_ID_Write
    input             Flush,              // from HazardDetection: IF_Flush

    input      [31:0] PCAddResult,
    input      [31:0] instructionReadIn,

    output reg [31:0] PCAddResultOut,
    output reg [31:0] instructionReadOut
);

    always @(posedge Clk) begin
        if (Reset || Flush) begin
            // On reset or flush, nuke the instruction in IF/ID
            instructionReadOut <= 32'b0;
            PCAddResultOut     <= 32'b0;
        end else if (WriteEnable) begin
            // Normal pipeline advance
            instructionReadOut <= instructionReadIn;
            PCAddResultOut     <= PCAddResult;
        end else begin
            // Stall: hold previous values
            instructionReadOut <= instructionReadOut;
            PCAddResultOut     <= PCAddResultOut;
        end
    end

endmodule
