`timescale 1ns / 1ps

module ALU32Bit_tb;
    reg [4:0] ALUControl;
    reg [31:0] A, B;
    wire [31:0] ALUResult;
    wire Zero;
    
    // Instantiate the ALU
    ALU32Bit uut (
        .ALUControl(ALUControl),
        .A(A),
        .B(B),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );
    
    integer error_count;
    
    initial begin
        error_count = 0;
        
        $display("=== COMPREHENSIVE ALU32Bit TESTBENCH ===");
        $display("Testing ALL MIPS operations...\n");
        
        // Initialize all inputs
        ALUControl = 5'b0;
        A = 32'b0;
        B = 32'b0;
        
        #10;
        
        // =========================================================================
        // 1. ARITHMETIC OPERATIONS
        // =========================================================================
        $display("1. ARITHMETIC OPERATIONS:");
        
        // ADD (add, addi, lw, sw, lb, sb, lh, sh)
        ALUControl = 5'd4; A = 32'h00000005; B = 32'h00000003; #10;
        if (ALUResult !== 32'h00000008) begin
            $display("ERROR: ADD - Expected 8, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: ADD %d + %d = %d", A, B, ALUResult);
        end
        
        // SUB (sub)
        ALUControl = 5'd5; A = 32'h0000000A; B = 32'h00000005; #10;
        if (ALUResult !== 32'h00000005) begin
            $display("ERROR: SUB - Expected 5, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: SUB %d - %d = %d", A, B, ALUResult);
        end
        
        // MUL (mul)
        ALUControl = 5'd6; A = 32'h00000006; B = 32'h00000007; #10;
        if (ALUResult !== 32'h0000002A) begin
            $display("ERROR: MUL - Expected 42, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: MUL %d * %d = %d", A, B, ALUResult);
        end
        
        // =========================================================================
        // 2. LOGICAL OPERATIONS  
        // =========================================================================
        $display("\n2. LOGICAL OPERATIONS:");
        
        // AND (and, andi)
        ALUControl = 5'd0; A = 32'h0000000F; B = 32'h0000000A; #10;
        if (ALUResult !== 32'h0000000A) begin
            $display("ERROR: AND - Expected 0xA, Got %h", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: AND %h & %h = %h", A, B, ALUResult);
        end
        
        // OR (or, ori)
        ALUControl = 5'd1; A = 32'h00000005; B = 32'h0000000A; #10;
        if (ALUResult !== 32'h0000000F) begin
            $display("ERROR: OR - Expected 0xF, Got %h", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: OR %h | %h = %h", A, B, ALUResult);
        end
        
        // XOR (xor, xori)
        ALUControl = 5'd2; A = 32'h0000000F; B = 32'h0000000A; #10;
        if (ALUResult !== 32'h00000005) begin
            $display("ERROR: XOR - Expected 0x5, Got %h", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: XOR %h ^ %h = %h", A, B, ALUResult);
        end
        
        // NOR (nor)
        ALUControl = 5'd3; A = 32'h00000005; B = 32'h0000000A; #10;
        if (ALUResult !== 32'hFFFFFFF0) begin
            $display("ERROR: NOR - Expected 0xFFFFFFF0, Got %h", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: NOR ~(%h | %h) = %h", A, B, ALUResult);
        end
        
        // =========================================================================
        // 3. SET COMPARISON OPERATIONS
        // =========================================================================
        $display("\n3. SET COMPARISON OPERATIONS:");
        
        // SLT (slt, slti) - true case
        ALUControl = 5'd7; A = 32'h00000002; B = 32'h00000005; #10;
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: SLT - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: SLT %d < %d ? %d", $signed(A), $signed(B), ALUResult);
        end
        
        // SLT (slt, slti) - false case
        ALUControl = 5'd7; A = 32'h0000000A; B = 32'h00000005; #10;
        if (ALUResult !== 32'h00000000) begin
            $display("ERROR: SLT - Expected 0, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: SLT %d < %d ? %d", $signed(A), $signed(B), ALUResult);
        end
        
        // SLT with negative numbers
        ALUControl = 5'd7; A = 32'hFFFFFFFE; B = 32'h00000005; #10; // -2 < 5
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: SLT negative - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: SLT %d < %d ? %d", $signed(A), $signed(B), ALUResult);
        end
        
        // =========================================================================
        // 4. SHIFT OPERATIONS
        // =========================================================================
        $display("\n4. SHIFT OPERATIONS:");
        
        // SLL (sll) - shift left logical
        ALUControl = 5'd8; A = 32'h00000002; B = 32'h00000001; #10; // shift 1 left by 2
        if (ALUResult !== 32'h00000004) begin
            $display("ERROR: SLL - Expected 4, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: SLL %h << 2 = %h", 32'h1, ALUResult);
        end
        
        // SRL (srl) - shift right logical
        ALUControl = 5'd9; A = 32'h00000002; B = 32'h00000008; #10; // shift 8 right by 2
        if (ALUResult !== 32'h00000002) begin
            $display("ERROR: SRL - Expected 2, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: SRL %h >> 2 = %h", 32'h8, ALUResult);
        end
        
        // =========================================================================
        // 5. BRANCH COMPARISON OPERATIONS (return 1/0)
        // =========================================================================
        $display("\n5. BRANCH COMPARISON OPERATIONS:");
        
        // CMPEQ (beq) - equal
        ALUControl = 5'd10; A = 32'h12345678; B = 32'h12345678; #10;
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: CMPEQ equal - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: CMPEQ %h == %h ? %d", A, B, ALUResult);
        end
        
        // CMPEQ (beq) - not equal
        ALUControl = 5'd10; A = 32'h12345678; B = 32'h12345679; #10;
        if (ALUResult !== 32'h00000000) begin
            $display("ERROR: CMPEQ not equal - Expected 0, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: CMPEQ %h == %h ? %d", A, B, ALUResult);
        end
        
        // CMPNE (bne) - not equal
        ALUControl = 5'd11; A = 32'h12345678; B = 32'h12345679; #10;
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: CMPNE - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: CMPNE %h != %h ? %d", A, B, ALUResult);
        end
        
        // CMPGT0 (bgtz) - greater than zero
        ALUControl = 5'd12; A = 32'h00000005; B = 32'h00000000; #10;
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: CMPGT0 - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: CMPGT0 %d > 0 ? %d", $signed(A), ALUResult);
        end
        
        // CMPGE0 (bgez) - greater or equal zero
        ALUControl = 5'd13; A = 32'h00000000; B = 32'h00000000; #10;
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: CMPGE0 - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: CMPGE0 %d >= 0 ? %d", $signed(A), ALUResult);
        end
        
        // CMPLT0 (bltz) - less than zero
        ALUControl = 5'd14; A = 32'hFFFFFFFF; B = 32'h00000000; #10; // -1
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: CMPLT0 - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: CMPLT0 %d < 0 ? %d", $signed(A), ALUResult);
        end
        
        // CMPLE0 (blez) - less or equal zero
        ALUControl = 5'd15; A = 32'h00000000; B = 32'h00000000; #10;
        if (ALUResult !== 32'h00000001) begin
            $display("ERROR: CMPLE0 - Expected 1, Got %d", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: CMPLE0 %d <= 0 ? %d", $signed(A), ALUResult);
        end
        
        // =========================================================================
        // 6. PASSTHROUGH OPERATIONS
        // =========================================================================
        $display("\n6. PASSTHROUGH OPERATIONS:");
        
        // PASSA (jr)
        ALUControl = 5'd16; A = 32'h40000000; B = 32'h00000000; #10;
        if (ALUResult !== 32'h40000000) begin
            $display("ERROR: PASSA - Expected 0x40000000, Got %h", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: PASSA = %h", ALUResult);
        end
        
        // PASSB
        ALUControl = 5'd17; A = 32'h00000000; B = 32'h12345678; #10;
        if (ALUResult !== 32'h12345678) begin
            $display("ERROR: PASSB - Expected 0x12345678, Got %h", ALUResult);
            error_count = error_count + 1;
        end else begin
            $display("PASS: PASSB = %h", ALUResult);
        end
        
        // =========================================================================
        // 7. ZERO FLAG TESTING
        // =========================================================================
        $display("\n7. ZERO FLAG TESTING:");
        
        // Zero flag true (result = 0)
        ALUControl = 5'd5; A = 32'h00000005; B = 32'h00000005; #10; // 5-5=0
        if (Zero !== 1'b1) begin
            $display("ERROR: Zero flag - Expected 1, Got %b", Zero);
            error_count = error_count + 1;
        end else begin
            $display("PASS: Zero flag = %b (result = 0)", Zero);
        end
        
        // Zero flag false (result != 0)
        ALUControl = 5'd4; A = 32'h00000001; B = 32'h00000001; #10; // 1+1=2
        if (Zero !== 1'b0) begin
            $display("ERROR: Zero flag - Expected 0, Got %b", Zero);
            error_count = error_count + 1;
        end else begin
            $display("PASS: Zero flag = %b (result != 0)", Zero);
        end
        
        // =========================================================================
        // TEST SUMMARY
        // =========================================================================
        $display("\n=== TEST SUMMARY ===");
        if (error_count == 0) begin
            $display("ALL TESTS PASSED! ✓");
        end else begin
            $display("%d TESTS FAILED! ✗", error_count);
        end
        
        $finish;
    end
    
    // Monitor to track changes (optional)
    initial begin
        $monitor("Time: %t | ALUControl: %d | A: %h | B: %h | Result: %h | Zero: %b", 
                 $time, ALUControl, A, B, ALUResult, Zero);
    end
    
endmodule
