`timescale 1ns / 1ps

// ============================================================================
// COMPLETE 32-BIT MIPS ALU WITH STANDARDIZED CONTROL ENCODING
// ============================================================================
module ALU32Bit(
    input [5:0] ALUControl,
    input [31:0] A,
    input [31:0] B,
    output reg [31:0] ALUResult,
    output Zero,
    output Overflow
);

    wire signed [31:0] A_signed = A;
    wire signed [31:0] B_signed = B;
    reg overflow_flag;
    
    always @(*) begin
        overflow_flag = 1'b0;
        
        case(ALUControl)
            // ===== LOGICAL OPERATIONS =====
            5'd0: ALUResult = A & B;                    // AND (and, andi)
            5'd1: ALUResult = A | B;                    // OR (or, ori)
            5'd2: ALUResult = A ^ B;                    // XOR (xor, xori)
            5'd3: ALUResult = ~(A | B);                 // NOR (nor)
            
            // ===== ARITHMETIC OPERATIONS =====
            5'd4: begin                                 // ADD (add, addi, lw, sw, lb, sb, lh, sh)
                ALUResult = A + B;
                overflow_flag = (A[31] == B[31]) && (ALUResult[31] != A[31]);
            end
            
            5'd5: begin                                 // SUB (sub)
                ALUResult = A - B;
                overflow_flag = (A[31] != B[31]) && (ALUResult[31] != A[31]);
            end
            
            5'd6: ALUResult = A * B;                    // MUL (mul)
            
            // ===== SET OPERATIONS =====
            5'd7: ALUResult = (A_signed < B_signed) ? 32'd1 : 32'd0;  // SLT (slt, slti)
            
            // ===== SHIFT OPERATIONS =====
            5'd8: ALUResult = B << A[4:0];              // SLL (sll) - shift B left by A bits
            5'd9: ALUResult = B >> A[4:0];              // SRL (srl) - shift B right by A bits
            
            // ===== BRANCH COMPARISON OPERATIONS =====
            5'd10: ALUResult = (A == B) ? 32'd1 : 32'd0;              // BEQ
            5'd11: ALUResult = (A != B) ? 32'd1 : 32'd0;              // BNE
            5'd12: ALUResult = (A_signed > 0) ? 32'd1 : 32'd0;        // BGTZ
            5'd13: ALUResult = (A_signed >= 0) ? 32'd1 : 32'd0;       // BGEZ
            5'd14: ALUResult = (A_signed < 0) ? 32'd1 : 32'd0;        // BLTZ
            5'd15: ALUResult = (A_signed <= 0) ? 32'd1 : 32'd0;       // BLEZ
            
            // ===== PASSTHROUGH OPERATIONS =====
            5'd16: ALUResult = A;                       // PASSA (jr)
            5'd17: ALUResult = B;                       // PASSB (jal/link address)
            
            default: ALUResult = 32'd0;
        endcase
    end
    
    assign Zero = (ALUResult == 32'd0);
    assign Overflow = overflow_flag;

endmodule
