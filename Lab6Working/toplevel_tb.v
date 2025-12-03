`timescale 1ns / 1ps

//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
module toplevel_tb;

    // Inputs
    reg Clk;
    reg Reset;

    // Outputs
    wire [31:0] PC_out;
    wire [31:0] WB_WriteData;
    wire [31:0] v0;
    wire [31:0] v1;

    // DUT
    toplevel uut (
        .Clk       (Clk),
        .Reset     (Reset),
        .PC_out    (PC_out),
        .WB_WriteData(WB_WriteData),
        .Readv0(v0),
        .Readv1(v1)
    );

    // Clock: 10 ns period
    initial Clk = 1'b0;
    always #5 Clk = ~Clk;

    initial begin
        // Apply reset
        Reset = 1'b1;
        #20;
        Reset = 1'b0;

        // Let it run for a while
        #1000;
        $stop;
    end

endmodule
