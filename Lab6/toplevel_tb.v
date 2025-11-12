`timescale 1ns / 1ps



//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
module toplevel_tb;

    // Inputs
    reg clk;
    reg reset;
    wire [31:0] instructionWrite;
    wire [31:0] pc;
    wire RegWrite;
    wire [4:0] WriteReg;
    wire [31:0] WriteData;

    // Outputs
    //wire [31:0] instruction;
    //wire [31:0] pc;

    // Instruction memory 
    //wire [31:0] write_data;
    //wire [4:0] write_register;
    

    // Instantiate the Unit Under Test (UUT)
    toplevel uut (
        .Reset(reset),
        .Clk(clk), 
        .instructionWrite(instructionWrite),
        .PC_out(pc),
        .WB_RegWrite(RegWrite),
        .WB_WriteReg(WriteReg),
        .WB_WriteData(WriteData)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
       
        @ (posedge clk);

        // Wait for global reset to finish
        #50;
        reset = 0;

        // Add stimulus here
        #50;
    end

    always #100 clk = ~clk;

endmodule
