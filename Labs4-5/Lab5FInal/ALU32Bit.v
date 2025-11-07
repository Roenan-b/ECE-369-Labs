
`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// ECE369 - Computer Architecture
// 32-bit ALU - supports ops needed for labs 5-8 and the table you posted.
// Notes:
//  - Shifts: shamt is taken from A[4:0]; value to shift is B.
//  - Signed comparisons use $signed(...).
//  - Branches can be driven either the classic way (SUB + Zero) or via the
//    explicit compare ops that return 1/0 in ALUResult.

//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%

////////////////////////////////////////////////////////////////////////////////
module ALU32Bit (
    input  [5:0]  ALUControl,   // widened to 5 to fit all ops
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] ALUResult,
    output        Zero
);

    // -------- Opcode map (pick what your control unit emits) ----------
    // Arithmetic / address:
    localparam ALU_AND   = 6'd0;   // and / andi
    localparam ALU_OR    = 6'd1;   // or  / ori
    localparam ALU_XOR   = 6'd2;   // xor / xori
    localparam ALU_NOR   = 6'd3;   // nor
    localparam ALU_ADD   = 6'd4;   // add, addi, lw, sw, lb/sb, lh/sh
    localparam ALU_SUB   = 6'd5;   // sub, beq/bne (with Zero) if desired
    localparam ALU_MUL   = 6'd6;   // mul (low 32 bits)
    localparam ALU_SLT   = 6'd7;   // slt / slti (signed)

    // Shifts (shamt in A[4:0], data in B):
    localparam ALU_SLL   = 6'd8;   // sll
    localparam ALU_SRL   = 6'd9;   // srl (logical)

    // Branch-friendly compares (return 1 or 0 in result):
    localparam ALU_CMPEQ = 6'd10;  // A == B   (beq)
    localparam ALU_CMPNE = 6'd11;  // A != B   (bne)
    localparam ALU_CMPGT0= 6'd12;  // A >  0   (bgtz)
    localparam ALU_CMPGE0= 6'd13;  // A >= 0   (bgez)
    localparam ALU_CMPLT0= 6'd14;  // A <  0   (bltz)
    localparam ALU_CMPLE0= 6'd15;  // A <= 0   (blez)

    // Passthroughs (handy for JR, etc.):
    localparam ALU_PASSA = 6'd16;  // result = A
    localparam ALU_PASSB = 6'd17;  // result = B

    reg [31:0] result;

    // Combinational ALU
    always @* begin
        case (ALUControl)
            ALU_AND   : result = A & B;
            ALU_OR    : result = A | B;
            ALU_XOR   : result = A ^ B;
            ALU_NOR   : result = ~(A | B);
            ALU_ADD   : result = A + B;                    // add/addi + address calc for {lw,sw,lb,sb,lh,sh}
            ALU_SUB   : result = A - B;                    // sub (also beq/bne with Zero flag if you prefer)
            ALU_MUL   : result = A * B;                    // low 32 bits
            ALU_SLT   : result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;

            ALU_SLL   : result = B << A[4:0];              // shamt in A[4:0], data in B
            ALU_SRL   : result = B >> A[4:0];

            ALU_CMPEQ : result = (A == B) ? 32'd1 : 32'd0; // beq
            ALU_CMPNE : result = (A != B) ? 32'd1 : 32'd0; // bne
            ALU_CMPGT0: result = ($signed(A) >  0) ? 32'd1 : 32'd0; // bgtz
            ALU_CMPGE0: result = ($signed(A) >= 0) ? 32'd1 : 32'd0; // bgez
            ALU_CMPLT0: result = ($signed(A) <  0) ? 32'd1 : 32'd0; // bltz
            ALU_CMPLE0: result = ($signed(A) <= 0) ? 32'd1 : 32'd0; // blez

            ALU_PASSA : result = A;     //PASSES THE NEXT ADDRES TO JUMP TO
            ALU_PASSB : result = B;     //FORWARDS VALUE

            default   : result = 32'b0;
        endcase
    end

    assign ALUResult = result;
    assign Zero      = (result == 32'b0);

endmodule
