`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// Team Members: Roenan Bingle, Evan Harris, Noah Monroe
// % Effort    :   33%         |     33%    |     33% 
//
// Module - RegisterFile_tb.v
// Description - Test the register_file (silent version)
////////////////////////////////////////////////////////////////////////////////

module RegisterFile_tb();

  reg  [4:0]  ReadRegister1;
  reg  [4:0]  ReadRegister2;
  reg  [4:0]  WriteRegister;
  reg  [31:0] WriteData;
  reg         RegWrite;
  reg         Clk;

  wire [31:0] ReadData1;
  wire [31:0] ReadData2;

  RegisterFile u0(
    .ReadRegister1(ReadRegister1),
    .ReadRegister2(ReadRegister2),
    .WriteRegister(WriteRegister),
    .WriteData(WriteData),
    .RegWrite(RegWrite),
    .Clk(Clk),
    .ReadData1(ReadData1),
    .ReadData2(ReadData2)
  );

  // Clock: 20ns period
  initial begin
    Clk <= 1'b0;
    forever #10 Clk <= ~Clk;
  end

  // --- Utility tasks ---
  task automatic write_reg(input [4:0] rd, input [31:0] data);
    begin
      @(negedge Clk);
      WriteRegister <= rd;
      WriteData     <= data;
      RegWrite      <= 1'b1;
      @(posedge Clk);
      @(negedge Clk);
      RegWrite      <= 1'b0;
      WriteRegister <= 5'd0;
      WriteData     <= 32'h0;
    end
  endtask

  task automatic read_pair(input [4:0] r1, input [4:0] r2);
    begin
      @(negedge Clk);
      ReadRegister1 <= r1;
      ReadRegister2 <= r2;
      @(negedge Clk);
    end
  endtask

  function automatic [31:0] pattern(input [4:0] idx);
    pattern = {24'hA5_5A_3C, idx};
  endfunction

  integer i;

  initial begin
    ReadRegister1 = 5'd0;
    ReadRegister2 = 5'd0;
    WriteRegister = 5'd0;
    WriteData     = 32'h0;
    RegWrite      = 1'b0;

    // Write registers 8..25
    for (i = 8; i <= 25; i = i + 1) begin
      write_reg(i[4:0], pattern(i[4:0]));
    end

    // Read back 2-by-2
    for (i = 8; i <= 24; i = i + 2) begin
      read_pair(i[4:0], (i+1)[4:0]);
    end

    #20;
    $stop;
  end

endmodule
