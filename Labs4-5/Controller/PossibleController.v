`timescale 1ns / 1ps

module controller(
  input  [31:0] instruction,
  input         Clk,

  // Mainline controls
  output reg        ALUSrc,
  output reg [1:0]  RegDstSel,   // 00: rt, 01: rd, 10: $31 (jal)
  output reg [5:0]  ALUControl,  // matches your ALU (0..17)
  output reg        MemRead,
  output reg        MemWrite,
  output reg [1:0]  WBSource,    // 00: ALU, 01: Mem, 10: PC+4
  output reg        RegWrite,
  output reg        Branch,
  output reg        Jump,
  output reg        JumpReg,     // jr
  // Immediate/shift helpers
  output reg        ExtZero,     // 1=zero-extend imm; 0=sign-extend
  output reg        UseShamt     // 1=ALU A comes from shamt
);

  // Fields
  wire [5:0] opcode = instruction[31:26];
  wire [4:0] rs     = instruction[25:21];
  wire [4:0] rt     = instruction[20:16];
  wire [4:0] rd     = instruction[15:11];
  wire [5:0] funct  = instruction[5:0];

  // Opcodes (true MIPS encodings)
  localparam OP_RTYPE  = 6'b000000; // SPECIAL
  localparam OP_REGIMM = 6'b000001; // BLTZ/BGEZ via rt
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

  // R-type functs (standard)
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
  // Course-specific MUL (treat as R-type)
  localparam FUNCT_MUL = 6'd24; // align with your ALU/testbench

  // ALUControl map (must match your ALU)
  localparam AC_AND  = 6'd0,
             AC_OR   = 6'd1,
             AC_XOR  = 6'd2,
             AC_NOR  = 6'd3,
             AC_ADD  = 6'd4,
             AC_SUB  = 6'd5,
             AC_MUL  = 6'd6,
             AC_SLT  = 6'd7,
             AC_SLL  = 6'd8,
             AC_SRL  = 6'd9,
             AC_BEQ  = 6'd10,
             AC_BNE  = 6'd11,
             AC_BGTZ = 6'd12,
             AC_BGEZ = 6'd13,
             AC_BLTZ = 6'd14,
             AC_BLEZ = 6'd15,
             AC_PASSA= 6'd16,   // jr
             AC_PASSB= 6'd17;   // jal (if you want to pass link/target)

  always @* begin
    // Safe defaults
    ALUSrc     = 0;
    RegDstSel  = 2'b00;
    ALUControl = AC_ADD;  // harmless default
    MemRead    = 0;
    MemWrite   = 0;
    WBSource   = 2'b00;   // ALU
    RegWrite   = 0;
    Branch     = 0;
    Jump       = 0;
    JumpReg    = 0;
    ExtZero    = 0;       // default sign-extend
    UseShamt   = 0;

    case (opcode)
      // ================= R-TYPE =================
      OP_RTYPE: begin
        RegDstSel = 2'b01;     // rd
        RegWrite  = 1;
        case (funct)
          FUNCT_AND: ALUControl = AC_AND;
          FUNCT_OR : ALUControl = AC_OR;
          FUNCT_XOR: ALUControl = AC_XOR;
          FUNCT_NOR: ALUControl = AC_NOR;
          FUNCT_ADD: ALUControl = AC_ADD;
          FUNCT_SUB: ALUControl = AC_SUB;
          FUNCT_MUL: ALUControl = AC_MUL;
          FUNCT_SLT: ALUControl = AC_SLT;
          FUNCT_SLL: begin ALUControl = AC_SLL; UseShamt = 1; end
          FUNCT_SRL: begin ALUControl = AC_SRL; UseShamt = 1; end
          FUNCT_JR : begin
            // PC <- rs (no reg writeback)
            RegWrite  = 0;
            Jump      = 1;
            JumpReg   = 1;
            ALUControl= AC_PASSA; // optional, if your datapath uses ALU for JR
          end
          default: begin RegWrite = 0; end
        endcase
      end

      // =============== IMMEDIATES ===============
      OP_ADDI: begin ALUSrc=1; RegWrite=1; RegDstSel=2'b00; ALUControl=AC_ADD; ExtZero=0; end
      OP_SLTI: begin ALUSrc=1; RegWrite=1; RegDstSel=2'b00; ALUControl=AC_SLT; ExtZero=0; end
      OP_ANDI: begin ALUSrc=1; RegWrite=1; RegDstSel=2'b00; ALUControl=AC_AND; ExtZero=1; end
      OP_ORI : begin ALUSrc=1; RegWrite=1; RegDstSel=2'b00; ALUControl=AC_OR ; ExtZero=1; end
      OP_XORI: begin ALUSrc=1; RegWrite=1; RegDstSel=2'b00; ALUControl=AC_XOR; ExtZero=1; end

      // ================ LOADS ===================
      OP_LB, OP_LH, OP_LW: begin
        ALUSrc    = 1;             // effective address: base + offset
        RegDstSel = 2'b00;         // rt
        MemRead   = 1;
        WBSource  = 2'b01;         // Mem
        RegWrite  = 1;
        ALUControl= AC_ADD;        // address calc
        ExtZero   = 0;             // sign-extend offset
        // (Mem size/type handled in memory unit)
      end

      // ================ STORES ==================
      OP_SB, OP_SH, OP_SW: begin
        ALUSrc    = 1;             // base + offset
        MemWrite  = 1;
        RegWrite  = 0;
        ALUControl= AC_ADD;
        ExtZero   = 0;
      end

      // ================ BRANCHES ================
      OP_BEQ : begin ALUSrc=0; Branch=1; ALUControl=AC_BEQ;  end
      OP_BNE : begin ALUSrc=0; Branch=1; ALUControl=AC_BNE;  end
      OP_BLEZ: begin ALUSrc=0; Branch=1; ALUControl=AC_BLEZ; end
      OP_BGTZ: begin ALUSrc=0; Branch=1; ALUControl=AC_BGTZ; end

      OP_REGIMM: begin // BLTZ/BGEZ via rt
        ALUSrc = 0; Branch = 1;
        if (rt == RT_BLTZ)      ALUControl = AC_BLTZ;
        else if (rt == RT_BGEZ) ALUControl = AC_BGEZ;
        else begin Branch=0; end
      end

      // ================= JUMPS ==================
      OP_J:   begin Jump=1; /* PC mux uses jump target; no reg write */ end
      OP_JAL: begin
        Jump      = 1;            // PC <- jump target
        RegWrite  = 1;            // write $ra
        RegDstSel = 2'b10;        // select $31
        WBSource  = 2'b10;        // write PC+4
        // (ALU not used; AC_PASSB optional if your datapath expects it)
      end

      default: ;
    endcase
  end
endmodule

