`timescale 1ns/1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - ALU32Bit_tb.v
// Tests all required ops from the table.
// Assumes ALU32Bit control map defined below (must match DUT).
////////////////////////////////////////////////////////////////////////////////

module ALU32Bit_tb;

  // ---- DUT I/O ----
  reg  [4:0]  ALUControl;
  reg  [31:0] A, B;
  wire [31:0] ALUResult;
  wire        Zero;

  ALU32Bit dut (
    .ALUControl(ALUControl),
    .A(A),
    .B(B),
    .ALUResult(ALUResult),
    .Zero(Zero)
  );

  // ---- Mirror the DUT's localparams ----
  localparam ALU_AND    = 5'd0;
  localparam ALU_OR     = 5'd1;
  localparam ALU_XOR    = 5'd2;
  localparam ALU_NOR    = 5'd3;
  localparam ALU_ADD    = 5'd4;
  localparam ALU_SUB    = 5'd5;
  localparam ALU_MUL    = 5'd6;
  localparam ALU_SLT    = 5'd7;
  localparam ALU_SLL    = 5'd8;
  localparam ALU_SRL    = 5'd9;
  localparam ALU_CMPEQ  = 5'd10;
  localparam ALU_CMPNE  = 5'd11;
  localparam ALU_CMPGT0 = 5'd12;
  localparam ALU_CMPGE0 = 5'd13;
  localparam ALU_CMPLT0 = 5'd14;
  localparam ALU_CMPLE0 = 5'd15;
  localparam ALU_PASSA  = 5'd16;
  localparam ALU_PASSB  = 5'd17;

  // ---- Helper: single check ----
  task automatic check;
    input [256*8-1:0] name;  // string literal only
    input [4:0] ctrl;
    input [31:0] a, b;
    input [31:0] expect;
    reg          expectZero;
  begin
    ALUControl = ctrl; A = a; B = b;
    #1; // allow combinational settle
    expectZero = (expect == 32'd0);
    if (ALUResult !== expect) begin
      $display("FAIL %-22s: ctrl=%0d A=0x%08h B=0x%08h -> got 0x%08h exp 0x%08h",
               name, ctrl, a, b, ALUResult, expect);
      $fatal;
    end else if (Zero !== expectZero) begin
      $display("FAIL(Z) %-18s: Zero=%0b exp %0b (res=0x%08h)",
               name, Zero, expectZero, ALUResult);
      $fatal;
    end else begin
      $display("PASS %-22s: res=0x%08h Zero=%0b", name, ALUResult, Zero);
    end
  end
  endtask

  // Signed helpers for readability in TB
  function automatic [31:0] s_lt (input [31:0] a, b);
    s_lt = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
  endfunction
  function automatic [31:0] s_gt0 (input [31:0] a);
    s_gt0 = ($signed(a) > 0) ? 32'd1 : 32'd0;
  endfunction
  function automatic [31:0] s_ge0 (input [31:0] a);
    s_ge0 = ($signed(a) >= 0) ? 32'd1 : 32'd0;
  endfunction
  function automatic [31:0] s_lt0 (input [31:0] a);
    s_lt0 = ($signed(a) < 0) ? 32'd1 : 32'd0;
  endfunction
  function automatic [31:0] s_le0 (input [31:0] a);
    s_le0 = ($signed(a) <= 0) ? 32'd1 : 32'd0;
  endfunction

  initial begin
    $display("=== ALU32Bit: begin unit tests ===");

    // ---------- Arithmetic ----------
    check("ADD (add/addi)",    ALU_ADD,  32'd7,      32'd5,      32'd12);
    // address calc for loads/stores uses ADD as well:
    check("ADDR (lw/sw/lb..)", ALU_ADD,  32'h1000_0000, 32'hFFFF_FFFC, 32'h0FFF_FFFC + 32'h1); // still ADD test

    check("SUB",               ALU_SUB,  32'd15,     32'd15,     32'd0);
    check("MUL low32",         ALU_MUL,  32'd13,     32'd9,      32'd117);
    check("SLT signed",        ALU_SLT,  32'hFFFF_FFF0, 32'd5,    s_lt(32'hFFFF_FFF0, 32'd5));

    // ---------- Logical ----------
    check("AND",               ALU_AND,  32'hF0F0_F0F0, 32'h0FF0_0FF0, 32'h00F0_00F0);
    check("OR",                ALU_OR,   32'hF0F0_000F, 32'h0FF0_0FF0, 32'hFFF0_0FF0);
    check("XOR",               ALU_XOR,  32'hAAAA_5555, 32'h0F0F_F0F0, 32'hA5A5_A5A5);
    check("NOR",               ALU_NOR,  32'h0000_00FF, 32'h0000_0F00, ~32'h0000_0FFF);

    // ---------- Shifts (shamt in A[4:0], data in B) ----------
    check("SLL",               ALU_SLL,  32'd4,      32'h0000_00F1, 32'h0000_0F10);
    check("SRL",               ALU_SRL,  32'd3,      32'h8000_0010, 32'h1000_0002);

    // ---------- Branch-style compares ----------
    check("CMPEQ (beq)",       ALU_CMPEQ,32'hDEAD_BEEF, 32'hDEAD_BEEF, 32'd1);
    check("CMPNE (bne)",       ALU_CMPNE,32'd1,      32'd2,      32'd1);

    // Use signed values for z-comparisons
    check("BGTZ",              ALU_CMPGT0, 32'd5,        32'dX,   s_gt0(32'd5));
    check("BGEZ",              ALU_CMPGE0, 32'd0,        32'dX,   s_ge0(32'd0));
    check("BLTZ",              ALU_CMPLT0, 32'hFFFF_FFFB,32'dX,   s_lt0(32'hFFFF_FFFB)); // -5
    check("BLEZ",              ALU_CMPLE0, 32'hFFFF_FFFF,32'dX,   s_le0(32'hFFFF_FFFF)); // -1

    // ---------- Passthroughs (useful for JR path, etc.) ----------
    check("PASSA (jr aid)",    ALU_PASSA, 32'h1234_5678, 32'hAAAA_AAAA, 32'h1234_5678);
    check("PASSB",             ALU_PASSB, 32'h1234_5678, 32'hDEAD_BEEF, 32'hDEAD_BEEF);

    // ---------- "Immediate" logicals map to same ops ----------
    // andi/ori/xori use same ALU ops; controller provides zero-extended imm on B.
    check("ANDI path",         ALU_AND,  32'hFFFF_00FF, 32'h0000_00F0, 32'h0000_00F0);
    check("ORI path",          ALU_OR,   32'h0000_000F, 32'h0000_00F0, 32'h0000_00FF);
    check("XORI path",         ALU_XOR,  32'h0000_00F0, 32'h0000_00FF, 32'h0000_000F);

    $display("=== ALL TESTS PASSED ✅ ===");
    $finish;
  end

endmodule
