module ALU32Bit_tb;
    reg [4:0] ALUControl;
    reg [31:0] A, B;
    wire [31:0] ALUResult;
    wire Zero, Overflow;
    
    ALU32Bit uut (.ALUControl(ALUControl), .A(A), .B(B), 
                  .ALUResult(ALUResult), .Zero(Zero), .Overflow(Overflow));
    
    initial begin
        $display("Testing ALL MIPS ALU Operations...");
        
        // 1. ARITHMETIC OPERATIONS
        $display("\n1. Arithmetic Operations:");
        
        // ADD
        ALUControl = 5'd0; A = 32'h5; B = 32'h3; #10;
        $display("ADD: %d + %d = %d (Zero=%b, Ovfl=%b)", A, B, ALUResult, Zero, Overflow);
        
        // SUB  
        ALUControl = 5'd1; A = 32'hA; B = 32'h5; #10;
        $display("SUB: %d - %d = %d (Zero=%b, Ovfl=%b)", A, B, ALUResult, Zero, Overflow);
        
        // MUL
        ALUControl = 5'd2; A = 32'h6; B = 32'h7; #10;
        $display("MUL: %d * %d = %d", A, B, ALUResult);
        
        // 2. LOGICAL OPERATIONS
        $display("\n2. Logical Operations:");
        
        // AND/ANDI
        ALUControl = 5'd3; A = 32'hF; B = 32'hA; #10;
        $display("AND: %h & %h = %h", A, B, ALUResult);
        
        // OR/ORI
        ALUControl = 5'd4; A = 32'h5; B = 32'hA; #10;
        $display("OR:  %h | %h = %h", A, B, ALUResult);
        
        // XOR/XORI
        ALUControl = 5'd5; A = 32'hF; B = 32'hA; #10;
        $display("XOR: %h ^ %h = %h", A, B, ALUResult);
        
        // NOR
        ALUControl = 5'd6; A = 32'h5; B = 32'hA; #10;
        $display("NOR: ~(%h | %h) = %h", A, B, ALUResult);
        
        // 3. SET OPERATIONS
        $display("\n3. Set Operations:");
        
        // SLT (signed less than) - true
        ALUControl = 5'd7; A = 32'h2; B = 32'h5; #10;
        $display("SLT: %d < %d ? %d", $signed(A), $signed(B), ALUResult);
        
        // SLT (signed less than) - false
        ALUControl = 5'd7; A = 32'hFFFFFFFE; B = 32'h5; #10; // -2 < 5
        $display("SLT: %d < %d ? %d", $signed(A), $signed(B), ALUResult);
        
        // 4. SHIFT OPERATIONS
        $display("\n4. Shift Operations:");
        
        // SLL
        ALUControl = 5'd9; A = 32'h2; B = 32'h1; #10; // shift left by 2
        $display("SLL: %h << 2 = %h", B, ALUResult);
        
        // SRL
        ALUControl = 5'd10; A = 32'h2; B = 32'h8; #10; // shift right by 2
        $display("SRL: %h >> 2 = %h", B, ALUResult);
        
        // 5. BRANCH COMPARISONS
        $display("\n5. Branch Comparisons:");
        
        // BEQ (equal)
        ALUControl = 5'd12; A = 32'h1234; B = 32'h1234; #10;
        $display("BEQ: %h == %h ? %d", A, B, ALUResult);
        
        // BNE (not equal)
        ALUControl = 5'd13; A = 32'h1234; B = 32'h1235; #10;
        $display("BNE: %h != %h ? %d", A, B, ALUResult);
        
        // BGTZ (greater than zero)
        ALUControl = 5'd14; A = 32'h5; B = 32'h0; #10;
        $display("BGTZ: %d > 0 ? %d", $signed(A), ALUResult);
        
        // BGEZ (greater or equal zero)
        ALUControl = 5'd15; A = 32'h0; B = 32'h0; #10;
        $display("BGEZ: %d >= 0 ? %d", $signed(A), ALUResult);
        
        // BLTZ (less than zero)
        ALUControl = 5'd16; A = 32'hFFFFFFFF; B = 32'h0; #10; // -1
        $display("BLTZ: %d < 0 ? %d", $signed(A), ALUResult);
        
        // BLEZ (less or equal zero)
        ALUControl = 5'd17; A = 32'h0; B = 32'h0; #10;
        $display("BLEZ: %d <= 0 ? %d", $signed(A), ALUResult);
        
        // 6. PASSTHROUGH OPERATIONS
        $display("\n6. Passthrough Operations:");
        
        // JR (jump register)
        ALUControl = 5'd18; A = 32'h400000; B = 32'h0; #10;
        $display("JR: PASSA = %h", ALUResult);
        
        // JAL (jump and link)
        ALUControl = 5'd20; A = 32'h0; B = 32'h400004; #10;
        $display("JAL: LINK = %h", ALUResult);
        
        $display("\nAll tests completed!");
        $finish;
    end
endmodule
