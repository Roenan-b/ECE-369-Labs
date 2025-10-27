module ALU32Bit_tb;
    reg [5:0] ALUControl;
    reg [31:0] A, B;
    wire [31:0] ALUResult;
    wire Zero, Overflow;
    
    ALU32Bit uut (
        .ALUControl(ALUControl),
        .A(A),
        .B(B),
        .ALUResult(ALUResult),
        .Zero(Zero),
        .Overflow(Overflow)
    );
    
    integer error_count;
    integer test_count;
    
    // Helper task for checking results
    task check_result;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            test_count = test_count + 1;
            if (ALUResult !== expected) begin
                $display("? FAIL: %s", test_name);
                $display("   Expected: 0x%h (%d), Got: 0x%h (%d)", 
                         expected, expected, ALUResult, ALUResult);
                error_count = error_count + 1;
            end else begin
                $display("? PASS: %s", test_name);
            end
        end
    endtask
    
    task check_zero_flag;
        input expected;
        input [255:0] test_name;
        begin
            test_count = test_count + 1;
            if (Zero !== expected) begin
                $display("? FAIL: %s", test_name);
                //$display("Expected: %0d, Got: %0d", expected, ALUResult);
                $display("   Expected Zero=%b, Got Zero=%b", expected, Zero);
                error_count = error_count + 1;
            end else begin
                $display("? PASS: %s", test_name);
            end
        end
    endtask
    
    initial begin
        error_count = 0;
        test_count = 0;
        
        $display("\n??????????????????????????????????????????????????????????????");
        $display("?     COMPREHENSIVE MIPS ALU TESTBENCH                       ?");
        $display("?     Testing ALL Operations with Unified Encoding           ?");
        $display("??????????????????????????????????????????????????????????????\n");
        
        // =====================================================================
        // 1. LOGICAL OPERATIONS
        // =====================================================================
        $display("???????????????????????????????????????????");
        $display("?  1. LOGICAL OPERATIONS                  ?");
        $display("???????????????????????????????????????????");
        
        // AND (and, andi)
        #10
        // AND (and, andi)
        ALUControl = 5'd0; A = 32'd15; B = 32'd10; #10;
        check_result(32'd10, "AND: 15 & 10 = 10");

        ALUControl = 5'd0; A = -1; B = 32'd305419896; #10;   // -1 = 0xFFFFFFFF, 305419896 = 0x12345678
        check_result(32'd305419896, "AND: -1 & 305419896 = 305419896");

        // OR (or, ori)
        ALUControl = 5'd1; A = 32'd5; B = 32'd10; #10;
        check_result(32'd15, "OR: 5 | 10 = 15");

        ALUControl = 5'd1; A = 32'd4042322160; B = 32'd252645135; #10; // 0xF0F0F0F0 and 0x0F0F0F0F
        check_result(-1, "OR: 4042322160 | 252645135 = -1");

        // XOR (xor, xori)
        ALUControl = 5'd2; A = 32'd15; B = 32'd10; #10;
        check_result(32'd5, "XOR: 15 ^ 10 = 5");

        ALUControl = 5'd2; A = -1; B = -1; #10;
        check_result(32'd0, "XOR: -1 ^ -1 = 0");

        // NOR (nor)
        ALUControl = 5'd3; A = 32'd5; B = 32'd10; #10;
        check_result(-16, "NOR: ~(5 | 10) = -16");

        ALUControl = 5'd3; A = 32'd0; B = 32'd0; #10;
        check_result(-1, "NOR: ~(0 | 0) = -1");

        // =====================================================================
        // 2. ARITHMETIC OPERATIONS
        // =====================================================================
        $display("\n???????????????????????????????????????????");
        $display("?  2. ARITHMETIC OPERATIONS               ?");
        $display("???????????????????????????????????????????");
        
        // ADD (add, addi, lw, sw, lb, sb, lh, sh)
        ALUControl = 5'd4; A = 32'h00000005; B = 32'h00000003; #10;
        check_result(32'h00000008, "ADD: 5 + 3 = 8");
        
        ALUControl = 5'd4; A = 32'hFFFFFFFF; B = 32'h00000001; #10;
        check_result(32'h00000000, "ADD: -1 + 1 = 0");
        
        // Test ADD overflow (positive + positive = negative)
        ALUControl = 5'd4; A = 32'h7FFFFFFF; B = 32'h00000001; #10;
        check_result(32'h80000000, "ADD: 0x7FFFFFFF + 1 (overflow)");
        if (Overflow !== 1'b1) begin
            $display("   ??  Warning: Overflow flag not set");
        end
        
        // SUB (sub)
        ALUControl = 5'd5; A = 32'h0000000A; B = 32'h00000005; #10;
        check_result(32'h00000005, "SUB: 10 - 5 = 5");
        
        ALUControl = 5'd5; A = 32'h00000005; B = 32'h00000005; #10;
        check_result(32'h00000000, "SUB: 5 - 5 = 0");
        
        ALUControl = 5'd5; A = 32'h00000000; B = 32'h00000001; #10;
        check_result(32'hFFFFFFFF, "SUB: 0 - 1 = -1 (0xFFFFFFFF)");
        
        // MUL (mul)
        ALUControl = 5'd6; A = 32'h00000006; B = 32'h00000007; #10;
        check_result(32'h0000002A, "MUL: 6 * 7 = 42");
        
        ALUControl = 5'd6; A = 32'h00000000; B = 32'h12345678; #10;
        check_result(32'h00000000, "MUL: 0 * anything = 0");
        
        ALUControl = 5'd6; A = 32'hFFFFFFFF; B = 32'h00000002; #10; // -1 * 2 = -2
        check_result(32'hFFFFFFFE, "MUL: -1 * 2 = -2");
        
        // =====================================================================
        // 3. SET COMPARISON OPERATIONS
        // =====================================================================
        $display("\n???????????????????????????????????????????");
        $display("?  3. SET COMPARISON OPERATIONS           ?");
        $display("???????????????????????????????????????????");
        
        // SLT (slt, slti) - true case
        ALUControl = 5'd7; A = 32'h00000002; B = 32'h00000005; #10;
        check_result(32'h00000001, "SLT: 2 < 5 ? 1");
        
        // SLT - false case
        ALUControl = 5'd7; A = 32'h0000000A; B = 32'h00000005; #10;
        check_result(32'h00000000, "SLT: 10 < 5 ? 0");
        
        // SLT - equal case
        ALUControl = 5'd7; A = 32'h00000005; B = 32'h00000005; #10;
        check_result(32'h00000000, "SLT: 5 < 5 ? 0");
        
        // SLT with negative numbers
        ALUControl = 5'd7; A = 32'hFFFFFFFE; B = 32'h00000005; #10; // -2 < 5
        check_result(32'h00000001, "SLT: -2 < 5 ? 1");
        
        ALUControl = 5'd7; A = 32'h00000005; B = 32'hFFFFFFFE; #10; // 5 < -2
        check_result(32'h00000000, "SLT: 5 < -2 ? 0");
        
        ALUControl = 5'd7; A = 32'hFFFFFFFE; B = 32'hFFFFFFFF; #10; // -2 < -1
        check_result(32'h00000001, "SLT: -2 < -1 ? 1");
        
        // =====================================================================
        // 4. SHIFT OPERATIONS
        // =====================================================================
        $display("\n???????????????????????????????????????????");
        $display("?  4. SHIFT OPERATIONS                    ?");
        $display("???????????????????????????????????????????");
        
        // SLL (sll) - shift left logical
        ALUControl = 5'd8; A = 32'h00000002; B = 32'h00000001; #10; // shift 1 left by 2
        check_result(32'h00000004, "SLL: 1 << 2 = 4");
        
        ALUControl = 5'd8; A = 32'h00000004; B = 32'h00000001; #10; // shift 1 left by 4
        check_result(32'h00000010, "SLL: 1 << 4 = 16");
        
        ALUControl = 5'd8; A = 32'h00000008; B = 32'h000000FF; #10; // shift 0xFF left by 8
        check_result(32'h0000FF00, "SLL: 0xFF << 8 = 0xFF00");
        
        // SRL (srl) - shift right logical
        ALUControl = 5'd9; A = 32'h00000002; B = 32'h00000008; #10; // shift 8 right by 2
        check_result(32'h00000002, "SRL: 8 >> 2 = 2");
        
        ALUControl = 5'd9; A = 32'h00000004; B = 32'h00000010; #10; // shift 16 right by 4
        check_result(32'h00000001, "SRL: 16 >> 4 = 1");
        
        ALUControl = 5'd9; A = 32'h00000008; B = 32'h0000FF00; #10; // shift 0xFF00 right by 8
        check_result(32'h000000FF, "SRL: 0xFF00 >> 8 = 0xFF");
        
        // =====================================================================
        // 5. BRANCH COMPARISON OPERATIONS
        // =====================================================================
        $display("\n???????????????????????????????????????????");
        $display("?  5. BRANCH COMPARISON OPERATIONS        ?");
        $display("???????????????????????????????????????????");
        
        // BEQ (beq) - equal
        ALUControl = 5'd10; A = 32'h12345678; B = 32'h12345678; #10;
        check_result(32'h00000001, "BEQ: 0x12345678 == 0x12345678 ? 1");
        
        // BEQ - not equal
        ALUControl = 5'd10; A = 32'h12345678; B = 32'h12345679; #10;
        check_result(32'h00000000, "BEQ: 0x12345678 == 0x12345679 ? 0");
        
        // BNE (bne) - not equal
        ALUControl = 5'd11; A = 32'h12345678; B = 32'h12345679; #10;
        check_result(32'h00000001, "BNE: 0x12345678 != 0x12345679 ? 1");
        
        // BNE - equal
        ALUControl = 5'd11; A = 32'hAAAAAAAA; B = 32'hAAAAAAAA; #10;
        check_result(32'h00000000, "BNE: 0xAAAAAAAA != 0xAAAAAAAA ? 0");
        
        // BGTZ (bgtz) - greater than zero (positive)
        ALUControl = 5'd12; A = 32'h00000005; B = 32'h00000000; #10;
        check_result(32'h00000001, "BGTZ: 5 > 0 ? 1");
        
        // BGTZ - zero
        ALUControl = 5'd12; A = 32'h00000000; B = 32'h00000000; #10;
        check_result(32'h00000000, "BGTZ: 0 > 0 ? 0");
        
        // BGTZ - negative
        ALUControl = 5'd12; A = 32'hFFFFFFFF; B = 32'h00000000; #10; // -1
        check_result(32'h00000000, "BGTZ: -1 > 0 ? 0");
        
        // BGEZ (bgez) - greater or equal zero (positive)
        ALUControl = 5'd13; A = 32'h00000005; B = 32'h00000000; #10;
        check_result(32'h00000001, "BGEZ: 5 >= 0 ? 1");
        
        // BGEZ - zero
        ALUControl = 5'd13; A = 32'h00000000; B = 32'h00000000; #10;
        check_result(32'h00000001, "BGEZ: 0 >= 0 ? 1");
        
        // BGEZ - negative
        ALUControl = 5'd13; A = 32'hFFFFFFFF; B = 32'h00000000; #10; // -1
        check_result(32'h00000000, "BGEZ: -1 >= 0 ? 0");
        
        // BLTZ (bltz) - less than zero (negative)
        ALUControl = 5'd14; A = 32'hFFFFFFFF; B = 32'h00000000; #10; // -1
        check_result(32'h00000001, "BLTZ: -1 < 0 ? 1");
        
        // BLTZ - zero
        ALUControl = 5'd14; A = 32'h00000000; B = 32'h00000000; #10;
        check_result(32'h00000000, "BLTZ: 0 < 0 ? 0");
        
        // BLTZ - positive
        ALUControl = 5'd14; A = 32'h00000005; B = 32'h00000000; #10;
        check_result(32'h00000000, "BLTZ: 5 < 0 ? 0");
        
        // BLEZ (blez) - less or equal zero (negative)
        ALUControl = 5'd15; A = 32'hFFFFFFFF; B = 32'h00000000; #10; // -1
        check_result(32'h00000001, "BLEZ: -1 <= 0 ? 1");
        
        // BLEZ - zero
        ALUControl = 5'd15; A = 32'h00000000; B = 32'h00000000; #10;
        check_result(32'h00000001, "BLEZ: 0 <= 0 ? 1");
        
        // BLEZ - positive
        ALUControl = 5'd15; A = 32'h00000005; B = 32'h00000000; #10;
        check_result(32'h00000000, "BLEZ: 5 <= 0 ? 0");
        
        // =====================================================================
        // 6. PASSTHROUGH OPERATIONS
        // =====================================================================
        $display("\n???????????????????????????????????????????");
        $display("?  6. PASSTHROUGH OPERATIONS              ?");
        $display("???????????????????????????????????????????");
        
        // PASSA (jr)
        ALUControl = 5'd16; A = 32'h40000000; B = 32'h12345678; #10;
        check_result(32'h40000000, "PASSA (JR): Pass A = 0x40000000");
        
        ALUControl = 5'd16; A = 32'hDEADBEEF; B = 32'h00000000; #10;
        check_result(32'hDEADBEEF, "PASSA (JR): Pass A = 0xDEADBEEF");
        
        // PASSB (jal/link)
        ALUControl = 5'd17; A = 32'h00000000; B = 32'h12345678; #10;
        check_result(32'h12345678, "PASSB (JAL): Pass B = 0x12345678");
        
        ALUControl = 5'd17; A = 32'hFFFFFFFF; B = 32'h400004; #10;
        check_result(32'h00400004, "PASSB (JAL): Pass B = 0x400004");
        
        // =====================================================================
        // 7. ZERO FLAG TESTING
        // =====================================================================
        $display("\n???????????????????????????????????????????");
        $display("?  7. ZERO FLAG TESTING                   ?");
        $display("???????????????????????????????????????????");
        
        // Zero flag true (SUB result = 0)
        ALUControl = 5'd5; A = 32'h00000005; B = 32'h00000005; #10;
        check_zero_flag(1'b1, "Zero flag: 5 - 5 = 0, Zero=1");
        
        // Zero flag true (ADD result = 0)
        ALUControl = 5'd4; A = 32'hFFFFFFFF; B = 32'h00000001; #10;
        check_zero_flag(1'b1, "Zero flag: -1 + 1 = 0, Zero=1");
        
        // Zero flag false (result != 0)
        ALUControl = 5'd4; A = 32'h00000001; B = 32'h00000001; #10;
        check_zero_flag(1'b0, "Zero flag: 1 + 1 = 2, Zero=0");
        
        // Zero flag with XOR
        ALUControl = 5'd2; A = 32'h12345678; B = 32'h12345678; #10;
        check_zero_flag(1'b1, "Zero flag: XOR same values, Zero=1");
        
        // =====================================================================
        // TEST SUMMARY
        // =====================================================================
        $display("\n??????????????????????????????????????????????????????????????");
        $display("?                    TEST SUMMARY                            ?");
        $display("??????????????????????????????????????????????????????????????");
        $display("?  Total Tests: %3d                                          ?", test_count);
        $display("?  Passed:      %3d                                          ?", test_count - error_count);
        $display("?  Failed:      %3d                                          ?", error_count);
        $display("??????????????????????????????????????????????????????????????");
        if (error_count == 0) begin
            $display("?  ??? ALL TESTS PASSED! ???                             ?");
        end else begin
            $display("?  ??? SOME TESTS FAILED! ???                         ?");
        end
        $display("??????????????????????????????????????????????????????????????\n");
        
        $finish;
    end
    
endmodule
