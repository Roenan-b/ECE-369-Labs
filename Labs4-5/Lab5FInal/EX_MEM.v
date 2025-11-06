`timescale 1ns / 1ps

module EX_MEM(
  input         Clk,
  input         Reset,

  // data / addresses
  input  [31:0] AddResultIn,
  input  [31:0] ALUResultIn,
  input  [4:0]  MuxIn,            // legacy (optional)
  input  [31:0] ReadData2In,
  input  [31:0] PCAddResultIn,

  // control in
  input         ZeroIn,
  input         MemWriteIn,
  input         MemReadIn,
  input         BranchIn,
  input  [1:0]  MemtoRegIn,
  input         RegWriteIn,
  input  [4:0]  WriteRegIn,
  input  [1:0]  MemSizeIn,
  input         MemUnsignedIn,

  // data / addresses out
  output reg [31:0] AddResultOut,
  output reg [31:0] ALUResultOut,
  output reg [4:0]  MuxOut,       // legacy (optional)
  output reg [31:0] ReadData2Out,
  output reg [31:0] PCAddResultOut,

  // control out
  output reg        ZeroOut,
  output reg        MemWriteOut,
  output reg        MemReadOut,
  output reg        BranchOut,
  output reg [1:0]  MemtoRegOut,
  output reg        RegWriteOut,
  output reg [4:0]  WriteRegOut,
  output reg [1:0]  MemSizeOut,
  output reg        MemUnsignedOut
);

  // Prefer async reset for clean startup like the other pipe regs
  always @(posedge Clk or posedge Reset) begin
    if (Reset) begin
      // data
      AddResultOut     <= 32'h0000_0000;
      ALUResultOut     <= 32'h0000_0000;
      MuxOut           <= 5'd0;
      ReadData2Out     <= 32'h0000_0000;
      PCAddResultOut   <= 32'h0000_0000;
      WriteRegOut      <= 5'd0;

      // control
      ZeroOut          <= 1'b0;
      MemWriteOut      <= 1'b0;
      MemReadOut       <= 1'b0;
      BranchOut        <= 1'b0;
      MemtoRegOut      <= 2'b00;
      RegWriteOut      <= 1'b0;

      // memory control defaults: legal & deterministic
      MemSizeOut       <= 2'b10;   // word
      MemUnsignedOut   <= 1'b0;    // signed
    end else begin
      // data
      AddResultOut     <= AddResultIn;
      ALUResultOut     <= ALUResultIn;
      MuxOut           <= MuxIn;
      ReadData2Out     <= ReadData2In;
      PCAddResultOut   <= PCAddResultIn;
      WriteRegOut      <= WriteRegIn;

      // control
      ZeroOut          <= ZeroIn;
      MemWriteOut      <= MemWriteIn;
      MemReadOut       <= MemReadIn;
      BranchOut        <= BranchIn;
      MemtoRegOut      <= MemtoRegIn;
      RegWriteOut      <= RegWriteIn;

      // memory control
      MemSizeOut       <= MemSizeIn;
      MemUnsignedOut   <= MemUnsignedIn;
    end

  end
endmodule
