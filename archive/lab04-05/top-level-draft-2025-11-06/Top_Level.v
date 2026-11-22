module Top_Level( Clk,
     Reset, regWriteData, pc); 
     
     input Clk;
     input Reset;
     output [31:0] regWriteData;
     output [31:0] pc;

    // --- IF Stage ---
    // Wires coming OUT of the Instruction Fetch Unit
    wire [31:0] PC_plus_4_IF;  // temporarily changed from wire to reg
    wire [31:0] Instruction_IF; // temporarily changed from wire to reg
    reg [31:0] Adder_Ex;
    wire [31:0] PC1;
    wire [31:0] PC2;
    wire [31:0] PCResult;
    reg [31:0] WriteData_WB;
    wire [31:0] writeData_WB_mux;
    reg [4:0] writeRegister_WB;
    reg [4:0] WriteRegister_MEM;
    reg [31:0] writeData_ID; // This will eventually come from the WB stage
    reg [4:0] WriteRegister_ID;
            reg PCSrc_WB;
        reg PCSrc2_WB;
        reg PCSrc;
        reg PCSrc2;
        wire shift;
        wire [31:0] ALU_A;
    

    // takes care of PC and PCAdder
    //InstructionFetchUnit IFU (
      //.Instruction(Instruction_IF),
      //.PCResult(PC_plus_4_IF), 
      //.Reset(Reset),
      //.Clk(Clk)   
    //);
    
    // instantiate all IFU blocks seperately
    // adder
        PCAdder pcAdd(
        .PCResult(PCResult), 
        .PCAddResult(PC_plus_4_IF)
    );
    assign pc = PCResult;
    
    
     // PCSrc mux -  this scares me
    // changed out to PC1
    Mux32Bit2To1 PCSrc_mux(.inA(PC_plus_4_IF), .inB(Adder_Result_MEM), .out(PC1), .sel(PCSrc));
    
    // PCSrc2 mux chooses from out of prev mux or instruction[26:0]
    Mux32Bit2To1 PCSrc2_mux(.inA(PC1), .inB({5'b0, Instruction_MEM[26:0]}), .out(PC2), .sel(PCSrc2));
    //assign PC_plus_4_IF = PC2;
    
        // program counter
        ProgramCounter PC(
        .Address(PC2), 
        .PCResult(PCResult), 
        .Reset(Reset), 
        .Clk(Clk)
    );
    
        // instruction
        InstructionMemory IM(
		.PCResult(PCResult),
        .Instruction(Instruction_IF)
	);
    

    // --- IF/ID Pipeline Register ---
    // These regs hold the values for the ID stage to use.
    reg [31:0] PC_plus_4_ID;
    reg [31:0] Instruction_ID;

    always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            // On reset, clear the pipeline register
            PC_plus_4_ID <= 32'b0;
            Instruction_ID <= 32'b0; // Or a NOP instruction
            WriteData_WB <= 0;
            
            WriteRegister_ID <= 0;
        end else begin
            // On the clock edge, capture the outputs from the IF stage
            PC_plus_4_ID <= PC_plus_4_IF;
            Instruction_ID <= Instruction_IF;
            writeData_ID <= writeData_WB_mux;
            WriteRegister_ID <= writeRegister_WB;
        PCSrc <= PCSrc_WB;
        PCSrc2 <= PCSrc2_WB;
            
        end
    end

    // --- ID Stage ---
    // The ID stage components now use the REGISTERED values
    
    

    wire RegWrite_ID;        // This will come from the Control Unit
    wire [31:0] ReadData1_ID;
    wire [31:0] ReadData2_ID;
    wire RegDst_ID;          // This will come from the Control Unit
    wire ALUSrc_ID;
    wire MemtoReg_ID;
    wire memRead_ID;
    wire memWrite_ID;
    wire branch_ID;
    wire [4:0] ALUOp_ID;
    wire PCSrc_ID;
    wire PCSrc2_ID;
    wire [31:0] Instruction_SE;
    reg RegWrite_WB;
    
    
    //reg [4:0] writeRegister_WB;
    
    
    
    Control ctrl (.instruction(Instruction_ID), .RegDst(RegDst_ID), .ALUSrc(ALUSrc_ID), .MemtoReg(MemtoReg_ID), 
    .RegWrite(RegWrite_ID), .MemRead(memRead_ID), .MemWrite(memWrite_ID), .Branch(branch_ID), .ALUOp(ALUOp_ID),
    .PCSrc(PCSrc_ID), .PCSrc2(PCSrc2_ID), .shift(shift));
    

    // The RegisterFile and MUX now use Instruction_ID, not Instruction_IF
    RegisterFile u1 (
      .ReadRegister1(Instruction_ID[25:21]), // rs
      .ReadRegister2(Instruction_ID[20:16]), // rt
      .WriteRegister(WriteRegister_ID),     // WORKING
      .WriteData(writeData_ID),             // maybe should be _WB
      .RegWrite(RegWrite_WB),               // WORKING
      .Clk(Clk),
      .ReadData1(ReadData1_ID),             // BROKEN
      .ReadData2(ReadData2_ID)
    );
    
    assign regWriteData = writeData_ID;
    
    // SignExtend instantation
    SignExtension SE(.in(Instruction_ID[15:0]), .out(Instruction_SE));
    
    // ID/EX PIPELINE
        wire [31:0] write_reg_mux_out_EX;
        reg RegDst_EX;          // This will come from the Control Unit
        reg ALUSrc_EX;
        reg MemtoReg_EX;
        reg memRead_EX;
        reg memWrite_EX;
        reg branch_EX;
        reg [4:0] ALUOp_EX;
        reg PCSrc_EX;
        reg PCSrc2_EX;
        reg RegWrite_EX;        // This will come from the Control Unit
        reg [4:0] WriteRegister_EX;
        reg [31:0] Instruction_EX;
        wire [31:0] ALUSrc_mux_out_EX;
        reg [31:0] Instruction_SE_EX;
        wire [31:0] ShiftLeft2;
        reg [31:0] PC_plus_4_EX;
        wire [31:0] Adder_Result_EX;
        wire [31:0] ALUResult_EX;
        reg [31:0] writeData_EX;
        reg [31:0] readData1_EX;
        reg [31:0] readData2_EX;
        wire [31:0] ALU_B;
        reg shift_EX;
        
        
        //EX = ID
        always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            RegDst_EX <= 0;
            ALUSrc_EX <= 0;
            MemtoReg_EX <= 0;
            memRead_EX <= 0;
            memWrite_EX <= 0;
            branch_EX <= 0;
            ALUOp_EX <= 0;
            PCSrc_EX <= 0;
            PCSrc2_EX <= 0;
            RegWrite_EX <= 0;
            Instruction_SE_EX <= 0;
            PC_plus_4_EX <= 0;
            writeData_EX <= 0;
            //Adder_Result_EX <= 0;
            //ALUResult_EX <= 0;
            shift_EX <= 0;
            end
        else begin
            Instruction_EX <= Instruction_ID;
            RegDst_EX <= RegDst_ID;
            ALUSrc_EX <= ALUSrc_ID;
            MemtoReg_EX <= MemtoReg_ID;
            memRead_EX <= memRead_ID;
            memWrite_EX <= memWrite_ID;
            branch_EX <= branch_ID;
            ALUOp_EX <= ALUOp_ID;
            PCSrc_EX <= PCSrc_ID;
            PCSrc2_EX <= PCSrc2_ID;
            RegWrite_EX <= RegWrite_ID;
            Instruction_SE_EX <= Instruction_SE;
            PC_plus_4_EX <= PC_plus_4_ID;
            writeData_EX <= writeData_ID;
            WriteRegister_EX <= WriteRegister_ID;
            readData1_EX <= ReadData1_ID;
            readData2_EX <= ReadData2_ID;
            shift_EX <= shift;
            end 
    end
        
    // Instantiate the RegDst MUX
    Mux32Bit2To1 regDst_mux (
        .out(write_reg_mux_out_EX),
        
        // Input 0: Pad the 5-bit 'rt' field to 32 bits
        .inA({27'b0, Instruction_EX[20:16]}), 
        
        // Input 1: Pad the 5-bit 'rd' field to 32 bits
        .inB({27'b0, Instruction_EX[15:11]}), 
        
        .sel(RegDst_EX)
        
    );
    
    
    // ALUsrc mux
    Mux32Bit2To1 ALUSrc (
        .out(ALU_B),
       
        .inA(readData2_EX), 
        
        .inB(Instruction_SE_EX), 
        
        .sel(ALUSrc_EX)
        
    );
    
    // shift left 2
    ALU32Bit SL2(.ALUControl(5'b01111), .A(Instruction_SE_EX), .B(2), 
    .ALUResult(ShiftLeft2));
      
    // ADD
    ALU32Bit Adder(.ALUControl(5'b00010), .A(ShiftLeft2),
    .B(PC_plus_4_EX), .ALUResult(Adder_Result_EX));
    
    // shamt mux
    Mux32Bit2To1 shamt (
    .out(ALU_A),
    .inA(readData1_EX),
    .inB({27'b0, Instruction_EX[10:6]}),
    .sel(shift_EX)
   );
   
   
   // ALU
   //assign ALU_B = (Instruction_EX[10:6] == 0) ? ALUSrc_mux_out_EX : Instruction_EX[10:6];
   
   ALU32Bit ALU(.ALUControl(ALUOp_EX), .A(ALU_A),
                .B(ALU_B), .ALUResult(ALUResult_EX), .Zero(Branch_EX));

   
   // EX/MEM Pipeline
        reg [31:0] Instruction_MEM;
        reg [31:0] PC_plus_4_MEM;
        reg [31:0] ALUResult_MEM;
        reg [31:0] Adder_Result_MEM;
        reg MemtoReg_MEM;
        reg memRead_MEM;
        reg memWrite_MEM;
        reg branch_MEM;
        
        reg [31:0] writeData_MEM;
        reg PCSrc_MEM;
        reg PCSrc2_MEM;
        wire [31:0] readData_MEM;
        reg RegWrite_MEM;
        reg [31:0] readData1_MEM;
        reg [31:0] readData2_MEM;
        
        
        // MEM = EX
        always @(posedge Clk or posedge Reset) begin
        if (Reset) begin
            MemtoReg_MEM <= 0;
            memRead_MEM <= 0;
            memWrite_MEM <= 0;
            branch_MEM <= 0;
            PCSrc_MEM <= 0;
            PCSrc2_MEM <= 0;
            PC_plus_4_MEM <= 0;
            Instruction_MEM <= 0;
            ALUResult_MEM <= 0;
            Adder_Result_MEM <= 0;
            readData1_MEM <= 0;
            readData2_MEM <= 0;
            //Adder_Result_EX <= 0;
            //ALUResult_EX <= 0;
            end
        else begin
            Instruction_MEM <= Instruction_EX;
            MemtoReg_MEM <= MemtoReg_EX;
            memRead_MEM <= memRead_EX;
            memWrite_MEM <= memWrite_EX;
            branch_MEM <= branch_EX;
            PCSrc_MEM <= PCSrc_EX;
            PCSrc2_MEM <= PCSrc2_EX;
            PC_plus_4_MEM <= PC_plus_4_EX;
            ALUResult_MEM <= ALUResult_EX;
            Adder_Result_MEM <= Adder_Result_EX;
            RegWrite_MEM <= RegWrite_EX;
            writeData_MEM <= writeData_EX;
            WriteRegister_MEM <= write_reg_mux_out_EX;
            readData1_MEM <= readData1_EX;
            readData2_MEM <= readData2_EX;
            
            // branch
            PCSrc_MEM <= branch_MEM && ALUResult_MEM;
            end 
    end
        

        // DataMemory
        DataMemory dm(.Address(ALUResult_MEM), .WriteData(readData2_MEM), .Clk(Clk), .MemWrite(memWrite_MEM), .MemRead(memRead_MEM), .ReadData(readData_MEM));
   
   // MEM/WB Pipeline
   wire [31:0] writeData_WB_mux;
        reg [31:0] Instruction_WB;
        reg [31:0] PC_plus_4_WB;
        reg [31:0] ALUResult_WB;
        //reg [31:0] Adder_Result_WB;
        reg MemtoReg_WB;
        //reg memRead_WB;
        reg memWrite_WB;
        //reg branch_WB;
        reg [31:0] readData_WB;
        
        //reg [31:0] WriteData_WB;
        //wire [31:0] ReadData1_WB;
        //wire [31:0] ReadData2_WB;
        

        
        
    always @(posedge Clk or posedge Reset) begin
    if (Reset) begin
        MemtoReg_WB   <= 0;
        RegWrite_WB   <= 0;
        ALUResult_WB  <= 0;
        readData_WB   <= 0;
        PC_plus_4_WB  <= 0;
        WriteData_WB <= 0;
        PCSrc_WB <= 0;
        PCSrc2_WB <= 0;
        writeRegister_WB <= 0;
    end else begin
        MemtoReg_WB   <= MemtoReg_MEM;
        writeRegister_WB   <= WriteRegister_MEM;
        ALUResult_WB  <= ALUResult_MEM;
        readData_WB   <= readData_MEM;
        RegWrite_WB <= RegWrite_MEM;
        PCSrc_WB <= PCSrc_MEM;
        PCSrc2_WB <= PCSrc2_MEM;
        //WriteData_WB    <= writeData_WB_mux; 
         
    end
end
        
   // INSTANTIATE MEMTOREGMUX
   Mux32Bit2To1 MemtoReg (
        .out(writeData_WB_mux), // CHANGED 11/4
        
        
        .inA(readData_WB), 
        
        
        .inB(ALUResult_WB), 
        
        .sel(MemtoReg_WB)
        
    );
    // INSTANTIATE REGISTER AGAIN SO WE CAN WRITE
   // RegisterFile u2 (
      //.ReadRegister1(Instruction_WB[25:21]), // rs
      //.ReadRegister2(Instruction_WB[20:16]), // rt
      //.WriteRegister(writeRegister_WB),
      //.WriteData(WriteData_WB),
      //.RegWrite(RegWrite_WB),
     // .Clk(Clk),
      //.ReadData1(ReadData1_WB),
      //.ReadData2(ReadData2_WB)
    //);
    
    
endmodule