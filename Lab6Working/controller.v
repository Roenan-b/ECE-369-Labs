`timescale 1ns / 1ps
  


//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
module controller(
  input  [31:0] instruction,
  input         Clk,
  output reg        ALUSrc,
  output reg [1:0]  RegDstSel,   // 00: rt, 01: rd, 10: $31
  output reg [5:0]  ALUControl,  // 0..17 per your ALU
  output reg        MemRead,
  output reg        MemWrite,
  output reg [1:0]  WBSource,    // 00: ALU, 01: Mem, 10: PC+4
  output reg        RegWrite,
  output reg        Branch,
  output reg        Jump,
  output reg        JumpReg,     // jr
  output reg        ExtZero,     // immed: 1=zero-extend; 0=sign-extend
  output reg        UseShamt,     // shifts: A=shamt
  output reg [1:0] MemSize,     // 00=byte, 01=half, 10=word
  output reg       MemUnsigned  // 1=zero-extend, 0=sign-extend

);

  wire [5:0] opcode = instruction[31:26];
  wire [4:0] rs     = instruction[25:21];
  wire [4:0] rt     = instruction[20:16];
  wire [4:0] rd     = instruction[15:11];
  wire [4:0] shamt  = instruction[10:6];
  wire [5:0] funct  = instruction[5:0];

  // MIPS opcodes - ONLY THOSE IN YOUR TABLE
  localparam OP_RTYPE  = 6'b000000;
  localparam OP_REGIMM = 6'b000001; // for bgez, bltz
  localparam OP_J      = 6'b000010;
  localparam OP_JAL    = 6'b000011;
  localparam OP_BEQ    = 6'b000100;
  localparam OP_BNE    = 6'b000101;
  localparam OP_BLEZ   = 6'b000110;
  localparam OP_BGTZ   = 6'b000111;
  localparam OP_ADDI   = 6'b001000;
  localparam OP_SLTI   = 6'b001010; // slti
  localparam OP_ANDI   = 6'b001100;
  localparam OP_ORI    = 6'b001101;
  localparam OP_XORI   = 6'b001110;
  localparam OP_LW     = 6'b100011;
  localparam OP_SW     = 6'b101011;
  localparam OP_LB     = 6'b100000;
  localparam OP_SB     = 6'b101000;
  localparam OP_LH     = 6'b100001;
  localparam OP_SH     = 6'b101001;

  // REGIMM rt for bgez/bltz
  localparam RT_BLTZ   = 5'b00000;
  localparam RT_BGEZ   = 5'b00001;

  // R-type functs - ONLY THOSE IN YOUR TABLE
  localparam FUNCT_SLL = 6'b000000;
  localparam FUNCT_SRL = 6'b000010;
  localparam FUNCT_JR  = 6'b001000;
  localparam FUNCT_ADD = 6'b100000;
  localparam FUNCT_SUB = 6'b100010;
  localparam FUNCT_AND = 6'b100100;
  localparam FUNCT_OR  = 6'b100101;
  localparam FUNCT_XOR = 6'b100110;
  localparam FUNCT_NOR = 6'b100111;
  localparam FUNCT_SLT = 6'b101010; // slt (was sit in your table)
  localparam FUNCT_MUL = 6'b011000; // Your custom MUL

  // ALUControl map (EXACTLY matches your ALU)
  localparam AC_AND   = 6'd0;
  localparam AC_OR    = 6'd1;
  localparam AC_XOR   = 6'd2;
  localparam AC_NOR   = 6'd3;
  localparam AC_ADD   = 6'd4;
  localparam AC_SUB   = 6'd5;
  localparam AC_MUL   = 6'd6;
  localparam AC_SLT   = 6'd7;
  localparam AC_SLL   = 6'd8;
  localparam AC_SRL   = 6'd9;
  localparam AC_BEQ   = 6'd10;
  localparam AC_BNE   = 6'd11;
  localparam AC_BGTZ  = 6'd12;
  localparam AC_BGEZ  = 6'd13;
  localparam AC_BLTZ  = 6'd14;
  localparam AC_BLEZ  = 6'd15;
  localparam AC_PASSA = 6'd16; // jr
  localparam AC_PASSB = 6'd17; // jal
  
  localparam OP_SPECIAL2 = 6'b011100; // MIPS32r2 SPECIAL2
  localparam FUNCT_MUL_R2 = 6'b000010; // mul rd, rs, rt

  always @* begin
    // Defaults
    ALUSrc     = 1'b0;
    RegDstSel  = 2'b00; // rt
    ALUControl = AC_ADD;
    MemRead    = 1'b0;
    MemWrite   = 1'b0;
    WBSource   = 2'b00; // ALU
    RegWrite   = 1'b0;
    Branch     = 1'b0;
    Jump       = 1'b0;
    JumpReg    = 1'b0;
    ExtZero    = 1'b0; // sign-extend by default
    UseShamt   = 1'b0;
    MemSize    = 2'b10; // word
    MemUnsigned= 1'b0;  // signed by default


    case (opcode)
      OP_RTYPE: begin
        RegDstSel = 2'b01; // rd
        RegWrite  = 1'b1;
        case (funct)
          FUNCT_ADD: ALUControl = AC_ADD;
          FUNCT_SUB: ALUControl = AC_SUB;
          FUNCT_AND: ALUControl = AC_AND;
          FUNCT_OR:  ALUControl = AC_OR;
          FUNCT_XOR: ALUControl = AC_XOR;
          FUNCT_NOR: ALUControl = AC_NOR;
          FUNCT_SLT: ALUControl = AC_SLT;
          FUNCT_MUL: ALUControl = AC_MUL;
          FUNCT_SLL: begin 
            ALUControl = AC_SLL; 
            UseShamt = 1'b1; 
          end
          FUNCT_SRL: begin 
            ALUControl = AC_SRL; 
            UseShamt = 1'b1; 
          end
          FUNCT_JR: begin
            RegWrite   = 1'b0;
            Jump       = 1'b1;
            JumpReg    = 1'b1;
            ALUControl = AC_PASSA;
          end
          default: begin
            RegWrite = 1'b0; // Unknown function
          end
        endcase
      end

      // === ARITHMETIC IMMEDIATE ===
      OP_ADDI: begin 
        ALUSrc=1'b1; RegWrite=1'b1; RegDstSel=2'b00; 
        ALUControl=AC_ADD; ExtZero=1'b0; 
        WBSource = 2'b00;
      end
      
      // === LOGICAL IMMEDIATE ===
      OP_ANDI: begin 
        ALUSrc=1'b1; RegWrite=1'b1; RegDstSel=2'b00; 
        ALUControl=AC_AND; ExtZero=1'b1; 
      end
      OP_ORI: begin 
        ALUSrc=1'b1; RegWrite=1'b1; RegDstSel=2'b00; 
        ALUControl=AC_OR; ExtZero=1'b1; 
      end
      OP_XORI: begin 
        ALUSrc=1'b1; RegWrite=1'b1; RegDstSel=2'b00; 
        ALUControl=AC_XOR; ExtZero=1'b1; 
      end
      
      // === SET IMMEDIATE (WAS MISSING!) ===
      OP_SLTI: begin 
        ALUSrc=1'b1; RegWrite=1'b1; RegDstSel=2'b00; 
        ALUControl=AC_SLT; ExtZero=1'b0; 
      end

      // === LOAD INSTRUCTIONS ===
      OP_LW: begin
        ALUSrc=1; RegDstSel=2'b00; MemRead=1; WBSource=2'b01; RegWrite=1; ALUControl=AC_ADD;
        MemSize=2'b10; MemUnsigned=1'b0; // word, signed doesn't matter
      end
      OP_LB: begin
        ALUSrc=1; RegDstSel=2'b00; MemRead=1; WBSource=2'b01; RegWrite=1; ALUControl=AC_ADD;
        MemSize=2'b00; MemUnsigned=1'b0; // byte, sign-extend
      end

      // === STORE INSTRUCTIONS ===
      OP_SW: begin
        ALUSrc=1; MemWrite=1; ALUControl=AC_ADD; RegWrite=1'b0;
        MemSize=2'b10; // word
      end
      OP_SB: begin
        ALUSrc=1; MemWrite=1; ALUControl=AC_ADD; RegWrite=1'b0;
        MemSize=2'b00; // byte
      end
      
      // === LOAD HALFWORD ===
      OP_LH: begin
        ALUSrc=1; RegDstSel=2'b00; MemRead=1; WBSource=2'b01; RegWrite=1; ALUControl=AC_ADD;
        MemSize=2'b01; MemUnsigned=1'b0; // half, sign-extend
      end
      // === STORE HALFWORD ===
      OP_SH: begin
        ALUSrc=1; MemWrite=1; ALUControl=AC_ADD; RegWrite=1'b0;
        MemSize=2'b01; // half
      end



      // === BRANCH INSTRUCTIONS ===
      OP_BEQ: begin 
        ALUSrc=1'b0; Branch=1'b1; ALUControl=AC_BEQ;  
      end
      OP_BNE: begin 
        ALUSrc=1'b0; Branch=1'b1; ALUControl=AC_BNE;  
      end
      OP_BLEZ: begin 
        ALUSrc=1'b0; Branch=1'b1; ALUControl=AC_BLEZ; 
      end
      OP_BGTZ: begin 
        ALUSrc=1'b0; Branch=1'b1; ALUControl=AC_BGTZ; 
      end

      // === REGIMM BRANCHES (bgez, bltz) ===
      OP_REGIMM: begin
        ALUSrc = 1'b0; 
        Branch = 1'b1;
        case (rt)
          RT_BLTZ: ALUControl = AC_BLTZ;
          RT_BGEZ: ALUControl = AC_BGEZ;
          default: Branch = 1'b0;
        endcase
      end

      // === JUMP INSTRUCTIONS ===
      OP_J: begin 
        Jump = 1'b1; 
      end
      OP_JAL: begin 
        Jump = 1'b1; 
        RegWrite = 1'b1; 
        RegDstSel = 2'b10; // $31
        WBSource = 2'b10;  // PC+4
        ALUControl = AC_PASSB;
      end
      
      OP_SPECIAL2: begin
        // mul rd, rs, rt  (signed, low 32 to rd)
        if (funct == FUNCT_MUL_R2) begin
        ALUSrc     = 1'b0;          // rs,rt
        RegDstSel  = 2'b01;         // rd
        ALUControl = AC_MUL;        // your ALU case
        MemRead    = 1'b0;
        MemWrite   = 1'b0;
        WBSource   = 2'b00;         // ALU
        RegWrite   = 1'b1;          // write rd
        Branch     = 1'b0;
        Jump       = 1'b0;
        JumpReg    = 1'b0;
        UseShamt   = 1'b0;
        ExtZero    = 1'b0;
  end else begin
    // Unknown SPECIAL2 funct
    RegWrite = 1'b0;
  end
end


      default: begin
        // Unknown opcode
        RegWrite = 1'b0;
        MemRead = 1'b0;
        MemWrite = 1'b0;
        Branch = 1'b0;
        Jump = 1'b0;
      end
    endcase
    $display("[%0t] ID   : MemSize=%b Uns=%b opcode=%b",
         $time, MemSize, MemUnsigned, instruction[31:26]);
  end
  
endmodule
