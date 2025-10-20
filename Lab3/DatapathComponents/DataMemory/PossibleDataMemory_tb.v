`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
//
// Team Members: Roenan Bingle, Evan Harris, Noah Monroe
// % Effort    :   33%         |     33%    |     33% 
//
// Module - DataMemory_tb.v
// Description - Test the 'DataMemory.v' module.
////////////////////////////////////////////////////////////////////////////////

module DataMemory_tb(); 

    reg     [31:0]  Address;
    reg     [31:0]  WriteData;
    reg             Clk;
    reg             MemWrite;
    reg             MemRead;

    wire [31:0] ReadData;

    DataMemory u0(
        .Address(Address), 
        .WriteData(WriteData), 
        .Clk(Clk), 
        .MemWrite(MemWrite), 
        .MemRead(MemRead), 
        .ReadData(ReadData)
    ); 

    // Clock generation (20ns period)
    initial begin
        Clk = 1'b0;
        forever #10 Clk = ~Clk;
    end

    initial begin
        // Initialize signals
        Address   = 32'h0;
        WriteData = 32'h0;
        MemWrite  = 1'b0;
        MemRead   = 1'b0;

        // Wait a few cycles before starting
        #20;

        // --- Write cycle 1 ---
        Address   = 32'h0000_0000;
        WriteData = 32'hDEAD_BEEF;
        MemWrite  = 1'b1;
        MemRead   = 1'b0;
        @(posedge Clk);   // perform write on posedge
        @(negedge Clk);
        MemWrite  = 1'b0;

        // --- Read cycle 1 ---
        Address   = 32'h0000_0000;
        MemRead   = 1'b1;
        @(negedge Clk);
        MemRead   = 1'b0;

        // --- Write cycle 2 ---
        Address   = 32'h0000_0004;
        WriteData = 32'hCAFEBABE;
        MemWrite  = 1'b1;
        @(posedge Clk);
        @(negedge Clk);
        MemWrite  = 1'b0;

        // --- Read cycle 2 ---
        Address   = 32'h0000_0004;
        MemRead   = 1'b1;
        @(negedge Clk);
        MemRead   = 1'b0;

        // --- Write cycle 3 ---
        Address   = 32'h0000_0010;
        WriteData = 32'h1234_ABCD;
        MemWrite  = 1'b1;
        @(posedge Clk);
        @(negedge Clk);
        MemWrite  = 1'b0;

        // --- Read cycle 3 ---
        Address   = 32'h0000_0010;
        MemRead   = 1'b1;
        @(negedge Clk);
        MemRead   = 1'b0;

        // --- Test another address (for different word index) ---
        Address   = 32'h0000_1040;
        WriteData = 32'h1111_2222;
        MemWrite  = 1'b1;
        @(posedge Clk);
        @(negedge Clk);
        MemWrite  = 1'b0;

        // --- Read that address ---
        Address   = 32'h0000_1040;
        MemRead   = 1'b1;
        @(negedge Clk);
        MemRead   = 1'b0;

        // End simulation after all operations
        #50;
        $finish;
    end

endmodule
