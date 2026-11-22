`timescale 1ns/1ps

module controller_tb;

  // DUT inputs
  reg  [31:0] instruction;
  reg         Clk;

  // DUT outputs
  wire        ALUSrc;
  wire [1:0]  RegDstSel;   // 00: rt, 01: rd, 10: $31
  wire [5:0]  ALUControl;  // your ALU codes (0..17)
  wire        MemRead;
  wire        MemWrite;
  wire [1:0]  WBSource;    // 00: ALU, 01: Mem, 10: PC+4
  wire        RegWrite;
  wire        Branch;
  wire        Jump;
  wire        JumpReg;
  wire        ExtZero;
  wire        UseShamt;

  // Instantiate DUT (your fixed controller)
  controller dut(
    .instruction(instruction),
    .Clk(Clk),
    .ALUSrc(ALUSrc),
    .RegDstSel(RegDstSel),
    .ALUControl(ALUControl),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .WBSource(WBSource),
    .RegWrite(RegWrite),
    .Branch(Branch),
    .Jump(Jump),
    .JumpReg(JumpReg),
    .ExtZero(ExtZero),
    .UseShamt(UseShamt)
  );

  // ============================================================
  // ALUControl map (mirror your ALU)
  // ============================================================
  localparam AC_AND   = 6'd0,
             AC_OR    = 6'd1,
             AC_XOR   = 6'd2,
             AC_NOR   = 6'd3,
             AC_ADD   = 6'd4,
             AC_SUB   = 6'd5,
             AC_MUL   = 6'd6,
             AC_SLT   = 6'd7,
             AC_SLL   = 6'd8,
             AC_SRL   = 6'd9,
             AC_BEQ   = 6'd10,
             AC_BNE   = 6'd11,
             AC_BGTZ  = 6'd12,
             AC_BGEZ  = 6'd13,
             AC_BLTZ  = 6'd14,
             AC_BLEZ  = 6'd15,
             AC_PASSA = 6'd16,  // jr (optional)
             AC_PASSB = 6'd17;  // jal (optional)

  // ============================================================
  // MIPS encodings (true opcodes / functs)
  // ============================================================
  localparam OP_RTYPE  = 6'b000000;
  localparam OP_REGIMM = 6'b000001; // bltz/bgez via rt
  localparam OP_J      = 6'b000010;
  localparam OP_JAL    = 6'b000011;
  localparam OP_BEQ    = 6'b000100;
  localparam OP_BNE    = 6'b000101;
  localparam OP_BLEZ   = 6'b000110;
  localparam OP_BGTZ   = 6'b000111;

  localparam OP_ADDI   = 6'b001000;
  localparam OP_SLTI   = 6'b001010;
  localparam OP_ANDI   = 6'b001100;
  localparam OP_ORI    = 6'b001101;
  localparam OP_XORI   = 6'b001110;

  localparam OP_LB     = 6'b100000;
  localparam OP_LH     = 6'b100001;
  localparam OP_LW     = 6'b100011;
  localparam OP_SB     = 6'b101000;
  localparam OP_SH     = 6'b101001;
  localparam OP_SW     = 6'b101011;

  // REGIMM rt codes
  localparam RT_BLTZ   = 5'd0;
  localparam RT_BGEZ   = 5'd1;

  // R-type functs
  localparam FUNCT_SLL = 6'd0;
  localparam FUNCT_SRL = 6'd2;
  localparam FUNCT_JR  = 6'd8;
  localparam FUNCT_ADD = 6'd32;
  localparam FUNCT_SUB = 6'd34;
  localparam FUNCT_AND = 6'd36;
  localparam FUNCT_OR  = 6'd37;
  localparam FUNCT_XOR = 6'd38;
  localparam FUNCT_NOR = 6'd39;
  localparam FUNCT_SLT = 6'd42;
  // course-specific MUL as R-type
  localparam FUNCT_MUL = 6'd24;

  // ============================================================
  // Helpers to build instructions
  // ============================================================
  function [31:0] RType;
    input [4:0] rs, rt, rd, shamt;
    input [5:0] funct;
    begin
      RType = {OP_RTYPE, rs, rt, rd, shamt, funct};
    end
  endfunction

  function [31:0] IType;
    input [5:0]  op;
    input [4:0]  rs, rt;
    input [15:0] imm;
    begin
      IType = {op, rs, rt, imm};
    end
  endfunction

  function [31:0] JType;
    input [5:0]  op;
    input [25:0] target;
    begin
      JType = {op, target};
    end
  endfunction

  function [31:0] RegImm; // bltz/bgez
    input [4:0] rt_sel;   // 0=bltz, 1=bgez
    input [4:0] rs;
    input [15:0] imm;
    begin
      RegImm = {OP_REGIMM, rs, rt_sel, imm};
    end
  endfunction

  // ============================================================
  // Self-check task
  // ============================================================
  integer tests, fails;

  task expect;
    input [255:0] name;
    input exp_ALUSrc;
    input [1:0]  exp_RegDstSel;
    input [5:0]  exp_ALUControl;
    input exp_MemRead;
    input exp_MemWrite;
    input [1:0]  exp_WBSource;
    input exp_RegWrite;
    input exp_Branch;
    input exp_Jump;
    input exp_JumpReg;
    input exp_ExtZero;
    input exp_UseShamt;
    begin
      #1; // let comb settle
      tests = tests + 1;
      if (ALUSrc     !== exp_ALUSrc    || 
          RegDstSel  !== exp_RegDstSel ||
          ALUControl !== exp_ALUControl||
          MemRead    !== exp_MemRead   ||
          MemWrite   !== exp_MemWrite  ||
          WBSource   !== exp_WBSource  ||
          RegWrite   !== exp_RegWrite  ||
          Branch     !== exp_Branch    ||
          Jump       !== exp_Jump      ||
          JumpReg    !== exp_JumpReg   ||
          ExtZero    !== exp_ExtZero   ||
          UseShamt   !== exp_UseShamt) begin
        $display("FAIL: %s", name);
        $display("  Got   : ALUSrc=%0d RegDstSel=%0d ALUCtrl=%0d MemR=%0d MemW=%0d WB=%0d RegW=%0d Br=%0d J=%0d JR=%0d ExtZ=%0d Shamt=%0d",
                  ALUSrc,RegDstSel,ALUControl,MemRead,MemWrite,WBSource,RegWrite,Branch,Jump,JumpReg,ExtZero,UseShamt);
        $display("  Expect: ALUSrc=%0d RegDstSel=%0d ALUCtrl=%0d MemR=%0d MemW=%0d WB=%0d RegW=%0d Br=%0d J=%0d JR=%0d ExtZ=%0d Shamt=%0d",
                  exp_ALUSrc,exp_RegDstSel,exp_ALUControl,exp_MemRead,exp_MemWrite,exp_WBSource,exp_RegWrite,exp_Branch,exp_Jump,exp_JumpReg,exp_ExtZero,exp_UseShamt);
        fails = fails + 1;
      end else begin
        $display("PASS: %s", name);
      end
    end
  endtask

  // ============================================================
  // Clock (not required, but nice to have)
  // ============================================================
  initial Clk = 0;
  always #5 Clk = ~Clk;

  // ============================================================
  // Test sequence
  // ============================================================
  initial begin
    tests = 0; fails = 0;
    $display("\n=== CONTROLLER TESTS ===\n");

    // ---------- R-type logicals ----------
    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_AND);
    expect("AND (R)", 0, 2'b01, AC_AND, 0,0, 2'b00,1, 0,0,0, 0);

    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_OR);
    expect("OR (R)",  0, 2'b01, AC_OR,  0,0, 2'b00,1, 0,0,0, 0);

    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_XOR);
    expect("XOR (R)", 0, 2'b01, AC_XOR, 0,0, 2'b00,1, 0,0,0, 0);

    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_NOR);
    expect("NOR (R)", 0, 2'b01, AC_NOR, 0,0, 2'b00,1, 0,0,0, 0);

    // ---------- R-type arith ----------
    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_ADD);
    expect("ADD (R)", 0, 2'b01, AC_ADD, 0,0, 2'b00,1, 0,0,0, 0);

    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_SUB);
    expect("SUB (R)", 0, 2'b01, AC_SUB, 0,0, 2'b00,1, 0,0,0, 0);

    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_MUL);
    expect("MUL (R)", 0, 2'b01, AC_MUL, 0,0, 2'b00,1, 0,0,0, 0);

    instruction = RType(5'd1,5'd2,5'd3,5'd0,FUNCT_SLT);
    expect("SLT (R)", 0, 2'b01, AC_SLT, 0,0, 2'b00,1, 0,0,0, 0);

    // ---------- Shifts ----------
    instruction = RType(5'd0,5'd2,5'd3,5'd4,FUNCT_SLL); // shamt=4
    expect("SLL", 0, 2'b01, AC_SLL, 0,0, 2'b00,1, 0,0,0, 1);

    instruction = RType(5'd0,5'd2,5'd3,5'd1,FUNCT_SRL); // shamt=1
    expect("SRL", 0, 2'b01, AC_SRL, 0,0, 2'b00,1, 0,0,0, 1);

    // ---------- JR ----------
    instruction = RType(5'd31,5'd0,5'd0,5'd0,FUNCT_JR);
    expect("JR",  0, 2'b01, AC_PASSA, 0,0, 2'b00,0, 0,1,1, 0);

    // ---------- Immediate logicals (zero-extend) ----------
    instruction = IType(OP_ANDI,5'd1,5'd2,16'h00FF);
    expect("ANDI",1, 2'b00, AC_AND, 0,0, 2'b00,1, 0,0,0, 0);  // ExtZero=1 expected below
    if (ExtZero !== 1) begin $display("NOTE: ANDI should set ExtZero=1"); fails=fails+1; end

    instruction = IType(OP_ORI,5'd1,5'd2,16'h00FF);
    expect("ORI", 1, 2'b00, AC_OR,  0,0, 2'b00,1, 0,0,0, 0);
    if (ExtZero !== 1) begin $display("NOTE: ORI should set ExtZero=1"); fails=fails+1; end

    instruction = IType(OP_XORI,5'd1,5'd2,16'h00FF);
    expect("XORI",1, 2'b00, AC_XOR, 0,0, 2'b00,1, 0,0,0, 0);
    if (ExtZero !== 1) begin $display("NOTE: XORI should set ExtZero=1"); fails=fails+1; end

    // ---------- addi/slti (sign-extend) ----------
    instruction = IType(OP_ADDI,5'd1,5'd2,16'hFF01); // negative imm
    expect("ADDI",1, 2'b00, AC_ADD, 0,0, 2'b00,1, 0,0,0, 0);
    if (ExtZero !== 0) begin $display("NOTE: ADDI should use sign-extend (ExtZero=0)"); fails=fails+1; end

    instruction = IType(OP_SLTI,5'd1,5'd2,16'h0001);
    expect("SLTI",1, 2'b00, AC_SLT, 0,0, 2'b00,1, 0,0,0, 0);
    if (ExtZero !== 0) begin $display("NOTE: SLTI should use sign-extend (ExtZero=0)"); fails=fails+1; end

    // ---------- Loads ----------
    instruction = IType(OP_LB,5'd1,5'd2,16'h0010);
    expect("LB", 1, 2'b00, AC_ADD, 1,0, 2'b01,1, 0,0,0, 0);

    instruction = IType(OP_LH,5'd1,5'd2,16'h0010);
    expect("LH", 1, 2'b00, AC_ADD, 1,0, 2'b01,1, 0,0,0, 0);

    instruction = IType(OP_LW,5'd1,5'd2,16'h0010);
    expect("LW", 1, 2'b00, AC_ADD, 1,0, 2'b01,1, 0,0,0, 0);

    // ---------- Stores ----------
    instruction = IType(OP_SB,5'd1,5'd2,16'h0010);
    expect("SB", 1, 2'b00, AC_ADD, 0,1, 2'b00,0, 0,0,0, 0);

    instruction = IType(OP_SH,5'd1,5'd2,16'h0010);
    expect("SH", 1, 2'b00, AC_ADD, 0,1, 2'b00,0, 0,0,0, 0);

    instruction = IType(OP_SW,5'd1,5'd2,16'h0010);
    expect("SW", 1, 2'b00, AC_ADD, 0,1, 2'b00,0, 0,0,0, 0);

    // ---------- Branches ----------
    instruction = IType(OP_BEQ,5'd1,5'd2,16'h0004);
    expect("BEQ",0, 2'b00, AC_BEQ, 0,0, 2'b00,0, 1,0,0, 0);

    instruction = IType(OP_BNE,5'd1,5'd2,16'h0004);
    expect("BNE",0, 2'b00, AC_BNE, 0,0, 2'b00,0, 1,0,0, 0);

    instruction = IType(OP_BLEZ,5'd1,5'd0,16'h0004); // rt==0 in encoding
    expect("BLEZ",0, 2'b00, AC_BLEZ,0,0, 2'b00,0, 1,0,0, 0);

    instruction = IType(OP_BGTZ,5'd1,5'd0,16'h0004); // rt==0 in encoding
    expect("BGTZ",0, 2'b00, AC_BGTZ,0,0, 2'b00,0, 1,0,0, 0);

    instruction = RegImm(RT_BLTZ,5'd1,16'h0004);
    expect("BLTZ",0, 2'b00, AC_BLTZ,0,0, 2'b00,0, 1,0,0, 0);

    instruction = RegImm(RT_BGEZ,5'd1,16'h0004);
    expect("BGEZ",0, 2'b00, AC_BGEZ,0,0, 2'b00,0, 1,0,0, 0);

    // ---------- Jumps ----------
    instruction = JType(OP_J, 26'h0001234);
    expect("J",   0, 2'b00, AC_ADD, 0,0, 2'b00,0, 0,1,0, 0); // ALUControl unused

    instruction = JType(OP_JAL,26'h0001234);
    expect("JAL", 0, 2'b10, AC_ADD, 0,0, 2'b10,1, 0,1,0, 0); // write $31 with PC+4

    // ============================================================
    // Summary
    // ============================================================
    $display("\nTests run: %0d   Fails: %0d", tests, fails);
    if (fails==0) $display(">>> ALL CONTROLLER TESTS PASSED ✅");
    else          $display(">>> SOME TESTS FAILED ❌");
    $finish;
  end

endmodule
